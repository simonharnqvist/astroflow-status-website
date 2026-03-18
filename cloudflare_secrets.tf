resource "cloudflare_worker_secret" "gcs_bucket" {
  script_name = cloudflare_worker_script.gcs_proxy.name
  name        = "GCS_BUCKET"
  value       = google_storage_bucket.static_site.name
}

resource "cloudflare_worker_secret" "gcs_service_account_key" {
  script_name = cloudflare_worker_script.gcs_proxy.name
  name        = "GCS_SERVICE_ACCOUNT_KEY"
  value       = google_service_account_key.cloudflare_origin_key.private_key
}

