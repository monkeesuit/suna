output "public_ip" {
  description = "Ephemeral public IP address of the compute instance"
  value       = module.compute_instance.public_ip
}
