#########################
###  SERVICE ACCOUNT  ###
#########################
resource "google_service_account" "vm" {
  project      = var.project
  account_id   = "${var.name}-${var.environment}"
  display_name = "VM Service Account"
}

locals {
  baseline_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/stackdriver.resourceMetadata.writer", # OS Config / metadata
    "roles/artifactregistry.reader",             # pull images if you run containers
  ]
}

resource "google_project_iam_member" "vm" {
  for_each = toset(local.baseline_roles)

  project = var.project
  role    = each.value
  member  = "serviceAccount:${google_service_account.vm.email}"
}

resource "google_secret_manager_secret_iam_member" "vm" {
  for_each = toset([var.backend_secret, var.frontend_secret])

  project   = var.project
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.vm.email}"
}

###################
###  DATA DISK  ###
###################
resource "google_compute_disk" "opt_data" {
  name = "${var.name}-opt"
  type = var.data_disk_type
  size = var.opt_disk_size_gb
  zone = var.zone
}

resource "google_compute_disk" "var_data" {
  name = "${var.name}-var"
  type = var.data_disk_type
  size = var.var_disk_size_gb
  zone = var.zone
}


#############################
###  COMPUTE INSTANCE VM  ###
#############################


resource "google_compute_address" "vm_ip" {
  name = "${var.name}-${var.environment}"
}

resource "google_compute_instance" "vm" {
  name = "${var.name}-${var.environment}"

  zone         = var.zone
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = var.boot_image
      size  = var.root_disk_size_gb
      type  = var.data_disk_type
    }
  }
  attached_disk {
    source      = google_compute_disk.var_data.id
    device_name = "${var.name}-var-data-${var.environment}"
    mode        = "READ_WRITE"
  }
  attached_disk {
    source      = google_compute_disk.opt_data.id
    device_name = "${var.name}-opt-data-${var.environment}"
    mode        = "READ_WRITE"
  }
  network_interface {
    subnetwork = var.subnet_link
    access_config {
      nat_ip = google_compute_address.vm_ip.address
    }
  }
  service_account {
    email  = google_service_account.vm.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  metadata = {
    "user-data" = templatefile("${path.module}/cloudinit/cloud-config.yaml.tmpl", {
      scripts_map = local.startup_scripts
      run_order   = sort(keys(local.startup_scripts)) # lexicographic order
    })
  }

  tags = var.tags
}
