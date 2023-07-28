# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster
resource "google_container_cluster" "primary" {
  name                     = local.values.kubernetes.name
  location                 = local.values.vpc.region
  node_locations           = local.values.kubernetes.zones
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.main.self_link
  subnetwork               = google_compute_subnetwork.private.self_link
  logging_service          = "none"
  monitoring_service       = "none"
  networking_mode          = "VPC_NATIVE"

  addons_config {
    http_load_balancing {
      disabled = !local.values.kubernetes.loadBalancer.enabled
    }
    horizontal_pod_autoscaling {
      disabled = !local.values.kubernetes.autoscaling.enabled
    }
    network_policy_config {
      disabled = !local.values.kubernetes.networkPolicies.enabled
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${local.values.project.name}.svc.id.goog"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-service-range"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  network_policy {
    enabled  = local.values.kubernetes.networkPolicies.enabled
    provider = "CALICO"
  }

  lifecycle {
    ignore_changes = [
      node_version,
    ]
  }

}
