provider "google" {
  project = "demoproj-437500"
  region  = "asia-northeast1"
}

terraform {
  backend "gcs" {
    bucket = "k8s-test-tfstate-c74f3a"
    prefix = "env1/application/"
  }
}

# Retrieve an access token as the Terraform runner
provider "kubernetes" {
  host                   = "https://${data.terraform_remote_state.core.outputs.cluster_endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(data.terraform_remote_state.core.outputs.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "gke-gcloud-auth-plugin"
  }
}

# For k8s custom resources deployed with kubectl_manifest (because kubernetes_manifest does not work well with CRDs)
/*
provider "kubectl" {
  host  = "https://${data.terraform_remote_state.core.outputs.cluster_endpoint}"
  cluster_ca_certificate = base64decode(data.terraform_remote_state.core.outputs.cluster_ca_certificate)
  exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "gke-gcloud-auth-plugin"
  }
  load_config_file = false
}
*/

provider "helm" {
  kubernetes {
    host                   = "https://${data.terraform_remote_state.core.outputs.cluster_endpoint}"
    cluster_ca_certificate = base64decode(data.terraform_remote_state.core.outputs.cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "gke-gcloud-auth-plugin"
    }
  }
}

