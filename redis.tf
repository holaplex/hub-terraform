# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/redis_instance
resource "google_redis_instance" "redis" {
  for_each = {
    for index, instance in local.values.redisInstances :
    instance.name => instance
  }

  name           = each.value.name
  display_name   = each.value.name
  region         = local.values.vpc.region
  tier           = each.value.tier
  memory_size_gb = each.value.memorySizeGb

  authorized_network = google_compute_network.main.id

  redis_version = "REDIS_7_0"

  maintenance_policy {
    weekly_maintenance_window {
      day = "TUESDAY"
      start_time {
        hours   = 0
        minutes = 30
        seconds = 0
        nanos   = 0
      }
    }
  }
  lifecycle {
    ignore_changes = [
      maintenance_schedule,
    ]
  }
}

output "redis_instance_ips" {
  value = {
    for instance in google_redis_instance.redis :
    instance.name => instance.host
  }
}
