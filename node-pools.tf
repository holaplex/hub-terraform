# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "kubernetes" {
  account_id = "kubernetes"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool
resource "google_container_node_pool" "main" {
  name       = local.values.kubernetes.nodePool.name
  cluster    = google_container_cluster.primary.id
  node_count = local.values.kubernetes.nodePool.nodeCount

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = local.values.kubernetes.nodePool.autoscaling.min
    max_node_count = local.values.kubernetes.nodePool.autoscaling.max
  }

  node_config {
    preemptible  = false
    machine_type = local.values.kubernetes.nodePool.machineType
    disk_size_gb = local.values.kubernetes.nodePool.diskSizeGb
    disk_type    = "pd-ssd"

    labels = {
      environment = local.values.kubernetes.environment
    }

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

