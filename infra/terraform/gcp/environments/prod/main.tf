module "network" {
  source = "../../modules/network"

  region      = var.region
  environment = var.environment
  name        = var.name

  subnet_cidr = var.subnet_cidr
}

module "compute_instance" {
  source = "../../modules/compute"

  project     = var.project
  zone        = var.zone
  environment = var.environment
  name        = var.name

  subnet_link = module.network.subnet_link

  data_disk_type    = var.data_disk_type
  root_disk_size_gb = var.root_disk_size_gb
  opt_disk_size_gb  = var.opt_disk_size_gb
  var_disk_size_gb  = var.var_disk_size_gb

  machine_type = var.machine_type
  boot_image   = var.boot_image

  repo_url            = var.repo_url
  backend_secret      = var.backend_secret
  frontend_secret     = var.frontend_secret
  docker_compose_args = var.docker_compose_args

  tags = var.instance_tags
}

module "firewall" {
  source      = "../../modules/firewall"
  network     = module.network.name
  environment = var.environment

  rules = var.firewall_rules
}
