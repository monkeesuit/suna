## Setup

1. **Supabase Setup**
    Create a supabase environment & project, then configure & migrate. https://supabase.com/dashboard

    ```
    cd backend/
    supabase link --project-ref <PROJECT_REF>
    supabase config push  # applies config.toml
    supbase db push       # remote migration
    ```

1. **Enable required APIs**
   ```bash
   PROJECT=suna-deployment-1749244914
   gcloud config set project "$PROJECT"
   gcloud services enable cloudresourcemanager.googleapis.com \
     iam.googleapis.com compute.googleapis.com \
     secretmanager.googleapis.com artifactregistry.googleapis.com
   ```

2. **Create and configure the Terraform service account**
   ```bash
   gcloud iam service-accounts create terraform \
     --description="Service account for Terraform" \
     --display-name="Terraform Service Account"

   SA="terraform@${PROJECT}.iam.gserviceaccount.com"
   gcloud projects add-iam-policy-binding $PROJECT \
     --member="serviceAccount:${SA}" \
     --role="roles/compute.networkAdmin"
   gcloud projects add-iam-policy-binding $PROJECT \
     --member="serviceAccount:${SA}" \
     --role="roles/compute.instanceAdmin.v1"
   gcloud projects add-iam-policy-binding $PROJECT \
     --member="serviceAccount:${SA}" \
     --role="roles/iam.serviceAccountAdmin"
   gcloud projects add-iam-policy-binding $PROJECT \
     --member="serviceAccount:${SA}" \
     --role="roles/iam.serviceAccountUser"
   gcloud projects add-iam-policy-binding $PROJECT \
     --member="serviceAccount:${SA}" \
     --role="roles/resourcemanager.projectIamAdmin"
   gcloud projects add-iam-policy-binding $PROJECT \
     --member="serviceAccount:${SA}" \
     --role="roles/compute.securityAdmin"
   gcloud projects add-iam-policy-binding $PROJECT \
     --member="serviceAccount:${SA}" \
     --role="roles/secretmanager.admin"

   gcloud auth login
   export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=$SA
   ```

    ⚠️ To control who can impersonate your Terraform service account, grant impersonation rights only to specific identities.

      * Give impersonation rights w/ `add-iam-policy-binding`
        ```bash
        gcloud iam service-accounts add-iam-policy-binding $SA \
          --member="user:alice@example.com" \
          --role="roles/iam.serviceAccountTokenCreator"
        ```
      * View current impersonation permissions w/ `get-iam-policy`
        ```bash
        gcloud iam service-accounts get-iam-policy $SA \
          --format="table(bindings.role, bindings.members)"
        ```
      * Revoke impersonation rights when no longer needed w/ `remove-iam-policy-binding`:
        ```bash
        gcloud iam service-accounts remove-iam-policy-binding $SA \
          --member="user:alice@example.com" \
          --role="roles/iam.serviceAccountTokenCreator"
        ```


3. **Configure remote state storage**
   ```bash
   gsutil mb -l us-central1 gs://suna-terraform-state
   gsutil versioning set on gs://suna-terraform-state
   gcloud storage buckets add-iam-policy-binding gs://suna-terraform-state \
     --member="serviceAccount:${SA}" \
     --role="roles/storage.objectAdmin"
   ```

4. **Manage secrets**
   ```bash
   gcloud secrets create suna-env-prod \
     --replication-policy="automatic" \
     --data-file=./suna.env
   gcloud secrets versions access latest --secret=suna-env-prod

   gcloud secrets create suna-frontend-env-prod \
     --replication-policy="automatic" \
     --data-file=./suna.frontend.env
   gcloud secrets versions access latest --secret=suna-frontend-env-prod

   # Updating secret
   gcloud secrets versions add suna-frontend-env-prod \
     --data-file=./suna.frontend.env
   ```

## Execution
1. **Initialize**
   ```bash
   cd infra/terraform/gcp/environments/prod   # or another environment
   gcloud auth application-default login
   terraform init
   ```
2. **Plan**
   ```bash
   terraform plan -var-file=prod.tfvars
   ```
3. **Apply**
   ```bash
   terraform apply -var-file=prod.tfvars
   terraform output -raw public_ip   # retrieve public endpoint
   ```
4. **Destroy**
   ```bash
   terraform destroy -var-file=prod.tfvars
   ```

### Example `prod.tfvars`
```hcl
project     = "suna-deployment-1749244914"
environment = "prod"
region = "us-central1"
zone   = "us-central1-a"
vpc_name    = "suna-v2-vpc"
subnet_name = "suna-v2-subnet"
subnet_cidr = "10.0.0.0/24"
secret_names = ["suna-env-prod", "suna-frontend-env-prod"]

instance_name  = "suna-v2"
instance_tags  = ["suna"]
machine_type   = "c2-standard-8"
boot_image     = "ubuntu-2204-lts"
static_ip_name = "suna-v2-ip"

data_disk_type    = "pd-ssd"
root_disk_size_gb = 15
opt_disk_size_gb  = 15
var_disk_size_gb  = 30

firewall_rules = [
  {
    name        = "allow-suna"
    action      = "allow"
    direction   = "INGRESS"
    protocol    = "tcp"
    ports       = ["3000", "8000"]
    ranges      = ["0.0.0.0/0"]
    target_tags = ["suna"]
    priority    = 1000
  },
  {
    name      = "allow-https-egress"
    action    = "allow"
    direction = "EGRESS"
    protocol  = "tcp"
    ports     = ["80", "443"]
    ranges    = ["0.0.0.0/0"]
    priority  = 1000
  },
  {
    name      = "allow-ssh-ingress"
    action    = "allow"
    direction = "INGRESS"
    protocol  = "tcp"
    ports     = ["22"]
    ranges    = ["0.0.0.0/0"]
    priority  = 1000
  }
]
```

### Variables

Key variables defined in `variables.tf`:

| Variable | Description |
|----------|-------------|
| `project` | GCP project ID |
| `region` | GCP region |
| `zone` | GCP zone |
| `vpc_name` | Name of the VPC |
| `subnet_name` | Name of the subnet |
| `subnet_cidr` | CIDR range for the subnet |
| `instance_name` | Name of the compute instance |
| `machine_type` | Machine type for the instance |
| `metadata_startup_script` | Startup script executed on boot |
| `instance_tags` | Network tags for the instance |
| `firewall_rules` | List of firewall rules |

Override defaults by supplying a modified `*.tfvars` file or with `-var` flags.

## Troubleshooting
- **Missing APIs** – Terraform errors such as `accessNotConfigured` indicate APIs are disabled.
  ```bash
  gcloud services enable cloudresourcemanager.googleapis.com iam.googleapis.com \
    compute.googleapis.com secretmanager.googleapis.com artifactregistry.googleapis.com
  ```
- **Insufficient IAM permissions** – Permission denied errors occur when the service account lacks a role.
  ```bash
  gcloud projects get-iam-policy $PROJECT --format="table(bindings.role, bindings.members)"
  gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:${SA}" --role=ROLE_NAME
  ```
- **Failed state bucket access** – `terraform init` fails if the service account cannot reach the backend bucket.
  ```bash
  gsutil ls gs://suna-terraform-state
  gcloud storage buckets add-iam-policy-binding gs://suna-terraform-state \
    --member="serviceAccount:${SA}" --role="roles/storage.objectAdmin"
  ```

## Future Work
- Parameterized disk management
- Improved startup scripts
- Module refactoring for reuse
- Issue with .env files - I need to populate the public IP manually after terraform assigns one