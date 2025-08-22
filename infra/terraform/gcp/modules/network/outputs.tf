output "name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "subnet_link" {
  description = "Self-link of the subnet"
  value       = google_compute_subnetwork.subnet.self_link
}
