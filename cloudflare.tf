terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# -----------------------------
# Worker Script
# -----------------------------

resource "cloudflare_worker_script" "gcs_proxy" {
  name = "gcs-origin-proxy"

  content = <<-EOF
    export default {
      async fetch(request, env) {
        const url = new URL(request.url)

        // Map request path to GCS object
        let objectPath = url.pathname
        if (objectPath.endsWith("/")) {
          objectPath += "index.html"
        }

        // Build GCS signed URL
        const signedUrl = await createSignedUrl(
          env.GCS_BUCKET,
          objectPath,
          env.GCS_SERVICE_ACCOUNT_KEY
        )

        // Fetch from GCS
        const response = await fetch(signedUrl, {
          method: "GET",
          headers: {
            "User-Agent": "Cloudflare-Worker-GCS-Proxy"
          }
        })

        // Cache at Cloudflare edge
        return new Response(response.body, {
          status: response.status,
          headers: {
            "Content-Type": response.headers.get("Content-Type"),
            "Cache-Control": "public, max-age=3600"
          }
        })
      }
    }

    async function createSignedUrl(bucket, objectPath, keyJson) {
      const key = JSON.parse(keyJson)
      const header = {
        alg: "RS256",
        typ: "JWT"
      }

      const now = Math.floor(Date.now() / 1000)
      const claim = {
        iss: key.client_email,
        scope: "https://www.googleapis.com/auth/devstorage.read_only",
        aud: "https://oauth2.googleapis.com/token",
        exp: now + 3600,
        iat: now
      }

      const encoder = new TextEncoder()
      const encodedHeader = btoa(JSON.stringify(header))
      const encodedClaim = btoa(JSON.stringify(claim))
      const toSign = `${encodedHeader}.${encodedClaim}`

      const cryptoKey = await crypto.subtle.importKey(
        "pkcs8",
        str2ab(atob(key.private_key.split("-----")[2].replace(/\n/g, ""))),
        { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
        false,
        ["sign"]
      )

      const signature = await crypto.subtle.sign(
        "RSASSA-PKCS1-v1_5",
        cryptoKey,
        encoder.encode(toSign)
      )

      const jwt = `${toSign}.${btoa(String.fromCharCode(...new Uint8Array(signature)))}`

      // Exchange JWT for access token
      const tokenResp = await fetch("https://oauth2.googleapis.com/token", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`
      })

      const tokenJson = await tokenResp.json()
      const accessToken = tokenJson.access_token

      return `https://storage.googleapis.com/${bucket}${objectPath}?access_token=${accessToken}`
    }

    function str2ab(str) {
      const buf = new ArrayBuffer(str.length)
      const bufView = new Uint8Array(buf)
      for (let i = 0; i < str.length; i++) {
        bufView[i] = str.charCodeAt(i)
      }
      return buf
    }
  EOF
}

resource "cloudflare_worker_route" "status_route" {
  zone_id     = var.cloudflare_zone_id
  pattern     = "status.astro-flow.com/*"
  script_name = cloudflare_worker_script.gcs_proxy.name
}

resource "cloudflare_record" "status" {
  zone_id = var.cloudflare_zone_id
  name    = "status"
  type    = "CNAME"
  value   = "storage.googleapis.com"
  proxied = true
}
