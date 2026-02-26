variable "project_id" {
  description = "Your GCP project ID"
  type        = string
}

variable "domain" {
  description = "The subdomain being proxied"
  type        = string
  default     = "status.astro-flow.com"
}