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

variable "gke_sa_roles" {
  description = "List of roles to be provided for GKE SA"
  type = set(string)
  default = [
    "roles/monitoring.viewer",
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/iam.serviceAccountTokenCreator"
  ]
}