import json
import asyncio
import httpx
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import uvicorn

app = FastAPI()


# -----------------------------
# Load URLs from shared config
# -----------------------------
def load_urls():
    with open("../config/urls.json") as f:
        return json.load(f)["urls"]


# -----------------------------
# Check a single URL
# -----------------------------
async def check_single_url(url: str):
    try:
        async with httpx.AsyncClient(timeout=1.5) as client:
            r = await client.head(url, follow_redirects=True)
            if r.status_code < 400:
                return {"url": url, "status": "online", "code": r.status_code}
            else:
                return {"url": url, "status": "error", "code": r.status_code}
    except Exception:
        return {"url": url, "status": "offline", "code": None}


# -----------------------------
# API endpoint
# -----------------------------
@app.get("/status")
async def status():
    urls = load_urls()
    tasks = [check_single_url(url) for url in urls]
    results = await asyncio.gather(*tasks)
    return {"urls": urls, "results": results}


# -----------------------------
# Serve shared config
# -----------------------------
app.mount("/config", StaticFiles(directory="../config"), name="config")


# -----------------------------
# Serve frontend
# -----------------------------
app.mount("/static", StaticFiles(directory="../frontend"), name="static")


@app.get("/")
def root():
    return FileResponse("../frontend/index.html")


# -----------------------------
# Run server
# -----------------------------
if __name__ == "__main__":
    uvicorn.run("server:app", host="0.0.0.0", port=8000, reload=True)
