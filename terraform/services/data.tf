data "terraform_remote_state" "core" {
  backend = "gcs"
  config = {
    bucket = "k8s-test-tfstate-c74f3a"
    prefix = "env1/core/"
  }
}

data "google_client_config" "provider" {}

#Generates a token for accessing the k8s cluster
#data "google_service_account_access_token" "my_kubernetes_sa" {
#  target_service_account = data.terraform_remote_state.core.outputs.cluster_access_service_account_email
#  scopes                 = ["userinfo-email", "cloud-platform"]
#  lifetime               = "3600s"
#}

data "kubernetes_ingress_v1" "grafana_ingress" {
  metadata {
    name      = "kube-prometheus-stack-grafana"
    namespace = kubernetes_namespace.prometheus.id
  }

  depends_on = [
    helm_release.kube_prometheus_stack
  ]
}

data "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name      = "argo-cd-argocd-server"
    namespace = kubernetes_namespace.argocd.id
  }

  depends_on = [
    helm_release.argo_cd
  ]
}

# Assumes consistent DNS zone naming scheme:  foo.bar.baz -> foo-bar-baz
data "google_dns_managed_zone" "this" {
  name = replace(var.primary_domain, ".", "-")
}