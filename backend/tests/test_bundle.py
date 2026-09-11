"""compile_bundle() -- covers only the image-URL fix added when merging
Thaariha's delivery (app/intelligence/bundle.py), not the full bundle
shaping. That function is hers, reviewed and delivered with a known gap
(BundleImage.url hardcoded None); this pins the fix -- real URLs resolved
through presigned_get_url(), one bad object_key falling back to url=None
for that image only rather than failing the whole bundle.
"""

from __future__ import annotations

import uuid
from datetime import UTC, datetime

from app.contracts.enums import AssetKind, Crop, ProblemStatus, ProblemType
from app.core.models import Asset, Farm, Problem
from app.intelligence.bundle import compile_bundle


def _farm() -> Farm:
    return Farm(
        id=uuid.uuid4(), farmer_id=uuid.uuid4(), crop=Crop.PADDY, variety="Indrayani",
        growth_stage="tillering", region="Nashik", location="SRID=4326;POINT(0 0)",
    )


def _problem(farm: Farm) -> Problem:
    return Problem(
        id=uuid.uuid4(), farm_id=farm.id, problem_type=ProblemType.DISEASE,
        status=ProblemStatus.OPEN, opened_at=datetime.now(UTC),
    )


def _image(object_key: str) -> Asset:
    return Asset(
        id=uuid.uuid4(), kind=AssetKind.IMAGE, content_type="image/jpeg",
        object_key=object_key, created_at=datetime.now(UTC),
    )


def test_a_real_object_key_resolves_to_a_real_url() -> None:
    farm = _farm()
    problem = _problem(farm)
    image = _image("image/real-key.jpg")

    bundle = compile_bundle(
        case_id=uuid.uuid4(), status="open", farm=farm, problem=problem,
        diagnosis=None, observations=[], images=[image], label_checks=[], followups=[],
    )

    assert len(bundle.images) == 1
    assert bundle.images[0].url is not None
    assert "image/real-key.jpg" in bundle.images[0].url


def test_an_empty_object_key_falls_back_to_none_for_that_image_only() -> None:
    """The defensive case: presigned_get_url() raises ValueError on an empty
    key. compile_bundle() must not propagate that -- one bad row should not
    take the whole bundle down for an agronomist who still needs to see
    every other photo, observation and verdict on the case."""
    farm = _farm()
    problem = _problem(farm)
    good = _image("image/real-key.jpg")
    bad = _image("")

    bundle = compile_bundle(
        case_id=uuid.uuid4(), status="open", farm=farm, problem=problem,
        diagnosis=None, observations=[], images=[good, bad], label_checks=[], followups=[],
    )

    urls = {img.asset_id: img.url for img in bundle.images}
    assert urls[good.id] is not None
    assert urls[bad.id] is None
