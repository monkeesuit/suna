output "public_ip" {
  description = "Public IP address of the VM"
  value       = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}

output "service_account_email" {
  description = "Service account email associated with the VM"
  value       = google_compute_instance.vm.service_account[0].email
}
