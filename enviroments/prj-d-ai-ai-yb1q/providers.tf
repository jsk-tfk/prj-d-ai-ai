provider "google-beta" {
  project = var.gce_project
  region  = var.gce_region
  zone    = var.gce_zone
}

provider "google" {
  project = var.gce_project
  region  = var.gce_region
  zone    = var.gce_zone
}

data "google_client_config" "provider" {}
