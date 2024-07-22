# RelatedDocumentation:
# - https://anixepl.atlassian.net/wiki/spaces/IM/pages/3231318042/Wheels+Infra+Spec

variable "gce_project" {
  default = "prj-d-ai-ai-yb1q"
}

variable "gce_region" {
  default = "europe-central2"
}

variable "gce_zone" {
  default = "europe-central2-c"
}

variable "lb_name" {
  default = "project-ai"
}

variable "ssl" {
  description = "Run load balancer on HTTPS and provision managed certificate with provided `domain`."
  type        = bool
  default     = true
}
variable "domain" {
  description = "Custom domain for the Load Balancer."
  type        = string
  default     = "chat.tfkable.dev"
}
variable "env_suffix" {
  default = "acc"
}

variable "environment" {
  default = "acceptance"
}

variable "database_machine_type" {
  description = "Machine type of created database"
  default     = "db-g1-small"
}

variable "database_highly_available" {
  description = "Whether database should be highly available or not"
  default     = false
}

variable "delete_database_instance_on_destroy" {
  description = "When set to true it will delete database instance on `terraform destroy`"
  default     = false
}

variable "iap_client_secret" {
  description = "value"
  default = null
}

variable "iap_client_id" {
  description = "value"
  default = null
}