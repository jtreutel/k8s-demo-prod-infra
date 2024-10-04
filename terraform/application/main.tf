locals {
  app_deployed = true # deployed via argod? if yes, true; if not yet, false
}

resource "kubernetes_namespace" "demoapp" {
  metadata {
    name   = "demoapp"
  }
}


resource "google_dns_record_set" "demoapp" {
  count = local.app_deployed ? 1 : 0

  name = "demoapp.${var.primary_domain}."
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.this.name

  rrdatas = [
    data.kubernetes_ingress_v1.demoapp_ingress[0].status.0.load_balancer.0.ingress.0.ip
  ]
}