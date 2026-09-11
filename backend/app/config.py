"""Bhoomi v2 configuration — the single home for every tunable constant.

Owner: Shreekumar. Spec: docs/DESIGN.md §6, §11, §12.

RULE (docs/DESIGN.md §6): "Constants live here and nowhere else. A threshold
literal appearing in a second file is a bug." Import from this module. Do not
re-declare a threshold, a radius or a floor anywhere else in the tree.
"""

from __future__ import annotations

import os
from functools import lru_cache
from typing import Literal

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

# ---------------------------------------------------------------------------
# Gate thresholds — docs/DESIGN.md §6.
# These three carry the product's "never fabricate" guarantee. They are module
# constants rather than settings fields because the gate must not be tunable by
# whoever controls the environment at demo time.
# ---------------------------------------------------------------------------

GATE = 0.70
"""Top-1 confidence at or above this, and clear of the runner-up, → advise."""

FLOOR = 0.45
"""Top-1 confidence below this → never engage the farmer, escalate."""

MARGIN = 0.15
"""Minimum top1-top2 gap to call a prediction clear. Below → clarify."""

RAG_THRESHOLD = 0.60
"""Minimum retrieval relevance before an advisory may be composed."""

# ---------------------------------------------------------------------------
# Perception floors — docs/DESIGN.md §9, docs/API_CONTRACT.md §4, §9.
# Below these the system says it could not read/hear rather than guessing.
# ---------------------------------------------------------------------------

OCR_FLOOR = 0.60
"""Below this OCR confidence the label check returns OCR_UNREADABLE."""

ASR_FLOOR = 0.60
"""Below this ASR confidence parsed_intent is omitted and the client re-prompts."""

OUT_OF_SCOPE_MAX_SOFTMAX = float(os.environ.get("VISION_OOS_FLOOR", "0.35"))
"""Below this max-softmax the classifier declares `out_of_scope=True` on C1
(docs/DESIGN.md §4). Read once at import time from `VISION_OOS_FLOOR` — this is
deployment tuning for a perception floor, not a gate decision threshold, so it
is exempt from the "module constant, not a settings field" rule that GATE/
FLOOR/MARGIN carry. It still lives only here, per the rule directly above.

KNOWN GAP (raised at the Aug 29 vision-integration checkpoint, partially
mitigated by VISION_MIN_VEGETATION_FRACTION below, not fully closed): this
floor was derived from a coverage table of in-distribution paddy photos only.
On out-of-scope test images (non-plant photos) the real classifier returned
max-softmax as high as 0.87 / 0.72 / 0.54 / 0.9995 — none below this floor —
because a 4-class softmax with no rejection class concentrates mass somewhere
regardless of input. Raising this floor to catch those would also reject ~93%
of genuine paddy photos (per the same coverage table), so there is no single
softmax-only threshold fix. The vegetation-fraction pre-filter below catches
the specific failure mode observed (no green content at all) cheaply, without
retraining, but is a heuristic, not a learned rejection class — see
VISION_MIN_VEGETATION_FRACTION's own docstring for what it does and does not
cover. A trained negative/"normal" class (retrain) or shifting more of the
burden to Doubt Doctor's differential question remain open for Suchit/
Thaariha to weigh against this mitigation."""

VISION_MIN_VEGETATION_FRACTION = float(os.environ.get("VISION_MIN_VEGETATION_FRACTION", "0.15"))
"""Below this fraction of green/yellow-green pixels, the classifier declares
`out_of_scope=True` regardless of softmax confidence — a cheap, untrained
complement to OUT_OF_SCOPE_MAX_SOFTMAX above.

Why: the softmax floor alone missed every out-of-scope test image thrown at it
during integration (see the KNOWN GAP note above), including one non-plant
photo scored at 99.95% confidence. Measured on that same test set, real paddy
leaf photos ran ~98% vegetation-hued pixels; the failing non-plant photos ran
0.0%-6.8%. 0.15 sits with wide margin on both sides of that one data point —
it has not been validated against a broad image set, only the specific
failures observed on 2026-08-29.

What this does NOT catch: any out-of-scope subject that happens to be green
(a cucumber, a lawn, a different crop's leaf) — this is a vegetation detector,
not a paddy-leaf detector or a trained rejection class. It complements
OUT_OF_SCOPE_MAX_SOFTMAX; it does not replace the need for a real fix (see the
KNOWN GAP note)."""

OUT_OF_SCOPE_RAW_LOGIT_FLOOR = float(os.environ.get("VISION_OOS_RAW_LOGIT_FLOOR", "2.0"))
"""Below this raw (pre-temperature) max-logit, the classifier declares
`out_of_scope=True` — a third, independent complement to OUT_OF_SCOPE_MAX_SOFTMAX
and VISION_MIN_VEGETATION_FRACTION above. Same exemption as those two: perception
tuning, not a gate decision, so it is env-overridable rather than hardcoded.

Why pre-temperature, not post: `temperature` is fitted purely to calibrate the
*known* 4-class probabilities (docs/DESIGN.md §4) — it is optimized so that a
0.58 on an in-distribution photo means "right 58% of the time", and it cannot
change any argmax. It says nothing about whether the input belongs to that
distribution at all, and dividing by it before scoring can inflate an
out-of-distribution input's apparent confidence exactly the way
OUT_OF_SCOPE_MAX_SOFTMAX's KNOWN GAP describes (0.9995 on a fabric photo).
Scoring the raw logit sidesteps a rescaling that was never fit for this job.

KNOWN GAP, same honesty as the two constants above: this floor was set from the
same small ad-hoc probe used for VISION_MIN_VEGETATION_FRACTION (solid-color
squares standing in for non-plant input) plus a handful of unrelated real
photos found on the dev machine, not a genuine paddy-photo validation set —
none was available locally. In that probe, the solid-color squares scored
1.7-2.13 raw max-logit; ordinary real photos (portraits, objects) scored
2.6-11.85, i.e. *higher* than the synthetic non-plant proxies and on the same
order as a confident in-distribution prediction. So this floor, like the
softmax one, reliably catches only the specific failure shape it was set
against (flat, low-signal input) and should not be read as "raw-logit OOD
detection solved" — it is one more heuristic vote in the OR below, not a
replacement for a trained rejection class."""

# ---------------------------------------------------------------------------
# Voice provider model pins — Sarvam. docs/DESIGN.md §1, §8.
# Module constants, not settings, for the same reason the thresholds are: they
# carry a guarantee. The §13 test "a Marathi query and its English equivalent
# retrieve overlapping docs" is only reproducible if the translator is
# deterministic — one pinned model, formal register. An environment that could
# swap the model or switch to a colloquial mode at demo time could break that
# test silently. The API KEY is the only voice secret; it lives in Settings
# below because it is deployment wiring, not a guarantee.
# ---------------------------------------------------------------------------

SARVAM_STT_MODEL = "saaras:v3"
"""Sarvam speech-to-text. transcribe mode → native-script text + confidence."""

SARVAM_TTS_MODEL = "bulbul:v3"
"""Sarvam text-to-speech for spoken_summary playback."""

SARVAM_TRANSLATE_MODEL = "mayura:v1"
"""Sarvam translation for to_embedding_text(). Marathi/Hindi → English."""

SARVAM_TRANSLATE_MODE = "formal"
"""Deterministic register. Colloquial/code-mixed modes vary phrasing run to run,
which is exactly the wrong property for a reproducible retrieval test."""

SARVAM_CHAT_MODEL = "sarvam-m"
"""Sarvam's chat-completion model, used by app.intelligence.rag.compose() (F7)
to draft the grounded advisory ladder. Gated by `settings.llm_enabled`, not
`asr_provider` -- composition is a separate pipeline from the speech/
translate path those three model pins above serve, and LLM_ENABLED is the
feature flag docs/DESIGN.md §12 already names for it (see app/main.py's
health payload). A module constant, not a setting, for the same reason the
other three Sarvam pins are: a reproducible advisory-composition test needs
one fixed model, not one an environment can swap at demo time."""

# ---------------------------------------------------------------------------
# Spread, follow-up and the confirmation prior — docs/DESIGN.md §10, §11.
# ---------------------------------------------------------------------------

SPREAD_RADIUS_M = 2000
"""Radius for F6 spread alerts, metres. docs/PRD.md §10 leaves the exact value
open; 2 km is the working default and is overridable per deployment only by
editing this line, not by environment."""

RISK_LEVELS = ("low", "moderate", "high")
"""Ordered, lowest first. Index position is the comparison."""

RISK_ALERT_MIN_LEVEL = "moderate"
"""Score at or above this level issues an Alert. Below it, nothing is written.

A module constant, not a settings field: an environment that can lower this can
flood every farmer with low-confidence alerts, and an alert nobody trusts is
worse than no alert. docs/PRD.md section 5."""

MAX_ALERTS_PER_FARM_PER_DAY = 2
"""Backstop cap on how many risk alerts one farm can receive in a day.

Alert cards are non-dismissible until answered (docs/API_CONTRACT.md §10), and
five non-dismissible cards is a product nobody opens twice. Suppressed targets
are re-evaluated tomorrow, so nothing is lost — only deferred.

This caps the F5 risk job ONLY. F6 spread alerts bypass it: a confirmed case
1.5 km away is strictly stronger information than a humidity band, and Phase 4
went to some trouble to stop the daily-uniqueness index suppressing exactly that
alert. Capping it here would reintroduce the same failure by another route."""

WEATHER_PAST_DAYS = 7
"""Trailing days requested from Open-Meteo alongside the forecast.

The favourability rules need a multi-day window ("humidity above 90% for 4
consecutive nights"). That looks like it needs a stored weather history; it does
not, because Open-Meteo's past_days returns the trailing week in the same call.
A weather-observation table would be state someone has to keep fresh, and a gap
in it silently weakens every rule that reads it."""

WEATHER_TIMEOUT_SECONDS = 15

CASE_ETA_MINUTES_PER_POSITION = 15
"""Minutes of expected wait per place in the agronomist queue.

docs/API_CONTRACT.md §12 returns eta_minutes on escalation. A crude linear
estimate, stated as such: the alternative is either no ETA at all, or a
model of agronomist throughput this build has no data to fit."""

FOLLOWUP_DUE_DAYS = 4
"""Days after an advisory before the follow-up check-in falls due.

Four, not five, to match the demo scenario: docs/PRD.md §6 step 8 is "Day 4: got
worse, with a new photo. Severity promotes, auto-escalation fires."
"""

OTP_LENGTH = 6
"""Digits in a one-time code. docs/API_CONTRACT.md §2."""

OTP_MAX_ATTEMPTS = 5
"""Verification attempts allowed against one OtpRequest before it is dead.

A module constant rather than a settings field: an environment that can raise
this can turn the verify endpoint back into a brute-force oracle."""

PRIOR_FULL_CONFIDENCE_COUNT = 10
"""Net confirmations that earn the full PRIOR_MAX_BIAS nudge.

Ten gets the whole nudge, five gets half, and a label corrected as often as it
is confirmed gets nothing. Linear and readable off a screen on purpose —
docs/DESIGN.md §11 warns that dressing this up as learning invites a question
with no good answer on stage."""

PRIOR_MAX_BIAS = 0.05
"""Cap on the additive bias the confirmation prior may apply to a vision
confidence before the gate sees it. docs/DESIGN.md §11: the prior must never be
able to move a prediction across a gate band on its own."""

# ---------------------------------------------------------------------------
# The §11 invariant, asserted rather than commented.
#
# A bias smaller than MARGIN cannot turn an ambiguous pair into a clear one, and
# a bias smaller than (GATE - FLOOR) cannot carry a prediction from below the
# floor to above the gate. Both must hold, at import time, on every process.
# ---------------------------------------------------------------------------

assert PRIOR_MAX_BIAS < MARGIN, (
    f"PRIOR_MAX_BIAS ({PRIOR_MAX_BIAS}) must be smaller than MARGIN ({MARGIN}): "
    "otherwise the confirmation prior could resolve an ambiguous pair by itself. "
    "docs/DESIGN.md §11."
)

assert PRIOR_MAX_BIAS < (GATE - FLOOR), (
    f"PRIOR_MAX_BIAS ({PRIOR_MAX_BIAS}) must be smaller than GATE - FLOOR "
    f"({GATE - FLOOR:.2f}): otherwise the confirmation prior could carry a "
    "prediction from escalate to advise by itself. docs/DESIGN.md §11."
)


class Settings(BaseSettings):
    """Environment-driven configuration.

    Deployment wiring and feature flags only. Decision thresholds are the module
    constants above and are deliberately not settable from the environment.
    """

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=False,
    )

    app_env: Literal["local", "production"] = "local"
    """Two security gates branch on this: core/security.py's fixed-OTP
    allowlist (`== "local"`, fails closed on anything unrecognised) and
    core/routers/auth.py's demo-login denylist (`!= "production"`, used to
    fail OPEN on anything unrecognised -- APP_ENV=prod, a typo, anything not
    exactly the literal string "production" passed the old bare-str check).
    Constrained to the two values this project actually sets anywhere
    (grepped: .env.example, every app_env comparison in app/) so a third
    value is a Pydantic ValidationError at Settings() construction --
    silently picking a branch is not a value this field can hold."""
    log_level: str = "INFO"
    api_prefix: str = "/api/v1"

    # --- Database ---
    database_url: str = "postgresql+asyncpg://bhoomi:bhoomi@localhost:5432/bhoomi"
    alembic_database_url: str = "postgresql+psycopg://bhoomi:bhoomi@localhost:5432/bhoomi"
    test_database_url: str | None = None
    """backend/tests/conftest.py's db_session fixture reads this, not
    database_url. Unset means the test suite runs against database_url, same
    as before this setting existed -- nobody's local setup breaks silently.
    Set it to a genuinely separate database (a second Supabase database, or a
    local Postgres) so a live-verification curl and the pytest suite cannot
    collide on the same seed rows. See README's "Test database" section for
    why a database rather than a schema, and how to point this at one."""
    db_echo: bool = False

    # --- Object storage ---
    s3_endpoint_url: str = "http://localhost:9000"
    s3_public_endpoint_url: str = "http://localhost:9000"
    s3_access_key: str = "bhoomi"
    s3_secret_key: str = "bhoomi123"
    s3_bucket: str = "bhoomi-assets"
    s3_region: str = "us-east-1"
    presign_expiry_seconds: int = Field(default=600, ge=60, le=3600)

    # --- Auth ---
    jwt_secret: str = "dev-secret-change-me"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 720
    refresh_token_expire_days: int = 30
    otp_expire_seconds: int = 300

    demo_mode: bool = False
    """Fail closed. POST /auth/demo (core/routers/auth.py) mints tokens for a
    fixed, seeded farmer identity with no credential beyond this flag -- it
    used to default True with the app_env check dead by construction (an AND
    inside a negation), so the endpoint was reachable in every deployment,
    unauthenticated, by default. A demo deployment opts in explicitly with
    DEMO_MODE=true; nothing is open by not asking. The route is also not
    mounted at all when this is false (app/main.py) -- there is nothing to
    probe, not just nothing to pass."""

    dev_fixed_otp: str | None = None
    """Local-only escape hatch so the demo does not need an SMS provider.

    Applies ONLY when app_env == "local" AND this is set. Unset means codes are
    always generated, in every environment — see core/security.py, which refuses
    to apply it rather than falling back to a default."""

    scheduler_enabled: bool = False
    """Off by default so running the API locally does not fire live jobs
    against shared data. The risk sweep is idempotent by database constraint,
    so enabling it on more than one replica is safe."""

    # --- Feature flags, docs/DESIGN.md §12 ---
    vision_model: Literal["real", "stub"] = "stub"
    asr_provider: Literal["live", "stub"] = "stub"
    llm_enabled: bool = False

    # --- Voice provider (Sarvam) ---
    # asr_provider (above) is the pipeline switch: stub → no Sarvam call on ASR,
    # TTS or translate; live → all three call Sarvam and this key is required.
    # Model versions are module constants above, deliberately not env-tunable.
    sarvamai_api_key: str | None = None

    # --- Weather, F5 ---
    open_meteo_base_url: str = "https://api.open-meteo.com/v1/forecast"


@lru_cache
def get_settings() -> Settings:
    """Process-wide settings singleton."""
    return Settings()


settings = get_settings()
