variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "network" {
  description = "VPC network for the firewall rule"
  type        = string
}

variable "rules" {
  description = "List of firewall rules"
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
}
