# https://registry.terraform.io/providers/hashicorp/google/latest/docs
provider "google" {
  project = local.values.project.name
  region  = local.values.vpc.region
}

# https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    bucket = "stage-holaplex-hub-tf-state"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}
