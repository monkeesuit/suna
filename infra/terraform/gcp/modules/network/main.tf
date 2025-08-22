resource "google_compute_network" "vpc" {
  name                    = "${var.name}-${var.environment}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  network       = google_compute_network.vpc.id
  name          = "${var.name}-${var.environment}"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
}
