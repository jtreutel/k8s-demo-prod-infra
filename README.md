# k8s-demo-prod-infra

Terraform plan for deploying and configuring a GKE cluster, installing shared services, and deploying GCP infrastructure to support the production application ("demoapp").


## Features
- **Separation of Concerns** 
  - Limits "blast radius" by grouping infrastructure in a way that minimizes the number of infra components that must be "touched" when making changes
- **Reusability**
  - The terraform plans are parameterized in such a way that they can easily be used to deploy additional environments (e.g. nonprod)
- **Secure and Transparent**
  - Deployment is performed via a service account that cannot be accessed by other developers
  - Deployments are only performed via GHA, making all changes to infrastructure visible and auditable

## Structure 

### Terraform/Core

Sets up basic Kubernetes infrastructure in GCP.  Deploys the following:
  - GCP VPC and subnets
  - GKE cluster
  - GKE nodepool (defined separately for easier management)
  - GCP Service Account for cluster access (see [TODO](#todo) below)

### Terraform/Services

Sets up shared services on the k8s cluster.  Deploys the following:
  - ArgoCD
  - Ingress Nginx controller
  - kube-prometheus stack, including Prometheus and Grafana (not used, just an example of where this sort of service would go)
  - Namespaces for the above applictions
  - DNS records pointing to the nginx ingresses for the above applications

### Terraform/Application

Sets up infrastructure to support the application.  Deploys the following:

  - DNS record pointing to the nginx ingress for the "demoapp" application

## Additional Context

### Assumptions
- Naming convention: Prod, QA, Dev are represented by the environment labels `prd`, `qal`, and `dev` respectively
- Existing infrastructure
  - State bucket `k8s-test-tfstate-c74f3a` 
  - Service account `gha-access` for programmatic access from GHA
  - Nginx Ingress TLS cert secrets manually created via certbot CLI

### TODO
  - General
    - Reconfigure networking so that internal services (e.g. Grafana) are only availabe on the private network
  - CI/CD
    - Configure GCP OIDC provider so that GHA does not have to store a GCP SA service key
    - Configure GHA pipeline to treat this repo as a monorepo using a cascading Terraform apply:
      - `core` modified:  `core -> services -> application`
      - `services` modified: `services -> application`
      - `application` modified: `application`
    - Configure GHA pipeline to allow Terraform to apply the `application` plan after changes are made to the application code repo
  - Core
    - Narrow `google_container_node_pool.node_config.oauth_scopes` in accordance with PoLP in prod; currently grants GCP SA access to all APIs
    - Parameterize GKE cluster config for horizontal/vertical cluster scaling
  - Services
    - Automate creation and renewal of TLS certs with certbot (using DNS01 challenge on GCP Cloud DNS)
 