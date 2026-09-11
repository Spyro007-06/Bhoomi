"""Pesticide label OCR extraction. Feeds F8.

OWNER: Suchit. Spec: docs/DESIGN.md §9, docs/API_CONTRACT.md §9.

Label text only; no layout understanding needed. The verdict that follows is a
table lookup in core/ — no model is consulted for it, and the LLM is not in this
path at all.

Unlike `classify()`, there is no stub/real switch here and none is added: the
three feature flags are `VISION_MODEL`, `ASR_PROVIDER` and `LLM_ENABLED`
(docs/DESIGN.md §12) — an exhaustive list, not an example. Tesseract is a local,
free binary with no per-call cost to gate, unlike the paddy checkpoint or a paid
Sarvam/LLM call, so this always runs for real.

LANDMINE for whoever wires labelcheck.py (routers/__init__.py names it Suchit +
Shreekumar + Thaariha — this module is only the OCR third of it): `seed/
registered_use.csv`'s `active_ingredient` column is the FULL printed name
INCLUDING concentration and formulation code — e.g. "Isoprothiolane 40% EC", not
the bare "isoprothiolane" — and `services/registered_use.py::lookup()` does an
exact casefold+trim match against that whole string. Calling `lookup()` with
just this module's `active_ingredient` field will return NOT_IN_RECORDS for
every real label. `LabelExtract.raw_line` carries the untouched OCR line so
labelcheck.py can build (or re-derive) whatever key actually matches — this
module does not decide that key for it.
"""

from __future__ import annotations

import io
import logging
import re
from dataclasses import dataclass
from pathlib import Path

import pytesseract

log = logging.getLogger("bhoomi.vision")


@dataclass(frozen=True, slots=True)
class LabelExtract:
    """OCR's read of a pesticide label. Wire shape: docs/API_CONTRACT.md §9
    `extracted` (field names match exactly).

    Any of the three text fields may be `None` — OCR found no text it could
    confidently attribute to that slot. A `None` here is not itself
    OCR_UNREADABLE: the caller compares `ocr_confidence` to `config.OCR_FLOOR`
    to decide that (this module does not import `config` — gate-shaped
    constants belong to the caller, docs/DESIGN.md §6).
    """

    active_ingredient: str | None
    concentration: str | None
    formulation: str | None
    ocr_confidence: float
    raw_line: str | None = None


# ---------------------------------------------------------------------------
# CIB&RC formulation codes — the ones present in seed/registered_use.csv, plus
# the other common Indian-label codes from the same CIB&RC major-use tables.
# Sorted longest-first before building the regex so "WDG" is tried before the
# "WG" it contains would otherwise match first.
# ---------------------------------------------------------------------------
FORMULATION_CODES: dict[str, str] = {
    "WDG": "water dispersible granules",
    "WG": "water dispersible granules",
    "WP": "wettable powder",
    "WS": "water soluble powder for seed treatment",
    "DS": "dry seed treatment powder",
    "SC": "suspension concentrate",
    "SL": "soluble liquid",
    "SP": "soluble powder",
    "EC": "emulsifiable concentrate",
    "ULV": "ultra low volume liquid",
    "GR": "granules",
    "DP": "dustable powder",
    "FS": "flowable concentrate for seed treatment",
    "CS": "capsule suspension",
}

_FORMULATION_CODE_ALTERNATION = "|".join(
    re.escape(c) for c in sorted(FORMULATION_CODES, key=len, reverse=True)
)
_FORMULATION_CODE_PATTERN = re.compile(
    r"\b(" + _FORMULATION_CODE_ALTERNATION + r")\b", re.IGNORECASE
)

# A bare percentage, optionally qualified w/w, w/v or v/v — the concentration
# half of a label line such as "50% WP" or "3% w/w".
_CONCENTRATION_PATTERN = re.compile(
    r"\d{1,3}(?:\.\d+)?\s?%(?:\s?w/w|\s?w/v|\s?v/v)?", re.IGNORECASE
)

# Words that show up on the same line as the active ingredient but aren't part
# of its name, so they'd otherwise leak into the extracted ingredient string.
_NOISE_WORDS = {"contains", "content", "technical", "grade", "w", "w/w", "w/v", "v/v"}

# Tesseract configuration: a label is normally photographed as one dense block
# of text (name, dose table, hazard pictograms as noise) rather than a page
# with paragraphs, so a uniform-block page segmentation mode reads it more
# reliably than tesseract's default (which assumes prose layout).
_TESSERACT_CONFIG = "--psm 6"


def _load_image_bytes(image: bytes | str) -> bytes:
    """`image` is either raw bytes, or a filesystem path to read them from.

    Fetching by object/asset key is the router/deps layer's job (it owns
    storage), not vision's — mirrors classifier.py's `_load_image_bytes`.
    """
    if isinstance(image, bytes):
        return image
    return Path(image).read_bytes()


def _mean_confidence(raw_confs: list) -> float:
    """Tesseract reports per-word confidence 0-100, or -1 for non-text boxes
    (lines, blocks). Average over the real words only; no words read at all is
    confidence 0.0, not an error — an unreadable photo is a normal outcome
    here (docs/DESIGN.md §9), not a failure.
    """
    values = []
    for raw in raw_confs:
        try:
            value = float(raw)
        except (TypeError, ValueError):
            continue
        if value >= 0:
            values.append(value)
    if not values:
        return 0.0
    return round(sum(values) / len(values) / 100.0, 3)


def _reconstruct_lines(data: dict) -> str:
    """`image_to_data` returns one row per WORD, not per line — `data["text"]`
    on its own has no line boundaries. Group words back into lines using
    tesseract's own (block_num, par_num, line_num) triple, in the order
    tesseract emitted them, and join words within a line with spaces so
    "50%" and "WP" land back on the same line instead of each getting its
    own — which is exactly the bug a naive `"\\n".join(data["text"])` has.
    """
    lines: dict[tuple[int, int, int], list[str]] = {}
    order: list[tuple[int, int, int]] = []
    for i, word in enumerate(data["text"]):
        if not word.strip():
            continue
        key = (data["block_num"][i], data["par_num"][i], data["line_num"][i])
        if key not in lines:
            lines[key] = []
            order.append(key)
        lines[key].append(word)
    return "\n".join(" ".join(lines[key]) for key in order)


def _clean_ingredient(text: str) -> str | None:
    cleaned = re.sub(r"[^A-Za-z+\- ]", " ", text)
    words = [w for w in cleaned.split() if w.lower() not in _NOISE_WORDS and w != "-"]
    result = " ".join(words).strip()
    return result or None


def _parse_label_text(
    raw_text: str,
) -> tuple[str | None, str | None, str | None, str | None]:
    """Find the label line carrying a concentration and/or formulation code,
    and split it into (active_ingredient, concentration, formulation, line).

    Matching is deliberately simple, per the module docstring: no attempt to
    handle combination products (e.g. "Carboxin 37.5% + Thiram 37.5% DS")
    beyond picking up the first ingredient — a partial read here is safe,
    because `registered_use.lookup()` treats anything that isn't an exact
    string match as NOT_IN_RECORDS rather than a wrong (and dangerous) match.
    """
    lines = [ln.strip() for ln in raw_text.splitlines() if ln.strip()]

    for i, line in enumerate(lines):
        conc_match = _CONCENTRATION_PATTERN.search(line)
        form_match = _FORMULATION_CODE_PATTERN.search(line)
        if not conc_match and not form_match:
            continue

        code = form_match.group(1).upper() if form_match else None
        formulation = FORMULATION_CODES[code] if code else None
        concentration = None
        if conc_match:
            percent_text = conc_match.group(0).strip()
            concentration = f"{percent_text} {code}" if code else percent_text

        # Strip whichever of the two matched spans are present to isolate the
        # ingredient-name portion of this line. Remove the later-starting span
        # first so the earlier span's offsets stay valid.
        spans = sorted(
            (m.span() for m in (conc_match, form_match) if m is not None),
            reverse=True,
        )
        remainder = line
        for start, end in spans:
            remainder = remainder[:start] + remainder[end:]

        ingredient = _clean_ingredient(remainder)
        if ingredient is None and i > 0:
            # Two-line layout: e.g. "IMIDACLOPRID" on one line, "17.8% SL" on
            # the next. Fall back to the previous non-empty line.
            ingredient = _clean_ingredient(lines[i - 1])

        return (ingredient, concentration, formulation, line)

    return (None, None, None, None)


def extract_label(image: bytes | str) -> LabelExtract:
    """Extract {active_ingredient, concentration, formulation, ocr_confidence}.

    Below `config.OCR_FLOOR` the caller returns OCR_UNREADABLE and offers the
    voice/text fallback rather than guessing an ingredient. docs/DESIGN.md §9.

    Args:
        image: image bytes, or a filesystem path to read them from.

    Returns:
        A `LabelExtract`. All three text fields may be `None` on a genuinely
        unreadable photo — `ocr_confidence` is what the caller gates on, not
        the presence of these fields.

    Raises:
        RuntimeError: the `tesseract-ocr` system binary isn't on PATH. This is
            a deployment problem, not a bad-photo problem — it must fail
            loudly rather than be mistaken for OCR_UNREADABLE.
        Exception: (from PIL) if the image cannot be decoded at all — a
            garbage input must fail loudly, not get silently "read" as blank.
    """
    from PIL import Image

    image_bytes = _load_image_bytes(image)

    with Image.open(io.BytesIO(image_bytes)) as img:
        img = img.convert("L")  # grayscale: label photos are text-on-plastic,
        # not colour-dependent, and this is what tesseract expects
        try:
            data = pytesseract.image_to_data(
                img, config=_TESSERACT_CONFIG, output_type=pytesseract.Output.DICT
            )
        except pytesseract.TesseractNotFoundError as exc:
            raise RuntimeError(
                "tesseract binary not found on PATH — install the tesseract-ocr "
                "system package (not a pip package; pytesseract only wraps it). "
                "docs/DESIGN.md §9."
            ) from exc

    raw_text = _reconstruct_lines(data)
    ocr_confidence = _mean_confidence(data["conf"])
    active_ingredient, concentration, formulation, raw_line = _parse_label_text(raw_text)

    log.info(
        "vision.extract_label(): ocr_confidence=%.3f matched_line=%r",
        ocr_confidence,
        raw_line,
    )

    return LabelExtract(
        active_ingredient=active_ingredient,
        concentration=concentration,
        formulation=formulation,
        ocr_confidence=ocr_confidence,
        raw_line=raw_line,
    )
