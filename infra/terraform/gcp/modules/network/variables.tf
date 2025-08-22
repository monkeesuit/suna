variable "environment" {
  description = "Deployment environment name"
  type        = string

}

variable "name" {
  description = "Name of the network"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
}

variable "region" {
  description = "Region for the subnet"
  type        = string
}
