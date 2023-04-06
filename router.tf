# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router
resource "google_compute_router" "router" {
  name    = local.values.router.name
  region  = local.values.vpc.region
  network = google_compute_network.main.id
}
