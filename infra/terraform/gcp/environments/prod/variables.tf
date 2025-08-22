variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "repo_url" {
  description = "Git repository URL for Suna"
  type        = string
}

variable "backend_secret" {
  description = "Secret name for backend environment variables"
  type        = string
}

variable "frontend_secret" {
  description = "Secret name for frontend environment variables"
  type        = string
}

variable "docker_compose_args" {
  description = "Extra arguments to pass to docker compose up"
  type        = string
  default     = ""
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "name" {
  type = string
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
}

variable "data_disk_type" {
  type = string
}

variable "root_disk_size_gb" {
  type = number
}

variable "opt_disk_size_gb" {
  type = number
}

variable "var_disk_size_gb" {
  type = number
}

variable "machine_type" {
  description = "Machine type for the instance"
  type        = string
}

variable "boot_image" {
  description = "Boot disk image for the instance"
  type        = string
}

variable "instance_tags" {
  description = "Network tags for the instance"
  type        = list(string)
  default     = []
}

variable "firewall_rules" {
  description = "List of firewall rules to apply"
  type = list(object({
    name        = string
    action      = string
    direction   = string
    protocol    = string
    ports       = list(string)
    ranges      = list(string)
    target_tags = optional(list(string))
    priority    = number
  }))
  default = []
}
