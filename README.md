# k8s-demo-prod-infra
Kubernetes cluster infra 


Features
- Separation of concerns -- limit blast radius (core/services)
- Reusable code -- parameterized/generalized; can be used to provision additional environments

Assumptions
- Env types: Prod, QA, Dev -- represented by the environment labels `prd`, `qal`, and `dev` respectively
- State bucket `k8s-test-tfstate-u518zm` created outside of the TF plan
- `google_container_node_pool.node_config.oauth_scopes` would be appropiately narrowed to follow PoLP in actual prod; currently grants GCP SA access to all APIs
- TLS certs manually created via certbot CLI -- in prod, we'd automate their creation with certbot on k8s and GCP Cloud DNS01 challenge