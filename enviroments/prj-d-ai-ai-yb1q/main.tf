#terraform {
#  backend "gcs" {
#    bucket = "anixe-terraform-state"
#    prefix = "fti-drive/wheels/acceptance"
#  }
#}


resource "google_project_service" "project_services" {
  for_each = toset([
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com"
  ])

  project = var.gce_project
  service = each.key

  disable_on_destroy = false
}

module "lb-http" {
  source  = "terraform-google-modules/lb-http/google//modules/serverless_negs"
  version = "~> 10.0"

  name    = var.lb_name
  project = var.gce_project

  ssl                             = var.ssl
  managed_ssl_certificate_domains = [var.domain]
  labels                          = { "example-label" = "cloud-run-ai" }

  backends = {
    default = {
      description = null
      groups = [
        {
          group = google_compute_region_network_endpoint_group.serverless_neg.id
        }
      ]
      enable_cdn = false

      iap_config = {
        enable = false
        #oauth2_client_id     = var.iap_client_id
        #oauth2_client_secret = var.iap_client_secret
      }
      log_config = {
        enable = false
      }
    }
  }
}

resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  provider              = google-beta
  name                  = "serverless-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.gce_region
  cloud_run {
    service = google_cloud_run_v2_service.default.name
  }
}

resource "google_cloud_run_v2_service" "default" {
  name     = "cloudrun-service"
  location = var.gce_region
  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.instance.connection_name]
      }
    }

    containers {
      image = "europe-central2-docker.pkg.dev/prj-d-ai-ai-yb1q/bydgoszcz-ai/bydgoszcz-ai-image:v0.2.0-alpha"
      ports {
        container_port = 8000
      }
      env {
        name = "PROJECT_ID"
        value = "prj-d-ai-ai-yb1q"
      }
      env {
        name  = "INSTANCE_CONNECTION_NAME"
        value = google_sql_database_instance.instance.connection_name
      }
      env {
        name = "DB_USER"
        value_source {
          secret_key_ref {
            secret = google_secret_manager_secret.dbuser.secret_id
            version = "1"
          }
        }
      }
      env {
        name = "DB_PASS"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.dbpass.secret_id
            version = "1"
          }
        }
      }
      env {
        name = "DB_NAME"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.dbname.secret_id
            version = "1"
          }
        }
      }

      volume_mounts {
        name = "cloudsql"
        mount_path = "/cloudsql"
      }
    }
  }

  traffic {
    type = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
  depends_on = [google_secret_manager_secret_version.dbuser_data]
}

data "google_project" "project" {
}

resource "google_cloud_run_service_iam_binding" "default" {
  location = google_cloud_run_v2_service.default.location
  service  = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}

# Create dbuser secret
resource "google_secret_manager_secret" "dbuser" {
  secret_id = "dbusersecret"
  replication {
    auto {}
  }
  depends_on = [google_project_service.project_services["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret_version" "dbuser_data" {
  secret = google_secret_manager_secret.dbuser.name
  secret_data = "secret-data"
}

resource "google_secret_manager_secret_iam_member" "secret-access" {
  secret_id = google_secret_manager_secret.dbuser.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
#  depends_on = [google_secret_manager_secret.dbuser]
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Create dbpass secret
resource "google_secret_manager_secret" "dbpass" {
  secret_id = "dbpasssecret"
  replication {
    auto {}
  }
  depends_on = [google_project_service.project_services["secretmanager.googleapis.com"]]
}

# Attaches secret data for dbpass secret
resource "google_secret_manager_secret_version" "dbpass_data" {
  secret      = google_secret_manager_secret.dbpass.id
  secret_data = random_password.db_password.result
}

# Update service account for dbpass secret
resource "google_secret_manager_secret_iam_member" "secretaccess_compute_dbpass" {
  secret_id = google_secret_manager_secret.dbpass.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com" # Project's compute service account
}


# Create dbname secret
resource "google_secret_manager_secret" "dbname" {
  secret_id = "dbnamesecret"
  replication {
    auto {}
  }
  depends_on = [google_project_service.project_services["secretmanager.googleapis.com"]]
}

# Attaches secret data for dbname secret
resource "google_secret_manager_secret_version" "dbname_data" {
  secret      = google_secret_manager_secret.dbname.id
  secret_data = google_sql_database.database.name
}

# Update service account for dbname secret
resource "google_secret_manager_secret_iam_member" "secretaccess_compute_dbname" {
  secret_id = google_secret_manager_secret.dbname.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com" # Project's compute service account
}
#resource "google_compute_network" "private_network" {
#  name = "ai-network"
#}
#
#resource "google_compute_global_address" "private_ip_address" {
#  provider = google-beta
#
#  name          = "ai-ip-address"
#  purpose       = "VPC_PEERING"
#  address_type  = "INTERNAL"
#  prefix_length = 16
#  network       = google_compute_network.private_network.id
#}
#
#resource "google_service_networking_connection" "private_vpc_connection" {
#  network                 = google_compute_network.private_network.id
#  service                 = "servicenetworking.googleapis.com"
#  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
#  provider = google-beta
#}
#
resource "google_sql_database" "database" {
  name     = "chat"
  instance = google_sql_database_instance.instance.name
}
resource "google_sql_database_instance" "instance" {
  name             = "cloudrun-chat-sql"
  region           = var.gce_region
  database_version = "POSTGRES_15"
  deletion_protection  = "false"

  #depends_on = [google_service_networking_connection.private_vpc_connection]
  settings {
    tier = var.database_machine_type

    database_flags {
      name  = "cloudsql_iam_authentication"
      value = "on"
    }
  }
}
#resource "google_sql_user" "iam_service_account_user" {
#  # Note: for Postgres only, GCP requires omitting the ".gserviceaccount.com" suffix
#  # from the service account email due to length limits on database usernames.
#  name     = trimsuffix(google_service_account.service_account.email)
#  instance = google_sql_database_instance.instance.name
#  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
#}
resource "google_sql_user" "iam_group_user" {
  name     = "ai-users@tfkable.eu"
  instance = google_sql_database_instance.instance.name
  type     = "CLOUD_IAM_GROUP"
}