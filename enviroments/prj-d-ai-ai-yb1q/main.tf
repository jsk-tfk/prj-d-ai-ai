#terraform {
#  backend "gcs" {
#    bucket = "anixe-terraform-state"
#    prefix = "fti-drive/wheels/acceptance"
#  }
#}


resource "google_project_service" "project" {
  for_each = toset([
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com"
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
      image = "europe-central2-docker.pkg.dev/prj-d-ai-ai-yb1q/bydgoszcz-ai/bydgoszcz-ai-image"

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

resource "google_sql_database_instance" "instance" {
  name             = "cloudrun-sql"
  region           = var.gce_region
  database_version = "POSTGRES_16"
  settings {
    tier = var.database_machine_type
  }

  deletion_protection  = "true"
}