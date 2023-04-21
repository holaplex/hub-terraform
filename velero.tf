#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam_custom_role
resource "google_project_iam_custom_role" "velero" {
  role_id     = local.values.kubernetes.backups.service.name
  title       = title(local.values.kubernetes.backups.service.name)
  description = format("Role for %s", local.values.kubernetes.backups.service.name)

  permissions = [
    "iam.serviceAccounts.signBlob",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.get",
    "storage.objects.list",
    "compute.disks.get",
    "compute.disks.create",
    "compute.disks.createSnapshot",
    "compute.snapshots.get",
    "compute.snapshots.create",
    "compute.snapshots.useReadOnly",
    "compute.snapshots.delete",
    "compute.zones.get"
  ]
}

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_member
resource "google_project_iam_member" "velero_custom_role" {
  project = local.values.project.name
  role    = "projects/${local.values.project.name}/roles/${local.values.kubernetes.backups.service.name}"
  member  = "serviceAccount:${google_service_account.velero.email}"
}

resource "google_project_iam_member" "workload_identity_user" {
  project = local.values.project.name
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${local.values.project.name}.svc.id.goog[${local.values.kubernetes.backups.service.namespace}/${local.values.kubernetes.backups.service.name}]"
}

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
resource "google_storage_bucket" "velero" {
  name          = local.values.kubernetes.backups.bucket.name
  project       = local.values.project.name
  location      = local.values.kubernetes.backups.bucket.location
  storage_class = local.values.kubernetes.backups.bucket.storageClass

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
resource "google_storage_bucket_iam_binding" "velero_object_admin" {
  bucket = google_storage_bucket.velero.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.velero.email}",
  ]
}
