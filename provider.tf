# https://registry.terraform.io/providers/hashicorp/google/latest/docs
provider "google" {
  project = "prod-holaplex-hub"
  region  = "us-central1"
}

# https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    bucket = "prod-holaplex-hub-tf-state"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}
