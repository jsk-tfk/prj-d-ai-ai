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

variable "gce_subnet_name" {
  default = "fti-wheels-acc"
}

variable "cluster_name" {
  default = "wheels-acc-new"
}

variable "fe_domain" {
  default = "resfinity.io"
}

variable "be_domain" {
  default = "resfinity.net"
}

variable "env_suffix" {
  default = "acc"
}

variable "environment" {
  default = "acceptance"
}

variable "administrator_email" {
  default = "wheels@anixe.pl"
}

variable "administrator_password" {
  default = "$2a$10$Sv4Jx1CSPW8yjMPbkyiCtuJHsSSpvon53SfrAjmy3EMwo.lvxMAoq"
}

variable "administrator_salt" {
  default = "salty"
}

variable "node_count" {
  default = 1
}

variable "node_machine_type" {
  default = "n1-standard-2"
}

variable "min_node_count" {
  default = 1
}
variable "max_node_count" {
  default = 1
}

variable "master_ipv4_cidr_block" {
  default = "172.31.0.0/28"
}





variable "cronicle_slack_webhook" {
  default = "https://hooks.slack.com/services/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"
}

variable "recs_rabbitmq_url" {
  default     = "amqp://resc:ajrC5GSVMdHQV8cxPNGMTfT3tUwApKaX@35.242.237.66:5672/resc"
  description = "AMQP URL to RECS vhost"
}

variable "rabbitmq_permissions" {
  type = list(object({
    configure = string
    read      = string
    user      = string
    vhost     = string
    write     = string
  }))
  default = [
    {
      configure = ".*"
      read      = ".*"
      user      = "resfinity"
      vhost     = "/"
      write     = ".*"
    },
    {
      configure = ".*"
      read      = ".*"
      user      = "resfinity"
      vhost     = "wheels"
      write     = ".*"
    }
  ]
}

variable "rabbitmq_vhost" {
  type = list(object({
    name = string
  }))
  default = [
    {
      name = "/"
    },
    {
      name = "wheels"
    },
    {
      name = "test"
    }
  ]
}

variable "rabbitmq_users" {
  type = map(object({
    login              = string
    password           = string
    encrypted_password = string
    tags               = string
  }))

  default = {
    "resfinity" = {
      login              = "resfinity"
      password           = "Anx1234Weels",
      encrypted_password = "bK90bWZ5b7IdrN9IYMCvQ9vwYCu2NVpuJO6WQ7Qmbjxg3Iob"
      tags               = "administrator,management,resfinity"
    },
    "telegraf" = {
      login              = "telegraf"
      password           = "UvobfKBg5beGFH6_f9CZNcgo8lKTyz2q",
      encrypted_password = "ZdpxT35Bi8/93JinMB4msa1VbnJI3v88QSP4LOMXMKLWrUuW"
      tags               = "monitoring"
    }
  }
}



variable "database_password" {
  default = "dceM1Nu0w7zIItmv"
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
