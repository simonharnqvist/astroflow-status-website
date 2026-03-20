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
  name                        = "${var.project_id}-status-site"
  location                    = "europe-west1"
  force_destroy               = true
  #uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "google_storage_bucket_object" "index_html" {
  bucket = google_storage_bucket.static_site.name
  name = "index.html"
  source = "./index.html"
  content_type = "text/html"
}

resource "google_storage_bucket_object" "js" {
  bucket = google_storage_bucket.static_site.name
  name = "status.js"
  source = "./status.js"
  content_type = "application/javascript"
}

resource "google_storage_bucket_object" "css" {
  bucket = google_storage_bucket.static_site.name
  name = "styles.css"
  source = "./styles.css"
  content_type = "text/css"
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