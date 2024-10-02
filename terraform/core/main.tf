#-------------------------------------------------------------------------------
# GKE Cluster and Networking
#-------------------------------------------------------------------------------

resource "google_compute_network" "this" {
  name = "${var.identifier}-${var.environment}-network"

  auto_create_subnetworks  = true
}

resource "google_compute_subnetwork" "this" {
  name = "${var.identifier}-${var.environment}-subnetwork"

  ip_cidr_range = "10.0.0.0/16"
  region        = var.gcp_region

  stack_type       = "IPV4_ONLY"

  network = google_compute_network.this.id

  # Don't remove the secondary IP ranges added automatically by the cluster
  lifecycle {
    ignore_changes = [ 
      secondary_ip_range 
      ]
  }
}

resource "google_container_cluster" "this" {
  name = "${var.identifier}-${var.environment}-cluster"
  location                 = var.gcp_region

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.this.id
  subnetwork = google_compute_subnetwork.this.id

  datapath_provider = "ADVANCED_DATAPATH"

  # Set deletion protection if this is a production environment
  deletion_protection = contains(["prd", "qal"], var.environment) ? true : false
}

resource "google_container_node_pool" "primary" {
  name       = "${var.identifier}-${var.environment}-pool-primary"
  location   = var.gcp_region
  cluster    = google_container_cluster.this.name
  node_count = 1

  # >1 and in multiple zones
  autoscaling {
    min_node_count = 2
    max_node_count = 4

    location_policy = "BALANCED"
  }

  node_config {
    preemptible  = false        # we don't want VMs to be interrupted
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.gke_access.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}



#-------------------------------------------------------------------------------
# Supporting IAM resources
#-------------------------------------------------------------------------------

resource "google_service_account" "gke_access" {
  account_id   = "${var.identifier}-${var.environment}-access"
  display_name = "Service Account for accessing ${var.identifier}${var.environment} GKE cluster"
}

#Allow the creation of tokens for accessing GKE
resource "google_project_iam_member" "service_account_token_creator" {
  project = var.gcp_project
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.gke_access.email}"
}