# Velero - Kubernetes Backups
# External secrets - Secrets management through GCP

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "velero" {
  account_id = "velero"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
resource "google_project_iam_member" "velero" {
  project = local.values.project.name
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.velero.email}"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam
resource "google_service_account_iam_member" "velero" {
  service_account_id = google_service_account.velero.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.values.project.name}.svc.id.goog[velero/velero]"
}

resource "google_service_account" "external-secrets" {
  account_id = "external-secrets"
}

resource "google_project_iam_member" "external-secrets" {
  project = local.values.project.name
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.external-secrets.email}"
}

resource "google_service_account_iam_member" "external-secrets" {
  service_account_id = google_service_account.external-secrets.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.values.project.name}.svc.id.goog[external-secrets/external-secrets]"
}
