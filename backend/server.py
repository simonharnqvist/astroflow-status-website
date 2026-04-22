import json
import asyncio
import httpx
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


def load_urls():
    with open("../config/urls.json") as f:
        return json.load(f)["urls"]


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


@app.get("/status")
async def status():
    urls = load_urls()
    tasks = [check_single_url(url) for url in urls]
    results = await asyncio.gather(*tasks)
    return {"urls": urls, "results": results}


app.mount("/config", StaticFiles(directory="../config"), name="config")

# Serve the frontend folder
app.mount("/static", StaticFiles(directory="../frontend"), name="static")


# Serve index.html at root
@app.get("/")
def root():
    return FileResponse("../frontend/index.html")


# Serve config folder
app.mount("/config", StaticFiles(directory="../config"), name="config")
