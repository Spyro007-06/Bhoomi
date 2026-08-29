"""Bounded paddy classifier. Returns contract C1.

OWNER: Suchit. Spec: docs/DESIGN.md §3 (module boundaries), §4 (C1), §12 (flags).

`classify()` is the only entry point. It dispatches on `settings.vision_model`:

  real  -> the PyTorch classifier, served in-process (Suchit, Phase 2+)
  stub  -> the deliberately-inert distribution below

The stub is the one function in another owner's module that Phase 0 implements,
because a missing stub blocks everyone and a *bad* stub loses the demo.

The real path loads `weights/bhoomi_vision_v1.pth` + `.json` once, lazily, into
a module-level singleton (`_get_model()`). It never reads gate thresholds
(GATE/FLOOR/MARGIN live in intelligence's gate, not here) and never hardcodes
label strings — the JSON's `labels` list is the sole source of class-index
order, so a retrain that changes label order or count needs no code change
here.
"""

from __future__ import annotations

import io
import json
import logging
import threading
from pathlib import Path

from app.config import OUT_OF_SCOPE_MAX_SOFTMAX, settings
from app.contracts.vision import Prediction, TopK

log = logging.getLogger("bhoomi.vision")

STUB_MODEL_VERSION = "stub-0"

WEIGHTS_DIR = Path(__file__).resolve().parent / "weights"
WEIGHTS_PATH = WEIGHTS_DIR / "bhoomi_vision_v1.pth"
METADATA_PATH = WEIGHTS_DIR / "bhoomi_vision_v1.json"

# ImageNet normalization. bhoomi_vision_v1.json carries no mean/std of its own
# (only img_size) — this matches timm's own default_cfg for efficientnet_b0
# (verified against the installed timm build), not a value read from the
# artifact. If a retrain ever writes normalization stats into the JSON, prefer
# those over this constant.
_IMAGENET_MEAN = (0.485, 0.456, 0.406)
_IMAGENET_STD = (0.229, 0.224, 0.225)

# ---------------------------------------------------------------------------
# The stub distribution. docs/DESIGN.md §12 and the Phase 0 brief:
#
#   "It must NOT hash the image, compare it to anything, or produce
#    input-dependent output that looks like a real prediction."
#
# So this is a constant. It does not read a single byte of the image.
#
# The values are chosen so the stub cannot produce advice under any gate path:
# top-1 is 0.34, below FLOOR (0.45), so the gate returns escalate/BELOW_FLOOR.
# The top1-top2 gap is 0.01, far below MARGIN, so even if the floor check were
# reordered the stub would land in clarify, never in advise. A stub physically
# incapable of composing an advisory is the property worth having here.
# ---------------------------------------------------------------------------
STUB_DISTRIBUTION: tuple[tuple[str, float], ...] = (
    ("paddy_blast", 0.34),
    ("paddy_brown_spot", 0.33),
    ("paddy_bacterial_leaf_blight", 0.33),
)


def _stub_topk() -> TopK:
    return TopK(
        predictions=[Prediction(label=lbl, confidence=c) for lbl, c in STUB_DISTRIBUTION],
        out_of_scope=False,
        model_version=STUB_MODEL_VERSION,
        is_stub=True,
    )


class _VisionModel:
    """Lazily-loaded singleton wrapping the trained EfficientNet-B0 checkpoint.

    Everything class-index-order or scale related (`labels`, `model_version`,
    `img_size`, `temperature`) comes from `bhoomi_vision_v1.json` at load time —
    nothing here hardcodes a label string or a class count.
    """

    def __init__(self) -> None:
        import timm
        import torch
        from torchvision import transforms

        if not METADATA_PATH.exists():
            raise FileNotFoundError(
                f"vision metadata not found at {METADATA_PATH} — expected "
                "alongside the .pth checkpoint."
            )
        if not WEIGHTS_PATH.exists():
            raise FileNotFoundError(
                f"vision weights not found at {WEIGHTS_PATH}."
            )

        meta = json.loads(METADATA_PATH.read_text(encoding="utf-8"))
        self.labels: list[str] = meta["labels"]
        self.model_version: str = meta["model_version"]
        self.model_name: str = meta["model_name"]
        self.img_size: int = meta["img_size"]
        self.temperature: float = meta["temperature"]

        if self.model_name != "efficientnet_b0":
            raise NotImplementedError(
                f"vision metadata names model_name={self.model_name!r}, but only "
                "efficientnet_b0 is wired up. Update _VisionModel if the "
                "architecture changed."
            )

        # The checkpoint's key layout (conv_stem/bn1/blocks.N.M/conv_head/bn2/
        # classifier) is timm's EfficientNet-B0, not torchvision's — verified by
        # loading it here with strict=True. Do not swap this for
        # torchvision.models.efficientnet_b0; the state dict keys don't match.
        model = timm.create_model("efficientnet_b0", pretrained=False, num_classes=len(self.labels))

        state_dict = torch.load(WEIGHTS_PATH, map_location="cpu", weights_only=True)
        if isinstance(state_dict, dict) and "state_dict" in state_dict:
            state_dict = state_dict["state_dict"]
        model.load_state_dict(state_dict, strict=True)
        model.eval()

        self.device = torch.device("cpu")
        model.to(self.device)
        self.model = model

        self.transform = transforms.Compose(
            [
                transforms.Resize(self.img_size),
                transforms.CenterCrop(self.img_size),
                transforms.ToTensor(),
                transforms.Normalize(mean=_IMAGENET_MEAN, std=_IMAGENET_STD),
            ]
        )

        log.info(
            "vision real model loaded: %s v=%s labels=%s img_size=%d temperature=%.4f",
            self.model_name,
            self.model_version,
            self.labels,
            self.img_size,
            self.temperature,
        )

    def predict(self, image_bytes: bytes) -> TopK:
        import torch
        from PIL import Image

        with Image.open(io.BytesIO(image_bytes)) as img:
            img = img.convert("RGB")
            tensor = self.transform(img).unsqueeze(0).to(self.device)

        with torch.no_grad():
            logits = self.model(tensor)[0]
            calibrated = logits / self.temperature
            probs = torch.softmax(calibrated, dim=0)

        ranked = sorted(
            zip(self.labels, (p.item() for p in probs), strict=True),
            key=lambda pair: pair[1],
            reverse=True,
        )
        top3 = ranked[:3]
        max_softmax = top3[0][1]

        return TopK(
            predictions=[Prediction(label=lbl, confidence=c) for lbl, c in top3],
            out_of_scope=max_softmax < OUT_OF_SCOPE_MAX_SOFTMAX,
            model_version=self.model_version,
            is_stub=False,
        )


_model_lock = threading.Lock()
_model_instance: _VisionModel | None = None


def _get_model() -> _VisionModel:
    """Load the real model once, lazily. Thread-safe double-checked init."""
    global _model_instance
    if _model_instance is None:
        with _model_lock:
            if _model_instance is None:
                _model_instance = _VisionModel()
    return _model_instance


def warmup() -> None:
    """Force-load the real model, if configured, so the first request doesn't
    pay the load cost. Call from app startup (docs/DESIGN.md §12)."""
    if settings.vision_model == "real":
        _get_model()


def _load_image_bytes(image: bytes | str) -> bytes:
    """`image` is either raw bytes, or a filesystem path to read them from.

    Fetching by object/asset key is the router/deps layer's job (it owns
    storage), not vision's — this module only ever sees bytes it's handed, or
    a local path for direct/offline use.
    """
    if isinstance(image, bytes):
        return image
    return Path(image).read_bytes()


def classify(image: bytes | str) -> TopK:
    """Classify a paddy leaf image into the bounded label set.

    Args:
        image: image bytes, or a filesystem path to read them from.

    Returns:
        TopK — exactly 3 predictions, descending, with `is_stub` set truthfully.

    Raises:
        FileNotFoundError: VISION_MODEL=real but the checkpoint/metadata are
            missing.
        Exception: (from PIL/torch) if the image cannot be decoded. This is
            deliberate — a garbage input must fail loudly, not get silently
            classified.
    """
    if settings.vision_model == "stub":
        log.warning(
            "vision.classify() served by STUB — fixed distribution, image not read. "
            "is_stub=true; clients must show a stub banner. docs/DESIGN.md §12."
        )
        return _stub_topk()

    model = _get_model()
    image_bytes = _load_image_bytes(image)
    return model.predict(image_bytes)
