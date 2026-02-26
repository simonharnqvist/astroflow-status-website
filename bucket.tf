resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "bucket_1" {
  name                        = "${random_id.bucket_prefix.hex}-bucket-1"
  location                    = "eu-west1"
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  force_destroy = true
}

resource "google_compute_backend_bucket" "bucket_1" {
  name        = "cats"
  description = "Contains cat image"
  bucket_name = google_storage_bucket.bucket_1.name
}


# adapt - only one bucket
# Create url map
resource "google_compute_url_map" "default" {
  name = "http-lb"

  default_service = google_compute_backend_bucket.bucket_1.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "path-matcher-2"
  }
  path_matcher {
    name            = "path-matcher-2"
    default_service = google_compute_backend_bucket.bucket_1.id

    path_rule {
      paths   = ["/love-to-fetch/*"]
      service = google_compute_backend_bucket.bucket_2.id
    }
  }
}

# Create HTTP target proxy
resource "google_compute_target_http_proxy" "default" {
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.default.id
}

# Create forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "http-lb-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}
