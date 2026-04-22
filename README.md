# Astroflow Service Status Page

Page for checking the availability of Astroflow URLs.

Backend is FastAPI; frontend is static HTML/JS served by the backend.
URLs are defined in a shared config file.

## Structure
```
project/
│
├── backend/
│   └── server.py        # FastAPI app + static serving
│
├── frontend/
│   ├── index.html
│   ├── script.js
│   └── styles.css
│
└── config/
    └── urls.json        # List of URLs to check
```

## Configuration

Edit config/urls.json to change which domains are checked:

## Running

From the backend/ directory:


```bash
uvicorn server:app --reload --port 8000
```

Then open `http://localhost:8000/`

## Endpoints

* `/` — UI

* `/status` — returns status for all URLs

* `/config/urls.json` — shared config file

* `/static/*` — frontend assets

* `/docs` — Swagger documentation

## Notes

No hardcoded hostnames; frontend uses relative paths.

Backend and frontend run as a single service.
