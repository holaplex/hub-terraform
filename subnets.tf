# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork
resource "google_compute_subnetwork" "private" {
  name                     = local.values.subnetwork.name
  ip_cidr_range            = local.values.subnetwork.cidrRange
  region                   = local.values.vpc.region
  network                  = google_compute_network.main.id
  private_ip_google_access = local.values.subnetwork.privateIpGoogleAccess

  secondary_ip_range {
    range_name    = "k8s-pod-range"
    ip_cidr_range = local.values.kubernetes.networkRanges.pods
  }
  secondary_ip_range {
    range_name    = "k8s-service-range"
    ip_cidr_range = local.values.kubernetes.networkRanges.services
  }
}
