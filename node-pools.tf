# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
resource "google_service_account" "kubernetes" {
  account_id = "kubernetes"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool
resource "google_container_node_pool" "node_pools" {
  for_each = {
    for node_pool in local.values.kubernetes.nodePools :
    node_pool.name => node_pool
  }

  name           = each.value.name
  cluster        = google_container_cluster.primary.id
  location       = google_container_cluster.primary.location
  node_locations = each.value.zones
  node_count     = each.value.nodeCount

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = each.value.autoscaling.min
    max_node_count = each.value.autoscaling.max
  }

  node_config {
    preemptible  = false
    machine_type = each.value.machineType
    disk_size_gb = each.value.diskSizeGb
    disk_type    = "pd-ssd"

    labels = {
      environment = local.values.kubernetes.environment
    }

    tags = ["${local.values.kubernetes.name}-node"]

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
