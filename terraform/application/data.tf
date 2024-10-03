data "terraform_remote_state" "core" {
  backend = "gcs"
  config = {
    bucket = "k8s-test-tfstate-c74f3a"
    prefix = "env1/core/"
  }
}

data "google_client_config" "provider" {}

data "kubernetes_ingress_v1" "demoapp_ingress" {
  metadata {
    name      = "demoapp-ingress"
    namespace = "demoapp"
  }
}

# Assumes consistent DNS zone naming scheme:  foo.bar.baz -> foo-bar-baz
data "google_dns_managed_zone" "this" {
  name     = replace(var.primary_domain, ".", "-")
}