variable "project_id" {
  description = "Your GCP project ID"
  type        = string
  default = "testbed-451310"
}

variable "domain" {
  description = "The subdomain being proxied"
  type        = string
  default     = "status.astro-flow.com"
}