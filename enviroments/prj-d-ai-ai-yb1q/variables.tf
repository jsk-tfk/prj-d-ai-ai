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


variable "env_suffix" {
  default = "acc"
}

variable "environment" {
  default = "acceptance"
}

variable "node_count" {
  default = 1
}

variable "database_machine_type" {
  description = "Machine type of created database"
  default     = "db-f1-micro"
}

variable "database_highly_available" {
  description = "Whether database should be highly available or not"
  default     = false
}

variable "delete_database_instance_on_destroy" {
  description = "When set to true it will delete database instance on `terraform destroy`"
  default     = false
}
