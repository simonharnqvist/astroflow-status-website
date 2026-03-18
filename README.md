# astroflow-status-website
Static website to monitor Astroflow status

                           ┌───────────────────────────┐
                           │        Users / Browsers   │
                           └──────────────┬────────────┘
                                          │
                                          ▼
                           ┌─────────────────────────────┐
                           │   status.astro-flow.com DNS │
                           │   (Cloudflare-managed)      │
                           └──────────────┬──────────────┘
                                          │
                                          ▼
                           ┌──────────────────────────┐
                           │   Cloudflare Edge Network│
                           │  - Global CDN            │
                           │  - DDoS Protection       │
                           │  - TLS Termination       │
                           └──────────────┬───────────┘
                                          │
                                          ▼
                           ┌──────────────────────────┐
                           │   Cloudflare Worker      │
                           │  - Receives request      │
                           │  - Generates signed URL  │
                           │    using SA key          │
                           │  - Fetches from GCS      │
                           │  - Adds cache headers    │
                           └──────────────┬───────────┘
                                          │
                                          ▼
                           ┌──────────────────────────┐
                           │  Google Cloud Storage    │
                           │  Private Bucket          │
                           │  - No public access      │
                           │  - IAM: only SA allowed  │
                           │  - Objects served via    │
                           │    signed URLs only      │
                           └──────────────────────────┘
