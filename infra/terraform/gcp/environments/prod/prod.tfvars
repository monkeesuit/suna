project     = "suna-deployment-1749244914"
environment = "prod"
name        = "suna-v2"

region = "us-central1"
zone   = "us-central1-a"

subnet_cidr = "10.0.0.0/24"

instance_tags = ["suna"]
machine_type  = "c2-standard-8"
boot_image    = "ubuntu-2204-lts"

data_disk_type    = "pd-ssd"
root_disk_size_gb = 15
opt_disk_size_gb  = 15
var_disk_size_gb  = 30

repo_url            = "https://github.com/monkeesuit/suna.git"
backend_secret      = "suna-env-prod"
frontend_secret     = "suna-frontend-env-prod"
docker_compose_args = ""

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
