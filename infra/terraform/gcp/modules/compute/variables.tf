variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "name" {
  description = "Name of the instance"
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g., prod, staging)"
  type        = string
}

variable "zone" {
  description = "Zone for the instance"
  type        = string
}

variable "subnet_link" {
  description = "Self link of the subnet"
  type        = string
}

variable "data_disk_type" {
  description = "Disk type. pd-ssd | pd-standard | pd-balanced"
  type        = string
}

variable "root_disk_size_gb" {
  description = "Root disk size in GB"
  type        = number
}

variable "opt_disk_size_gb" {
  description = "/opt disk size in GB"
  type        = number
}

variable "var_disk_size_gb" {
  description = "/var disk size in GB"
  type        = number
}

variable "machine_type" {
  description = "Machine type for the instance"
  type        = string
}

variable "boot_image" {
  description = "Boot disk image"
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

locals {
  startup_scripts = {
    "01-mount.sh" = templatefile("${path.module}/scripts/01-mount.sh", {
      name = var.name
    }),
    "02-suna.sh" = templatefile("${path.module}/scripts/02-suna.sh", {
      repo_url            = var.repo_url,
      backend_secret      = var.backend_secret,
      frontend_secret     = var.frontend_secret,
      docker_compose_args = var.docker_compose_args,
    }),
  }
}


variable "tags" {
  description = "Network tags"
  type        = list(string)
  default     = []
}
