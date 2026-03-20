resource "google_storage_bucket_object" "index_html" {
  bucket = google_storage_bucket.static_site.name
  name = "index.html"
  source = "../src/index.html"
  content_type = "text/html"
}

resource "google_storage_bucket_object" "js" {
  bucket = google_storage_bucket.static_site.name
  name = "status.js"
  source = "../src/status.js"
  content_type = "application/javascript"
}

resource "google_storage_bucket_object" "css" {
  bucket = google_storage_bucket.static_site.name
  name = "styles.css"
  source = "../src/styles.css"
  content_type = "text/css"
}

resource "google_storage_bucket_object" "urls" {
    bucket = google_storage_bucket.static_site.name
    name = "urls.json"
    source = "../config/urls.json"
    content_type = "text/json"
    
}