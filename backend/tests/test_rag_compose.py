"""compose() -- the validation/grounding logic in app/intelligence/rag.py.

Exercises the pipeline with a fake ComposerLLM (dependency-injected via the
`llm` parameter), not a live Sarvam call -- these are unit tests of the
structural guarantees (chemical last, chemical grounded on a real
registered_use row, endorsement language rejected, an invented product_id
dropped, PHI_CONFLICT drops the rung), not an integration test of the
provider. See app/voice/providers.py's LiveComposerLLM docstring for why a
live call is unverified in this environment.
"""

from __future__ import annotations

import json
from datetime import date

import pytest

from app.contracts.enums import LadderTier
from app.core.services.corpus import CorpusChunk
from app.core.services.registered_use import RegisteredUseRow
from app.intelligence import rag


class FakeComposerLLM:
    """Returns each of `replies` in order, one per `complete()` call."""

    def __init__(self, replies: list[str]) -> None:
        self._replies = list(replies)
        self.calls: list[tuple[str, str]] = []

    async def complete(self, system_prompt: str, user_prompt: str) -> str:
        self.calls.append((system_prompt, user_prompt))
        return self._replies.pop(0)


def _chunk(**overrides) -> CorpusChunk:
    defaults = dict(
        id="c_1", doc_id="doc_1", title="Paddy Blast", source="TNAU Agritech Portal",
        content="Diamond-shaped lesions with grey centres.", authoritative=True,
        reviewed_on=date(2026, 8, 31),
    )
    defaults.update(overrides)
    return CorpusChunk(**defaults)


def _row(**overrides) -> RegisteredUseRow:
    defaults = dict(
        id="ru_1", active_ingredient="Tricyclazole 75 WP", crop="paddy",
        target="paddy_blast", pesticide_class="fungicide",
        dosage_text="0.6 g per litre", phi_days=30, reentry_hours=24,
        source="CIB&RC", source_dated=date(2020, 1, 1), last_verified=None,
        restriction_note=None,
    )
    defaults.update(overrides)
    return RegisteredUseRow(**defaults)


def _valid_reply(**ladder_overrides) -> str:
    ladder = ladder_overrides.pop("ladder", None) or [
        {"tier": "cultural", "action": "Drain the field and let it dry for 48 hours."},
        {"tier": "chemical", "product_id": "ru_1"},
    ]
    body = {
        "possible_issue": "Early blast.",
        "what_to_check": "Diamond-shaped lesions with grey centres.",
        "what_to_avoid": "Do not top-dress nitrogen now.",
        "ladder": ladder,
        "expert_trigger": "If lesions spread within 3 days, escalate.",
    }
    body.update(ladder_overrides)
    return json.dumps(body)


@pytest.fixture(autouse=True)
def _llm_enabled(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(rag.settings, "llm_enabled", True)


async def test_valid_reply_grounds_the_chemical_rung_on_the_db_row() -> None:
    """The LLM only ever names a product_id -- dosage/phi/reentry/action text
    in the shipped rung come from the RegisteredUseRow, never the model."""
    llm = FakeComposerLLM([_valid_reply()])

    result = await rag.compose(
        "leaves have grey-centred lesions", "paddy", "paddy_blast",
        retrieved_docs=[_chunk()], advisory_use_rows=[_row()],
        days_to_harvest=60, llm=llm,
    )

    assert result is not None
    assert len(llm.calls) == 1
    assert [r.tier for r in result.ladder] == [LadderTier.CULTURAL, LadderTier.CHEMICAL]
    chemical = result.ladder[-1]
    assert chemical.action == "Tricyclazole 75 WP"
    assert chemical.dosage == "0.6 g per litre"
    assert chemical.phi_days == 30
    assert chemical.reentry_hours == 24
    assert result.citations and result.citations[0].doc_id == "doc_1"


async def test_chemical_rung_not_last_is_rejected_and_retried() -> None:
    """docs/DESIGN.md §8: rejected and recomposed, not shipped."""
    bad = _valid_reply(
        ladder=[
            {"tier": "chemical", "product_id": "ru_1"},
            {"tier": "cultural", "action": "Drain the field."},
        ]
    )
    llm = FakeComposerLLM([bad, _valid_reply()])

    result = await rag.compose(
        "query", "paddy", "paddy_blast", retrieved_docs=[_chunk()],
        advisory_use_rows=[_row()], days_to_harvest=None, llm=llm,
    )

    assert len(llm.calls) == 2  # one retry happened
    assert result is not None
    assert result.ladder[-1].tier == LadderTier.CHEMICAL


async def test_both_replies_invalid_returns_none() -> None:
    llm = FakeComposerLLM(["not json at all", "still not json"])

    result = await rag.compose(
        "query", "paddy", "paddy_blast", retrieved_docs=[_chunk()],
        advisory_use_rows=[_row()], days_to_harvest=None, llm=llm,
    )

    assert result is None
    assert len(llm.calls) == 2


async def test_endorsement_language_is_rejected() -> None:
    bad = _valid_reply()
    parsed = json.loads(bad)
    parsed["what_to_avoid"] = "This product is safe to use."
    llm = FakeComposerLLM([json.dumps(parsed), _valid_reply()])

    result = await rag.compose(
        "query", "paddy", "paddy_blast", retrieved_docs=[_chunk()],
        advisory_use_rows=[_row()], days_to_harvest=None, llm=llm,
    )

    assert len(llm.calls) == 2
    assert result is not None  # the retry's clean reply ships


async def test_invented_product_id_drops_the_chemical_rung_not_the_whole_ladder() -> None:
    reply = _valid_reply(
        ladder=[
            {"tier": "cultural", "action": "Drain the field."},
            {"tier": "chemical", "product_id": "not_a_real_id"},
        ]
    )
    llm = FakeComposerLLM([reply])

    result = await rag.compose(
        "query", "paddy", "paddy_blast", retrieved_docs=[_chunk()],
        advisory_use_rows=[_row()], days_to_harvest=None, llm=llm,
    )

    assert result is not None
    assert len(llm.calls) == 1
    assert [r.tier for r in result.ladder] == [LadderTier.CULTURAL]


async def test_phi_conflict_drops_the_chemical_rung() -> None:
    """days_to_harvest below the row's phi_days drops the rung -- same rule
    labelcheck.py's PHI_CONFLICT branch applies."""
    reply = _valid_reply(
        ladder=[
            {"tier": "cultural", "action": "Drain the field."},
            {"tier": "chemical", "product_id": "ru_1"},
        ]
    )
    llm = FakeComposerLLM([reply])

    result = await rag.compose(
        "query", "paddy", "paddy_blast", retrieved_docs=[_chunk()],
        advisory_use_rows=[_row(phi_days=30)], days_to_harvest=5, llm=llm,
    )

    assert result is not None
    assert [r.tier for r in result.ladder] == [LadderTier.CULTURAL]


async def test_empty_ladder_after_drops_is_rejected() -> None:
    """If the only rung was chemical and it gets dropped, the whole
    composition is rejected -- an advisory cannot ship with no action at all."""
    reply = _valid_reply(ladder=[{"tier": "chemical", "product_id": "not_real"}])
    llm = FakeComposerLLM([reply, reply])

    result = await rag.compose(
        "query", "paddy", "paddy_blast", retrieved_docs=[_chunk()],
        advisory_use_rows=[_row()], days_to_harvest=None, llm=llm,
    )

    assert result is None
    assert len(llm.calls) == 2


async def test_no_retrieved_docs_returns_none_without_calling_the_llm() -> None:
    llm = FakeComposerLLM([])

    result = await rag.compose(
        "query", "paddy", "paddy_blast", retrieved_docs=[],
        advisory_use_rows=[_row()], days_to_harvest=None, llm=llm,
    )

    assert result is None
    assert llm.calls == []


def test_embed_and_compose_refuse_when_llm_disabled(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(rag.settings, "llm_enabled", False)

    with pytest.raises(RuntimeError):
        rag.embed("some text")


def test_embed_calls_the_model_and_returns_a_list(monkeypatch: pytest.MonkeyPatch) -> None:
    """BGE-m3 itself is never downloaded in this test -- _get_embedding_model
    is swapped for a fake that mimics SentenceTransformer.encode()'s shape
    (a numpy-like object with .tolist())."""

    class _FakeVector:
        def tolist(self) -> list[float]:
            return [0.1, 0.2, 0.3]

    class _FakeModel:
        def encode(self, text: str, normalize_embeddings: bool) -> _FakeVector:
            assert normalize_embeddings is True
            return _FakeVector()

    monkeypatch.setattr(rag, "_get_embedding_model", lambda: _FakeModel())

    assert rag.embed("blast lesions") == [0.1, 0.2, 0.3]


async def test_compose_refuses_when_llm_disabled(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(rag.settings, "llm_enabled", False)

    with pytest.raises(RuntimeError):
        await rag.compose(
            "query", "paddy", "paddy_blast", retrieved_docs=[_chunk()],
            advisory_use_rows=[], days_to_harvest=None, llm=FakeComposerLLM([]),
        )
