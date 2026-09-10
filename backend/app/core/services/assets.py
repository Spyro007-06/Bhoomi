"""Asset bytes: the read side for ASR, the write side for TTS.

OWNER: Shreekumar. Spec: docs/DESIGN.md §3, §8 (v3), docs/API_CONTRACT.md §3, §4.

-----------------------------------------------------------------------------
Why this exists

`core/routers/assets.py` only ever minted a presigned PUT for a client's own
upload — nothing in `core/` could read an object back, or write bytes the
*server* generated and hand back a URL. `app/voice/providers.py`'s
LiveSpeechToText and LiveTextToSpeech both documented this exact gap and
raised NotImplementedError naming it, rather than reaching into S3 or the
database directly from `voice/` and breaking the module boundary
docs/DESIGN.md §3 draws (`voice/` is Shruthi's, `core/` is the only package
that touches the database or object storage). These two functions are that
missing half.

`get_asset_bytes` -- READ side, for ASR. `store_bytes` -- WRITE side, for TTS.
Both take a session, like every other function in this package; `voice/` gets
typed results back, never a session of its own.

-----------------------------------------------------------------------------
On `uploaded_at`

Nothing in the live app ever sets `Asset.uploaded_at` — only `seed/case_file.py`
does, for demo fixtures. `core/routers/assets.py`'s presign endpoint writes the
row before the client's PUT even starts, and nothing today confirms that PUT
landed. `get_asset_bytes` below does NOT gate on `uploaded_at` being non-null:
doing so would refuse every real asset a farmer has ever uploaded, since none
of them have it set. What it gates on instead is the only thing that is
actually true or false in the object store itself — whether `object_key`
resolves to a real object — which is the same fact `uploaded_at` was meant to
proxy for, checked directly instead of through a column nothing writes.

`store_bytes`, by contrast, DOES set `uploaded_at`. It is the one code path in
this codebase where the row and the bytes are written by the same call, so
"uploaded" is synchronously, provably true the moment the row is created —
not a promise about a client PUT that may or may not have happened yet.
-----------------------------------------------------------------------------
"""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from datetime import UTC, datetime
from functools import lru_cache

import boto3
from botocore.config import Config
from botocore.exceptions import ClientError
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.contracts.enums import AssetKind
from app.core.models import Asset
from app.errors import NotFound, ValidationFailed

# Same extension map as core/routers/assets.py's presign endpoint. Duplicated
# rather than imported: that map is a private detail of the presign handler,
# not a shared constant, and the two call sites diverging slightly (this one
# only ever sees audio/* in practice) is not worth a shared-module import for
# five dict entries.
_EXTENSION_BY_CONTENT_TYPE = {
    "image/jpeg": "jpg",
    "image/png": "png",
    "audio/mpeg": "mp3",
    "audio/wav": "wav",
    "audio/webm": "webm",
}


@lru_cache
def _s3(endpoint_url: str) -> boto3.client:
    """One cached client per endpoint URL.

    Two different endpoints are genuinely needed, not one: `s3_endpoint_url`
    for every operation this process performs itself (GET the bytes, PUT the
    bytes), and `s3_public_endpoint_url` only for signing a URL that is about
    to leave the process and be fetched by a client. They are equal in local
    dev (docker-compose) and can differ in a real deployment (an internal
    Docker/VPC hostname vs. a publicly reachable one) — a URL built against
    the internal host works from inside this container and nowhere else,
    which is exactly the failure this split exists to prevent.
    """
    return boto3.client(
        "s3",
        endpoint_url=endpoint_url,
        aws_access_key_id=settings.s3_access_key,
        aws_secret_access_key=settings.s3_secret_key,
        region_name=settings.s3_region,
        config=Config(signature_version="s3v4"),
    )


def _as_uuid(asset_id: uuid.UUID | str) -> uuid.UUID | None:
    if isinstance(asset_id, uuid.UUID):
        return asset_id
    try:
        return uuid.UUID(asset_id)
    except (ValueError, AttributeError, TypeError):
        return None


async def get_asset_bytes(
    session: AsyncSession,
    asset_id: uuid.UUID | str,
    *,
    expected_kind: AssetKind = AssetKind.AUDIO,
) -> bytes:
    """Read an asset's bytes back from object storage, by id.

    `expected_kind` defaults to AUDIO -- this function's first caller
    (LiveSpeechToText, app/voice/providers.py) always wants audio and calls
    positionally with two arguments, so its call site did not change when
    this gained a second caller wanting images (diagnose_farm(),
    core/routers/diagnose.py, Part 2 of the same task that added this
    parameter) instead of the fixed AUDIO check the function was written
    with initially.

    Three distinct, distinguishable failures, none of them a raw exception
    reaching the caller:

    - the Asset row does not exist                          -> NotFound
    - the row exists but is not `kind=expected_kind`         -> ValidationFailed
    - the row exists, right kind, but no object is at
      `object_key` -- the presigned PUT was minted and never
      completed, or failed partway                           -> NotFound

    The third case is real, not hypothetical: `core/routers/assets.py`'s
    presign endpoint writes the Asset row BEFORE the client PUTs any bytes,
    so an id that resolves to a row with nothing behind it in storage is an
    expected state, not a bug. See the module docstring for why this does not
    gate on `uploaded_at` instead.
    """
    parsed = _as_uuid(asset_id)
    asset = await session.get(Asset, parsed) if parsed is not None else None
    if asset is None:
        raise NotFound(f"Asset {asset_id} does not exist.")

    if asset.kind != expected_kind:
        raise ValidationFailed(
            f"Asset {asset_id} is kind={asset.kind.value!r}, not "
            f"{expected_kind.value!r} -- it cannot be used here."
        )

    client = _s3(settings.s3_endpoint_url)
    try:
        response = client.get_object(Bucket=settings.s3_bucket, Key=asset.object_key)
    except ClientError as exc:
        error_code = exc.response.get("Error", {}).get("Code", "")
        if error_code in ("NoSuchKey", "404"):
            raise NotFound(
                f"Asset {asset_id}'s row exists but no object was ever "
                f"uploaded to storage — the presigned PUT for "
                f"{asset.object_key!r} was minted but never completed, or "
                "failed partway."
            ) from exc
        raise
    return response["Body"].read()


@dataclass(frozen=True, slots=True)
class StoredAsset:
    """docs/API_CONTRACT.md §4's `{audio_url, expires_in}` shape, plus the id
    a caller may want to reference the new row by."""

    asset_id: uuid.UUID
    url: str
    expires_in: int


async def store_bytes(
    session: AsyncSession, kind: AssetKind, content_type: str, data: bytes
) -> StoredAsset:
    """Write server-generated bytes to object storage and return a URL a
    client can fetch them from.

    For TTS: Sarvam hands `LiveTextToSpeech._synthesize_bytes()` decoded audio
    bytes, and `synthesize()` must return `audio_url` + `expires_in`
    (docs/API_CONTRACT.md §4) without `voice/` ever touching S3 or the
    database directly (docs/DESIGN.md §3). This mints the Asset row, PUTs the
    bytes itself (a direct write, not a presigned round trip -- there is no
    client on the other end of this upload), and returns a presigned GET.

    Reuses the Asset row rather than a new table: nothing about a
    server-written object differs from a client-written one once the bytes
    exist -- same `kind`, `content_type`, `object_key` shape, same row the
    read side above already knows how to serve back.
    """
    asset_id = uuid.uuid4()
    extension = _EXTENSION_BY_CONTENT_TYPE.get(content_type, "bin")
    object_key = f"{kind.value}/{asset_id}.{extension}"

    _s3(settings.s3_endpoint_url).put_object(
        Bucket=settings.s3_bucket, Key=object_key, Body=data, ContentType=content_type
    )

    session.add(
        Asset(
            id=asset_id,
            kind=kind,
            content_type=content_type,
            object_key=object_key,
            byte_size=len(data),
            # Provably true here -- see the module docstring's "On
            # uploaded_at" section. This is the one write path where the
            # bytes and the row are the same call, not a promise about a
            # client PUT that may never land.
            uploaded_at=datetime.now(UTC),
        )
    )
    await session.commit()

    url = _s3(settings.s3_public_endpoint_url).generate_presigned_url(
        "get_object",
        Params={"Bucket": settings.s3_bucket, "Key": object_key},
        ExpiresIn=settings.presign_expiry_seconds,
    )
    return StoredAsset(asset_id=asset_id, url=url, expires_in=settings.presign_expiry_seconds)
