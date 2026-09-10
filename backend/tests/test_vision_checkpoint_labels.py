"""Integration test for the checkpoint-label-namespace fix.

Regression target: the checkpoint's metadata (bhoomi_vision_v1.json) declares
v2 label names ("blast", "brown_spot", ...); TargetLabel is v3-namespaced
("paddy_blast", ...). Before app/vision/classifier.py's
CHECKPOINT_LABEL_ALIASES translation, a real inference call returned v2
names in Prediction.label, and the first downstream TargetLabel(...)
construction raised.

This drives the real model (VISION_MODEL=real, no fixture) end to end and
asserts every returned label is a valid v3 TargetLabel -- the exact
construction that used to blow up.

Not a fixture-image asset: a real photograph is what actually exercises this
(see the task's pasted live-HTTP verification for that), but committing a
scraped photo into the repo as a permanent test fixture raises licensing
questions this change has no business answering. The synthetic image below
is enough to drive real inference through the model and prove the label
translation holds -- it is not a substitute for the real-photo verification,
which was done live and is not re-derived here.
"""

from __future__ import annotations

import io

import pytest
from PIL import Image, ImageDraw

from app.config import settings
from app.contracts.enums import TargetLabel
from app.vision.classifier import CHECKPOINT_LABEL_ALIASES, classify


def _leaf_like_image_bytes(size: int = 224) -> bytes:
    """A green, textured, non-uniform image -- clears the vegetation-fraction
    pre-filter (docs: solid green already does, per
    tests/test_vision_out_of_scope.py) without being a solid color, closer to
    what a real leaf photo's pixel statistics look like than a flat fill."""
    img = Image.new("RGB", (size, size), color=(45, 110, 40))
    draw = ImageDraw.Draw(img)
    for i in range(0, size, 9):
        draw.line([(i, 0), (0, i)], fill=(70, 150, 60), width=2)
        draw.line([(size - 1, i), (i, size - 1)], fill=(30, 90, 35), width=2)
    draw.ellipse((size * 0.3, size * 0.3, size * 0.55, size * 0.5), fill=(120, 80, 30))
    buf = io.BytesIO()
    img.save(buf, format="JPEG")
    return buf.getvalue()


@pytest.fixture
def _force_real(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(settings, "vision_model", "real")


def test_real_classifier_returns_v3_namespaced_labels(_force_real: None) -> None:
    """The regression this fix targets: TargetLabel(top1.label) used to raise
    because the checkpoint's raw label names ("blast", ...) are not TargetLabel
    members. Prediction.label is now typed TargetLabel (contract C1), so this
    also proves the classifier's output validates against that type -- a v2
    name here would fail Pydantic validation before the test body even runs."""
    topk = classify(_leaf_like_image_bytes())

    assert topk.is_stub is False
    assert len(topk.predictions) == 3
    for prediction in topk.predictions:
        assert isinstance(prediction.label, TargetLabel)
        # The checkpoint is paddy-only (Step 0 finding): every label it can
        # produce is one of the four aliases wired in classifier.py.
        assert prediction.label in CHECKPOINT_LABEL_ALIASES.values()
        assert prediction.label.crop.value == "paddy"
