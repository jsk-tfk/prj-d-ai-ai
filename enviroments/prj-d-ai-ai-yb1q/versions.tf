
terraform {
  required_version = ">= 1.5.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.35.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "5.0.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}
