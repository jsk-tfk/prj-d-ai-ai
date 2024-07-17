
terraform {
  required_version = ">= 1.5.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.11.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "3.87.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}
