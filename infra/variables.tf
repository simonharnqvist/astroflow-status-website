variable "project_id" {
  type        = string
  default = "testbed-451310"
}

variable "domain" {
  description = "Subdomain for proxy"
  type        = string
  default     = "status.astro-flow.com"
}

variable "bucket_name" {
  type = string
  default = "status.astro-flow.com"
}