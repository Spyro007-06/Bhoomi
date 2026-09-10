"""app/core/services/assets.py: the asset-bytes read/write helpers.

Hits the real local MinIO (S3_ENDPOINT_URL) and the real db_session Postgres --
no mocking. The read side's three branches are exactly the three failure
modes voice/ needs distinguished: row missing, wrong kind, row-without-bytes.
"""

from __future__ import annotations

import uuid

import httpx
import pytest

from app.config import settings
from app.contracts.enums import AssetKind
from app.core.models import Asset
from app.core.services.assets import get_asset_bytes, store_bytes
from app.errors import NotFound, ValidationFailed


async def _insert_asset(session, **overrides) -> Asset:
    asset = Asset(
        id=overrides.pop("id", uuid.uuid4()),
        kind=overrides.pop("kind", AssetKind.AUDIO),
        content_type=overrides.pop("content_type", "audio/wav"),
        object_key=overrides.pop("object_key", f"audio/{uuid.uuid4()}.wav"),
        **overrides,
    )
    session.add(asset)
    await session.flush()
    return asset


# --- read side: not found ---------------------------------------------------


async def test_get_asset_bytes_missing_row_raises_not_found(db_session) -> None:
    with pytest.raises(NotFound):
        await get_asset_bytes(db_session, uuid.uuid4())


async def test_get_asset_bytes_malformed_id_raises_not_found_not_a_crash(db_session) -> None:
    with pytest.raises(NotFound):
        await get_asset_bytes(db_session, "not-a-uuid")


# --- read side: wrong kind ---------------------------------------------------


async def test_get_asset_bytes_refuses_an_image_asset(db_session) -> None:
    asset = await _insert_asset(session=db_session, kind=AssetKind.IMAGE, content_type="image/jpeg")

    with pytest.raises(ValidationFailed) as exc_info:
        await get_asset_bytes(db_session, asset.id)

    assert "image" in str(exc_info.value)
    assert "audio" in str(exc_info.value)


# --- read side: row exists, object never uploaded ---------------------------


async def test_get_asset_bytes_presigned_but_never_uploaded_errors_cleanly(db_session) -> None:
    """The exact state core/routers/assets.py's presign endpoint leaves
    behind before a client PUTs anything: a real row, nothing in storage."""
    key = f"audio/{uuid.uuid4()}-never-uploaded.wav"
    asset = await _insert_asset(session=db_session, object_key=key)

    with pytest.raises(NotFound) as exc_info:
        await get_asset_bytes(db_session, asset.id)

    assert "never" in str(exc_info.value).lower() or "no object" in str(exc_info.value).lower()


async def test_get_asset_bytes_accepts_an_image_when_expected_kind_is_image(
    db_session,
) -> None:
    """core/routers/diagnose.py reads a real uploaded photo through this same
    helper with expected_kind=IMAGE -- not the AUDIO default voice/ relies on
    (its call site passes no expected_kind at all, and must keep working
    unchanged; see test_get_asset_bytes_refuses_an_image_asset above)."""
    payload = b"\xff\xd8\xff-not-a-real-jpeg-but-real-bytes"
    object_key = f"image/{uuid.uuid4()}.jpg"

    import boto3
    from botocore.config import Config

    client = boto3.client(
        "s3",
        endpoint_url=settings.s3_endpoint_url,
        aws_access_key_id=settings.s3_access_key,
        aws_secret_access_key=settings.s3_secret_key,
        region_name=settings.s3_region,
        config=Config(signature_version="s3v4"),
    )
    client.put_object(
        Bucket=settings.s3_bucket, Key=object_key, Body=payload, ContentType="image/jpeg"
    )

    asset = await _insert_asset(
        session=db_session, kind=AssetKind.IMAGE, content_type="image/jpeg", object_key=object_key
    )

    result = await get_asset_bytes(db_session, asset.id, expected_kind=AssetKind.IMAGE)

    assert result == payload


async def test_get_asset_bytes_with_expected_kind_image_refuses_an_audio_asset(
    db_session,
) -> None:
    """The check works in both directions -- an audio row handed to a caller
    that wanted an image is refused the same way an image row is refused for
    the AUDIO default."""
    asset = await _insert_asset(session=db_session)  # defaults to kind=AUDIO

    with pytest.raises(ValidationFailed) as exc_info:
        await get_asset_bytes(db_session, asset.id, expected_kind=AssetKind.IMAGE)

    assert "audio" in str(exc_info.value)
    assert "image" in str(exc_info.value)


# --- read side: the real round trip -----------------------------------------


async def test_get_asset_bytes_returns_real_bytes_from_storage(db_session) -> None:
    """A real audio asset: bytes PUT directly to MinIO (bypassing the presign
    flow, which is the client's job), then read back through the helper."""
    import boto3
    from botocore.config import Config

    object_key = f"audio/{uuid.uuid4()}-real.wav"
    client = boto3.client(
        "s3",
        endpoint_url=settings.s3_endpoint_url,
        aws_access_key_id=settings.s3_access_key,
        aws_secret_access_key=settings.s3_secret_key,
        region_name=settings.s3_region,
        config=Config(signature_version="s3v4"),
    )
    payload = b"RIFF....WAVEfmt real-audio-bytes-for-the-test"
    client.put_object(
        Bucket=settings.s3_bucket, Key=object_key, Body=payload, ContentType="audio/wav"
    )

    asset = await _insert_asset(session=db_session, object_key=object_key)

    result = await get_asset_bytes(db_session, asset.id)

    assert result == payload


# --- write side: store_bytes -------------------------------------------------


async def test_store_bytes_writes_a_fetchable_url_and_sets_uploaded_at(db_session) -> None:
    """The TTS write side: bytes in, a real presigned URL out that actually
    fetches the same bytes back -- built on s3_public_endpoint_url, not
    s3_endpoint_url (docs/API_CONTRACT.md §4's {audio_url, expires_in})."""
    payload = b"RIFF....WAVEfmt synthesized-tts-audio-bytes"

    stored = await store_bytes(db_session, AssetKind.AUDIO, "audio/wav", payload)

    assert stored.expires_in == settings.presign_expiry_seconds
    assert stored.url.startswith(settings.s3_public_endpoint_url)

    fetched = httpx.get(stored.url)
    assert fetched.status_code == 200
    assert fetched.content == payload

    row = await db_session.get(Asset, stored.asset_id)
    assert row is not None
    assert row.kind == AssetKind.AUDIO
    assert row.content_type == "audio/wav"
    assert row.byte_size == len(payload)
    assert row.uploaded_at is not None


async def test_store_bytes_then_get_asset_bytes_round_trips(db_session) -> None:
    """The write side and the read side agree: what store_bytes wrote is
    exactly what get_asset_bytes reads back."""
    payload = b"round-trip-bytes"

    stored = await store_bytes(db_session, AssetKind.AUDIO, "audio/wav", payload)

    assert await get_asset_bytes(db_session, stored.asset_id) == payload
