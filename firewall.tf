# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall
resource "google_compute_firewall" "allow_admission_webhooks" {
  name    = "allow-admission-webhooks"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["9443"]
  }

  source_ranges = [google_container_cluster.primary.private_cluster_config[0].master_ipv4_cidr_block]
  target_tags   = ["${local.values.kubernetes.name}-node"]
}
