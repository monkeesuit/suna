terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google",
      version = "~> 5.0"
    }
  }
  backend "gcs" {
    bucket = "suna-terraform-state"
    prefix = "state/prod"
  }
}

provider "google" {
  project                     = var.project
  region                      = var.region
  zone                        = var.zone
  impersonate_service_account = "terraform@${var.project}.iam.gserviceaccount.com"
}
