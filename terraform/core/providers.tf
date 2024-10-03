provider "google" {
  project = "demoproj-437500"
  region  = "asia-northeast1"
}

terraform {
  backend "gcs" {
    bucket = "k8s-test-tfstate-c74f3a"
    prefix = "env1/core/"
  }
}