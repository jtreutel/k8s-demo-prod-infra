output "cluster_endpoint" {
  value = google_container_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  value = google_container_cluster.this.master_auth[0].cluster_ca_certificate
}

output "cluster_access_service_account_email" {
  value = google_service_account.gke_access.email
}