"""Advisory pipeline (F7) — retrieval, grounded composition, structural validation.

OWNER: Thaariha. Spec: docs/DESIGN.md §8, docs/API_CONTRACT.md §8.

    query -> to_embedding_text() -> embed (BGE-m3) -> pgvector search
          -> relevance below RAG_THRESHOLD? -> retrieved:false, STOP
          -> LLM composes into the fixed schema, grounded on retrieved chunks
          -> validate: ladder ordered, chemical last, citations present
          -> persist Advisory

The validation step is not optional. A ladder with a chemical rung first is
rejected and recomposed, not shipped. Structural guarantees enforced only by
prompt wording are not guarantees.

The Devanagari trap (docs/DESIGN.md §8): any normalisation that strips non-ASCII
gives a Marathi query a zero vector, a degenerate similarity score, and confident
fabricated advice past the threshold. This has bitten this codebase before.
`embed()` below does no translation or normalisation of its own — the caller
must already have run the query through `voice.embedding_text.to_embedding_text()`
(Shruthi's, which does the translate-then-normalise-then-glossary-pin dance)
before this module ever sees it.

GATED AS ONE UNIT. `embed()` and `compose()` both refuse (loudly, not
silently) when `settings.llm_enabled` is false — the same flag, not a fourth
one (docs/DESIGN.md §12's three feature flags are exhaustive). This mirrors
vision/classifier.py's stub property: with the flag off, `gate.decide()`
fails closed on `retrieval_score is None` (its own docstring), so `advise` is
unreachable and neither function is ever called by the intended
orchestration. A caller reaching them anyway is a caller bug, not a
condition to render — see StubComposerLLM's docstring
(app/voice/providers.py) for the fuller reasoning.

CHEMICAL GROUNDING, the harder half of docs/DESIGN.md §8's "resolve against
registered_use at composition time" rule. The LLM is never trusted to state a
dosage, PHI or re-entry period — it may only *select* a chemical rung by
`product_id` from the exact candidate list this module hands it
(`advisory_use_rows`, which the caller builds via
`registered_use.for_advisory(session, target, crop)` — see that function's
own docstring for why it is already filtered to complete rows). Once
selected, the rung's `action`/`dosage`/`phi_days`/`reentry_hours` are
overwritten from the database row, never from whatever the model said. An
LLM inventing a product name, a dose, or a PHI is therefore structurally
impossible in the shipped output, not merely discouraged by the prompt.
"""

from __future__ import annotations

import json
import logging
import re
import threading
from dataclasses import dataclass
from datetime import date

from app.config import settings
from app.contracts.enums import LADDER_TIER_ORDER, LadderTier
from app.core.services.corpus import CorpusChunk
from app.core.services.registered_use import RegisteredUseRow
from app.voice.providers import ComposerLLM, get_composer_llm

log = logging.getLogger("bhoomi.intelligence")

EMBEDDING_MODEL_NAME = "BAAI/bge-m3"
EMBEDDING_DIM = 1024
"""Matches CorpusDoc.embedding's Vector(1024) column (migration 0009)."""

# ---------------------------------------------------------------------------
# embed() — in-process BGE-m3, lazily loaded once per process.
# ---------------------------------------------------------------------------

_embedding_model_lock = threading.Lock()
_embedding_model_instance = None


def _get_embedding_model():
    """Load BGE-m3 once, lazily. Thread-safe double-checked init — same
    pattern as vision/classifier.py's `_get_model()`."""
    global _embedding_model_instance
    if _embedding_model_instance is None:
        with _embedding_model_lock:
            if _embedding_model_instance is None:
                from sentence_transformers import SentenceTransformer

                _embedding_model_instance = SentenceTransformer(EMBEDDING_MODEL_NAME)
    return _embedding_model_instance


def embed(text: str) -> list[float]:
    """BGE-m3 embedding of `text`. docs/DESIGN.md §8.

    Args:
        text: English, already through `voice.embedding_text.to_embedding_text()`
            — see the module docstring's Devanagari-trap note. This function
            does no translation or normalisation of its own.

    Returns:
        A 1024-dim vector, normalised (cosine similarity is what
        `corpus.search()`'s `<=>` operator computes against it).

    Raises:
        RuntimeError: `settings.llm_enabled` is false. See the module
            docstring's GATED AS ONE UNIT note — this is a caller bug, not a
            farmer-facing condition.
    """
    if not settings.llm_enabled:
        raise RuntimeError(
            "intelligence.rag.embed() called while settings.llm_enabled is "
            "false. The retrieval pipeline is gated as one unit — see the "
            "module docstring's GATED AS ONE UNIT note."
        )
    model = _get_embedding_model()
    vector = model.encode(text, normalize_embeddings=True)
    return vector.tolist()


# ---------------------------------------------------------------------------
# compose()'s return shape. Mirrors core/schemas/problems.py's
# LadderRungOut/CitationOut/AdvisoryOut, minus the DB-generated `id`/
# `created_at` fields those carry — compose() runs before the Advisory row
# exists, so it cannot populate either. The caller (the advisory router,
# core/) persists this and maps it onto AdvisoryOut for the response.
# ---------------------------------------------------------------------------


@dataclass(frozen=True, slots=True)
class ComposedLadderRung:
    tier: LadderTier
    action: str
    dosage: str | None = None
    phi_days: int | None = None
    reentry_hours: int | None = None


@dataclass(frozen=True, slots=True)
class ComposedCitation:
    doc_id: str | None
    title: str
    reviewed_on: str | None


@dataclass(frozen=True, slots=True)
class ComposedAdvisory:
    possible_issue: str
    what_to_check: str
    what_to_avoid: str
    ladder: list[ComposedLadderRung]
    expert_trigger: str | None
    citations: list[ComposedCitation]


# ---------------------------------------------------------------------------
# The endorsement-language ban. docs/API_CONTRACT.md §9's rule for verdict
# copy ("no 'safe', 'approved', 'you can use'") is enforced by VERDICT_MESSAGES
# being a fixed string table — there is no table here, because the ladder's
# cultural/biological text and possible_issue/what_to_check/what_to_avoid are
# genuinely composed prose. So the same three phrases are checked directly
# against the LLM's output, and a hit fails the whole composition (see
# _finalize()) rather than being silently stripped — scrubbing safety-adjacent
# language automatically is its own risk; refusing and escalating is not.
# ---------------------------------------------------------------------------

_BANNED_ENDORSEMENT_PHRASES = ("safe", "approved", "you can use")


def _contains_endorsement_language(text: str) -> bool:
    lowered = text.lower()
    return any(phrase in lowered for phrase in _BANNED_ENDORSEMENT_PHRASES)


_SYSTEM_PROMPT = """\
You are Bhoomi's advisory composer for Indian smallholder farmers (paddy, \
cotton, soybean, jowar). You write a short, practical crop-problem advisory.

RULES, followed exactly:
1. Ground every claim ONLY in the SOURCE MATERIAL given to you. Never state a \
fact that is not in it.
2. Reply with JSON ONLY — no markdown fences, no prose outside the JSON object.
3. The JSON schema is exactly:
   {"possible_issue": str, "what_to_check": str, "what_to_avoid": str,
    "ladder": [ {"tier": "cultural", "action": str} | \
{"tier": "biological", "action": str} | \
{"tier": "chemical", "product_id": str} , ... ],
    "expert_trigger": str}
4. `ladder` has at most one rung per tier, in this exact order when present: \
cultural, then biological, then chemical. The chemical rung, if you include \
one, is ALWAYS last.
5. A "chemical" rung may ONLY reference a product_id from the REGISTERED \
PRODUCTS list below. Never invent a product, an active ingredient, a dose, or \
a pre-harvest interval. If no listed product fits this problem, omit the \
chemical rung entirely — a ladder with only cultural/biological rungs is a \
complete, valid answer.
6. Never write the words "safe", "approved", or "you can use" about any \
product or action. State facts; do not endorse.
"""


def _build_user_prompt(
    query_text: str,
    crop: str,
    target: str,
    retrieved_docs: list[CorpusChunk],
    advisory_use_rows: list[RegisteredUseRow],
) -> str:
    source_material = "\n\n".join(
        f"[{i}] ({chunk.title}, source: {chunk.source})\n{chunk.content}"
        for i, chunk in enumerate(retrieved_docs, start=1)
    )
    if advisory_use_rows:
        products = "\n".join(
            f"- product_id={row.id}: {row.active_ingredient} ({row.pesticide_class})"
            for row in advisory_use_rows
        )
    else:
        products = "(none registered for this crop/target — omit the chemical rung.)"

    return (
        f"CROP: {crop}\nTARGET: {target}\nFARMER QUERY: {query_text}\n\n"
        f"SOURCE MATERIAL:\n{source_material}\n\n"
        f"REGISTERED PRODUCTS (chemical rung candidates):\n{products}"
    )


_JSON_FENCE_RE = re.compile(r"^```(?:json)?\s*|\s*```$", re.MULTILINE)


def _parse_llm_json(raw: str) -> dict | None:
    """LLMs sometimes wrap JSON in a markdown fence despite rule 2 above.
    Strip it before parsing; anything else that fails to parse is a genuine
    malformed reply, not something this function guesses at."""
    text = _JSON_FENCE_RE.sub("", raw).strip()
    try:
        parsed = json.loads(text)
    except (json.JSONDecodeError, TypeError):
        return None
    return parsed if isinstance(parsed, dict) else None


def _citations_from(retrieved_docs: list[CorpusChunk]) -> list[ComposedCitation]:
    seen: set[str] = set()
    citations: list[ComposedCitation] = []
    for chunk in retrieved_docs:
        if chunk.doc_id in seen:
            continue
        seen.add(chunk.doc_id)
        reviewed: date | None = chunk.reviewed_on
        citations.append(
            ComposedCitation(
                doc_id=chunk.doc_id,
                title=chunk.title,
                reviewed_on=reviewed.isoformat() if reviewed else None,
            )
        )
    return citations


def _finalize(
    parsed: dict,
    products_by_id: dict[str, RegisteredUseRow],
    retrieved_docs: list[CorpusChunk],
    days_to_harvest: int | None,
) -> ComposedAdvisory | None:
    """Validate + ground one LLM reply. `None` means "reject" — the caller
    either retries once or gives up entirely; this function never patches a
    bad reply into a shippable one (docs/DESIGN.md §8: "rejected and
    recomposed, not shipped")."""
    possible_issue = parsed.get("possible_issue")
    what_to_check = parsed.get("what_to_check")
    what_to_avoid = parsed.get("what_to_avoid")
    expert_trigger = parsed.get("expert_trigger")
    raw_ladder = parsed.get("ladder")

    if not (
        isinstance(possible_issue, str)
        and possible_issue
        and isinstance(what_to_check, str)
        and what_to_check
        and isinstance(what_to_avoid, str)
        and what_to_avoid
        and isinstance(raw_ladder, list)
    ):
        return None

    for text in (possible_issue, what_to_check, what_to_avoid, expert_trigger or ""):
        if isinstance(text, str) and _contains_endorsement_language(text):
            return None

    rungs: list[ComposedLadderRung] = []
    seen_tiers: set[str] = set()
    for entry in raw_ladder:
        if not isinstance(entry, dict):
            return None
        tier = entry.get("tier")
        if tier not in {t.value for t in LadderTier} or tier in seen_tiers:
            return None
        seen_tiers.add(tier)

        if tier == LadderTier.CHEMICAL.value:
            row = products_by_id.get(str(entry.get("product_id")))
            if row is None:
                # Not one of the offered candidates -- DROP the rung entirely
                # rather than shipping it (docs/DESIGN.md §8), whether that's
                # because the model invented an id or because a real
                # candidate later failed a check we haven't reached yet.
                continue
            if days_to_harvest is not None and days_to_harvest < row.phi_days:
                continue  # DROP: PHI_CONFLICT, same rule labelcheck.py applies
            rungs.append(
                ComposedLadderRung(
                    tier=LadderTier.CHEMICAL,
                    action=row.active_ingredient,
                    dosage=row.dosage_text,
                    phi_days=row.phi_days,
                    reentry_hours=row.reentry_hours,
                )
            )
        else:
            action = entry.get("action")
            if not isinstance(action, str) or not action or _contains_endorsement_language(action):
                return None
            rungs.append(ComposedLadderRung(tier=LadderTier(tier), action=action))

    if not rungs:
        # An advisory with an empty ladder (every rung dropped, or the model
        # produced none) is not a shippable answer -- reject rather than
        # ship "here is your problem, and no action at all".
        return None

    tier_positions = [LADDER_TIER_ORDER.index(rung.tier) for rung in rungs]
    if tier_positions != sorted(tier_positions):
        return None  # chemical-not-last (or any other ordering violation)

    citations = _citations_from(retrieved_docs)
    if not citations:
        return None

    return ComposedAdvisory(
        possible_issue=possible_issue,
        what_to_check=what_to_check,
        what_to_avoid=what_to_avoid,
        ladder=rungs,
        expert_trigger=expert_trigger if isinstance(expert_trigger, str) else None,
        citations=citations,
    )


async def compose(
    query_text: str,
    crop: str,
    target: str,
    retrieved_docs: list[CorpusChunk],
    advisory_use_rows: list[RegisteredUseRow],
    days_to_harvest: int | None,
    llm: ComposerLLM | None = None,
) -> ComposedAdvisory | None:
    """Compose an advisory strictly grounded on `retrieved_docs`, with the
    chemical rung (if any) grounded on `advisory_use_rows`.

    Called only after the gate returns `advise`. Never called speculatively.

    Args:
        query_text: the farmer's query (already embedding-text-normalised by
            the caller, but passed here as plain text for the LLM prompt —
            embed() and compose() read the same text at two different
            stages of the pipeline).
        crop, target: the problem's crop and target label.
        retrieved_docs: `corpus.search()`'s results for this crop/target,
            already past the RAG_THRESHOLD relevance check (the gate's job,
            not this function's) — must be non-empty, since citations are
            built from it and an advisory cannot ship with none.
        advisory_use_rows: `registered_use.for_advisory(session, target, crop)`'s
            result — the ONLY chemical rungs this call may select from. See
            the module docstring's CHEMICAL GROUNDING note.
        days_to_harvest: farmer-supplied; a candidate whose `phi_days`
            exceeds it is dropped from the ladder, same PHI rule
            labelcheck.py applies.
        llm: injected for tests; defaults to
            `voice.providers.get_composer_llm()`.

    Returns:
        A `ComposedAdvisory`, or `None` if no valid, grounded advisory could
        be produced after one corrective retry — the caller must treat this
        exactly like a `NO_RELEVANT_SOURCE` gate outcome (escalate, no
        fabrication), per docs/API_CONTRACT.md §8's "not retrieved" response.

    Raises:
        RuntimeError: `settings.llm_enabled` is false. See the module
            docstring's GATED AS ONE UNIT note.
    """
    if not settings.llm_enabled:
        raise RuntimeError(
            "intelligence.rag.compose() called while settings.llm_enabled is "
            "false. The retrieval pipeline is gated as one unit — see the "
            "module docstring's GATED AS ONE UNIT note."
        )
    if not retrieved_docs:
        # The caller should never reach compose() with nothing retrieved
        # (the gate's RAG_THRESHOLD check precedes it) -- fail closed rather
        # than compose an unsourced advisory if it happens anyway.
        return None

    llm = llm or get_composer_llm()
    products_by_id = {row.id: row for row in advisory_use_rows}
    user_prompt = _build_user_prompt(query_text, crop, target, retrieved_docs, advisory_use_rows)

    raw = await llm.complete(_SYSTEM_PROMPT, user_prompt)
    parsed = _parse_llm_json(raw)
    if parsed is not None:
        result = _finalize(parsed, products_by_id, retrieved_docs, days_to_harvest)
        if result is not None:
            return result

    # docs/DESIGN.md §8: "the response is rejected and recomposed, not
    # shipped." One corrective retry, naming what a reply must avoid this
    # time, then give up rather than loop indefinitely against a model that
    # keeps failing the same check.
    log.warning(
        "intelligence.rag.compose(): first reply invalid (malformed JSON or "
        "a structural/grounding violation) for crop=%s target=%s -- retrying once",
        crop,
        target,
    )
    raw = await llm.complete(
        _SYSTEM_PROMPT,
        user_prompt
        + "\n\nYour previous reply was rejected: it was not valid JSON, used "
        "banned endorsement language, referenced a product_id not in the "
        "REGISTERED PRODUCTS list, or put the chemical rung somewhere other "
        "than last. Follow every rule exactly this time.",
    )
    parsed = _parse_llm_json(raw)
    if parsed is None:
        log.error(
            "intelligence.rag.compose(): second reply also invalid for "
            "crop=%s target=%s -- giving up, caller must escalate",
            crop,
            target,
        )
        return None
    return _finalize(parsed, products_by_id, retrieved_docs, days_to_harvest)
