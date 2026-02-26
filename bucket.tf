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
