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
  region  = "europe-west1"
}

resource "google_storage_bucket" "static_site" {
  name                        = "${var.bucket_name}"
  location                    = "europe-west1"
  force_destroy               = true
  #uniform_bucket_level_access = true

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

output "bucket_name" {
  description = "Upload static files here"
  value       = google_storage_bucket.static_site.name
}