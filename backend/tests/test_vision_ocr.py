"""`extract_label()` is real OCR, not a stub — docs/DESIGN.md §9.

Unlike vision/classifier.py there is no VISION_MODEL-style switch here (only
three flags exist, docs/DESIGN.md §12), so these tests exercise tesseract for
real against small synthetic label images rather than monkeypatching a stub
flag.
"""

from __future__ import annotations

import io

import pytest
from PIL import Image, ImageDraw, ImageFont

from app.vision import LabelExtract, extract_label
from app.vision.ocr import FORMULATION_CODES


def _label_image(lines: list[str]) -> bytes:
    """Render `lines` as black text on a white background, PNG-encoded.

    A generously sized, high-contrast synthetic image — the point of these
    tests is verifying the parsing logic runs on real tesseract output, not
    benchmarking OCR accuracy on hard photos.
    """
    font = ImageFont.truetype(
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", size=40
    )
    img = Image.new("RGB", (900, 120 * len(lines) + 40), "white")
    draw = ImageDraw.Draw(img)
    for i, line in enumerate(lines):
        draw.text((20, 20 + 120 * i), line, fill="black", font=font)
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return buf.getvalue()


def test_extract_label_reads_a_clean_single_line_label() -> None:
    result = extract_label(_label_image(["CARBENDAZIM 50% WP"]))

    assert isinstance(result, LabelExtract)
    assert result.active_ingredient is not None
    assert "carbendazim" in result.active_ingredient.lower()
    assert result.concentration == "50% WP"
    assert result.formulation == FORMULATION_CODES["WP"]
    assert 0.0 <= result.ocr_confidence <= 1.0
    assert result.ocr_confidence > 0.0


def test_extract_label_handles_two_line_layout() -> None:
    """Ingredient name and concentration/formulation on separate lines — a
    common real-label layout, per the module's two-line fallback."""
    result = extract_label(_label_image(["IMIDACLOPRID", "17.8% SL"]))

    assert result.active_ingredient is not None
    assert "imidacloprid" in result.active_ingredient.lower()
    assert result.concentration == "17.8% SL"
    assert result.formulation == FORMULATION_CODES["SL"]


def test_extract_label_on_a_blank_image_is_a_normal_low_confidence_result() -> None:
    """A blank / unreadable photo is not an error — docs/DESIGN.md §9 has the
    caller compare ocr_confidence against OCR_FLOOR and offer a fallback."""
    blank = Image.new("RGB", (200, 200), "white")
    buf = io.BytesIO()
    blank.save(buf, format="PNG")

    result = extract_label(buf.getvalue())

    assert result.ocr_confidence == 0.0
    assert result.active_ingredient is None
    assert result.concentration is None
    assert result.formulation is None


def test_extract_label_rejects_undecodable_input() -> None:
    """Garbage bytes must fail loudly, not be silently 'read' as blank."""
    with pytest.raises(Exception):  # noqa: B017 - PIL raises varying types
        extract_label(b"not an image")


def test_extract_label_accepts_a_filesystem_path(tmp_path) -> None:
    path = tmp_path / "label.png"
    path.write_bytes(_label_image(["ACEPHATE 75% SP"]))

    result = extract_label(str(path))

    assert result.concentration == "75% SP"
    assert result.formulation == FORMULATION_CODES["SP"]
