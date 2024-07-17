
terraform {
  required_version = ">= 1.6.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.11.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "3.87.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.14.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }
  }
}
