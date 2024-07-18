#terraform {
#  backend "gcs" {
#    bucket = "anixe-terraform-state"
#    prefix = "fti-drive/wheels/acceptance"
#  }
#}


resource "google_project_service" "project" {
  for_each = toset([
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com"
  ])

  project = var.gce_project
  service = each.key

  disable_on_destroy = false
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
        name = "SECRET_ENV_VAR"
        value_source {
          secret_key_ref {
            secret = google_secret_manager_secret.secret.secret_id
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
  depends_on = [google_secret_manager_secret_version.secret-version-data]
}

data "google_project" "project" {
}

resource "google_secret_manager_secret" "secret" {
  secret_id = "secret-1"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "secret-version-data" {
  secret = google_secret_manager_secret.secret.name
  secret_data = "secret-data"
}

resource "google_secret_manager_secret_iam_member" "secret-access" {
  secret_id = google_secret_manager_secret.secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.secret]
}

resource "google_compute_network" "private_network" {
  name = "ai-network"
}

resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta

  name          = "ai-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.private_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.private_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}
resource "google_sql_database_instance" "instance" {
  name             = "cloudrun-ai-sql"
  region           = var.gce_region
  database_version = "POSTGRES_15"

  depends_on = [google_service_networking_connection.private_vpc_connection]
  settings {
    tier = var.database_machine_type
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.private_network.id
      enable_private_path_for_google_cloud_services = true
    }
  }

  deletion_protection  = "true"
}