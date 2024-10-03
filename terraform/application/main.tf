resource "google_dns_record_set" "demoapp" {
  name = "demoapp.${var.primary_domain}."
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.this.name

  rrdatas = [
    data.kubernetes_ingress_v1.demoapp_ingress.status.0.load_balancer.0.ingress.0.ip
  ]
}