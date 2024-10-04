variable "chart_version_prometheus" {
  description = "kube-prometheus-stack chart version. Note that this is different than the Prometheus app version."
  type        = string
  default     = "63.1.0" #app ver: v0.76.1
}

variable "chart_version_ingress_nginx" {
  description = "ingress-nginx chart version. Note that this is different than the Ingress Nginx app version."
  type        = string
  default     = "4.11.2" #app ver: 1.11.2
}

variable "chart_version_argo_cd" {
  description = "argo-cd chart version. Note that this is different than the ArgoCD app version."
  type        = string
  default     = "7.6.7" #app ver: v2.12.4
}

variable "primary_domain" {
  description = "DNS domain for this cluster"
}