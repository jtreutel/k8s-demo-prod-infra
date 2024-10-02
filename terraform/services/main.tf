resource "kubernetes_namespace" "prometheus" {
  metadata {
    name   = "prometheus"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name   = "argocd"
  }
}

resource "helm_release" "kube_prometheus_stack" {

  name = "kube-prometheus-stack"

  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack" #prometheus-community/kube-prometheus-stack
  namespace        = kubernetes_namespace.prometheus.id
  create_namespace = false  # we'll create it separately in case we need to label it
  atomic           = true   
  version          = var.chart_version_prometheus  # peg the chart version to avoid accidental updates



  values = [
    templatefile(
        "${path.module}/helm-values/kube_prometheus_stack.yaml",
        {
            namespaceOverride = kubernetes_namespace.prometheus.id
            primary_domain = var.primary_domain
        }
        )
  ]

  depends_on = [
    kubernetes_namespace.prometheus,
    helm_release.ingress_nginx
  ]
}




resource "helm_release" "ingress_nginx" {

  name = "ingress-nginx"

  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx" #prometheus-community/kube-prometheus-stack
  create_namespace = true 
  atomic           = true   
  version          = var.chart_version_ingress_nginx  # peg the chart version to avoid accidental updates


/*
  values = [
    templatefile(
        "${path.module}/helm-values/ingress_nginx.yaml",
        {
        }
        )
  ]
*/

}



resource "helm_release" "argo_cd" {

  name = "argo-cd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd" 
  create_namespace = false
  namespace        = kubernetes_namespace.argocd.id 
  atomic           = true   
  version          = var.chart_version_argo_cd  # peg the chart version to avoid accidental updates



  values = [
    templatefile(
        "${path.module}/helm-values/argo_cd.yaml",
        {
            primary_domain = var.primary_domain
        }
        )
  ]

  depends_on = [
    kubernetes_namespace.argocd,
    helm_release.ingress_nginx
  ]
}




#-------------------------------------------------------------------------------
# DNS Resources
#-------------------------------------------------------------------------------

resource "google_dns_record_set" "grafana" {
  name = "grafana.${var.primary_domain}."
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.this.name

  rrdatas = [
    data.kubernetes_ingress_v1.grafana_ingress.status.0.load_balancer.0.ingress.0.ip
  ]
}

resource "google_dns_record_set" "argocd" {
  name = "argocd.${var.primary_domain}."
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.this.name

  rrdatas = [
    data.kubernetes_ingress_v1.argocd_ingress.status.0.load_balancer.0.ingress.0.ip
  ]
}