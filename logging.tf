#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_member
resource "google_project_iam_member" "logging_custom_role" {
  project = local.values.project.name
  role    = "projects/${local.values.project.name}/roles/${local.values.kubernetes.logging.service.name}"
  member  = "serviceAccount:${google_service_account.logging.email}"
}

resource "google_project_iam_member" "logs_workload_identity_user" {
  project = local.values.project.name
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${local.values.project.name}.svc.id.goog[${local.values.kubernetes.logging.service.name}/${local.values.kubernetes.logging.service.namespace}]"
}

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
resource "google_storage_bucket" "logging" {
  name          = local.values.kubernetes.logging.bucket.name
  project       = local.values.project.name
  location      = local.values.kubernetes.logging.bucket.location
  storage_class = local.values.kubernetes.logging.bucket.storageClass

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age        = 60
      with_state = "ANY"
    }
  }
}

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam#google_storage_bucket_iam_binding
resource "google_storage_bucket_iam_binding" "logging_object_admin" {
  bucket = google_storage_bucket.logging.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.logging.email}",
  ]
}
