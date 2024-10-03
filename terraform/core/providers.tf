provider "google" {
  project = "demoproj"
  region  = "asia-northeast1"
}

terraform {
  backend "gcs" {
    bucket = "k8s-test-tfstate-c74f3a"
    prefix = "env1/core/"
  }
}