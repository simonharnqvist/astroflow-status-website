terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = "eu-west2"
}

# ---------- Storage ----------

resource "google_storage_bucket" "static_site" {
  name                        = "${var.project_id}-status-site"
  location                    = "EU"
  force_destroy               = true
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.static_site.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# ---------- Outputs ----------


output "bucket_url" {
  description = "Give this to admin for the reverse proxy"
  value       = "https://storage.googleapis.com/${google_storage_bucket.static_site.name}"
}

output "bucket_name" {
  description = "Upload static files here"
  value       = google_storage_bucket.static_site.name
}