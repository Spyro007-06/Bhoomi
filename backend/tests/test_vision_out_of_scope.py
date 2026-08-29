"""The real classifier's out-of-scope detection.

Added after integration testing (2026-08-29) found that softmax confidence
alone does not reliably flag non-paddy photos: a photo of fabric scored 99.95%
confident on `blast`. See VISION_MIN_VEGETATION_FRACTION and
OUT_OF_SCOPE_MAX_SOFTMAX in app/config.py for the full story and known limits
of the fix below — this is a heuristic complement, not a trained rejection
class.
"""

from __future__ import annotations

import io

import pytest
from PIL import Image

from app.config import settings
from app.vision.classifier import _vegetation_fraction, classify


def _solid_image_bytes(rgb: tuple[int, int, int], size: int = 224) -> bytes:
    img = Image.new("RGB", (size, size), color=rgb)
    buf = io.BytesIO()
    img.save(buf, format="JPEG")
    return buf.getvalue()


def test_vegetation_fraction_high_on_green() -> None:
    """A solid green square should score high — this is the signal the
    real photos in integration testing (98% green) matched."""
    img = Image.new("RGB", (224, 224), color=(60, 140, 60))
    assert _vegetation_fraction(img) > 0.9


def test_vegetation_fraction_low_on_grey() -> None:
    """A solid grey square (stand-in for the fabric photo that scored
    0.0% vegetation and 99.95% confident `blast` during integration testing)
    should score at or near zero."""
    img = Image.new("RGB", (224, 224), color=(120, 120, 120))
    assert _vegetation_fraction(img) < 0.05


def test_vegetation_fraction_low_on_red() -> None:
    img = Image.new("RGB", (224, 224), color=(180, 30, 30))
    assert _vegetation_fraction(img) < 0.05


@pytest.fixture
def _force_real(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(settings, "vision_model", "real")


def test_real_path_flags_out_of_scope_on_non_vegetation_image(
    _force_real: None,
) -> None:
    """End-to-end: a solid grey image must come back out_of_scope=True even if
    the disease softmax lands confidently on some label — reproduces the
    integration-testing failure mode (bag-fabric photo, 99.95% confident
    `blast`, out_of_scope was False before this fix)."""
    topk = classify(_solid_image_bytes((120, 120, 120)))
    assert topk.out_of_scope is True
    assert topk.is_stub is False
