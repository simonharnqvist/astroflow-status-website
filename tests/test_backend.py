import json
import asyncio
import os
from pathlib import Path

import pytest
import respx
import httpx
from fastapi.testclient import TestClient

from backend.server import app, load_urls, check_single_url


# -----------------------------
# Fixtures
# -----------------------------
@pytest.fixture
def client():
    return TestClient(app)


@pytest.fixture
def mock_urls_file(tmp_path, monkeypatch):
    """Create a temporary urls.json and patch load_urls() to use it."""
    config_dir = tmp_path / "config"
    config_dir.mkdir()

    urls_file = config_dir / "urls.json"
    urls_file.write_text(json.dumps({"urls": ["https://a.com", "https://b.com"]}))

    monkeypatch.setattr(
        "backend.server.load_urls", lambda: json.loads(urls_file.read_text())["urls"]
    )

    return urls_file


# -----------------------------
# Test: load_urls()
# -----------------------------
def test_load_urls(mock_urls_file):
    urls = load_urls()
    assert urls == ["https://a.com", "https://b.com"]


# -----------------------------
# Test: check_single_url()
# -----------------------------
@pytest.mark.asyncio
async def test_check_single_url_online():
    url = "https://example.com"

    with respx.mock:
        respx.head(url).respond(status_code=200)

        result = await check_single_url(url)

    assert result["url"] == url
    assert result["status"] == "online"
    assert result["code"] == 200


@pytest.mark.asyncio
async def test_check_single_url_error():
    url = "https://example.com"

    with respx.mock:
        respx.head(url).respond(status_code=503)

        result = await check_single_url(url)

    assert result["status"] == "error"
    assert result["code"] == 503


@pytest.mark.asyncio
async def test_check_single_url_offline():
    url = "https://offline.test"

    with respx.mock:
        respx.head(url).side_effect = httpx.ConnectError("fail")

        result = await check_single_url(url)

    assert result["status"] == "offline"
    assert result["code"] is None


# -----------------------------
# Test: /status endpoint
# -----------------------------
def test_status_endpoint(client, mock_urls_file):
    with respx.mock:
        respx.head("https://a.com").respond(status_code=200)
        respx.head("https://b.com").respond(status_code=404)

        response = client.get("/status")

    assert response.status_code == 200
    data = response.json()

    assert data["urls"] == ["https://a.com", "https://b.com"]
    assert len(data["results"]) == 2

    assert data["results"][0]["status"] == "online"
    assert data["results"][1]["status"] == "error"


# -----------------------------
# Test: root endpoint (index.html)
# -----------------------------
def test_root_serves_index(tmp_path, monkeypatch):
    frontend_dir = tmp_path / "frontend"
    frontend_dir.mkdir()
    index_file = frontend_dir / "index.html"
    index_file.write_text("<html>OK</html>")

    monkeypatch.setattr(
        "backend.server.FileResponse", lambda path: {"mocked": True, "path": path}
    )

    from backend.server import root

    result = root()

    assert result["mocked"] is True
    assert "../frontend/index.html" in result["path"]
