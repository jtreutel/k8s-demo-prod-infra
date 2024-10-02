variable "identifier" {
  description = "A unique identifier for this environment."
  type        = string
}

variable "environment" {
  description = "An environment signifier.  Accepted values: dev|qal|prd"
  type        = string
}

variable "gcp_region" {
  description = "GCP region in which to deploy"
  type        = string
}

variable "gcp_project" {
  description = "GCP project in which to deploy"
  type        = string
}