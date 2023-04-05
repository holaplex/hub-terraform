#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance
resource "google_sql_database_instance" "instance" {
  for_each = {
    for index, instance in local.values.sqlInstances :
    instance.name => instance
  }
  name             = each.value.name
  region           = local.values.vpc.region
  database_version = "POSTGRES_14"

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier                  = each.value.machineType
    disk_size             = each.value.diskSizeGb
    disk_autoresize       = true
    disk_autoresize_limit = 200

    availability_type = "REGIONAL"
    activation_policy = "ALWAYS"

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.main.id
      enable_private_path_for_google_cloud_services = true
    }
    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
    }
    insights_config {
      query_insights_enabled = true
    }
  }
}

resource "google_sql_database" "database" {
  for_each = {
    for index, instance in local.values.sqlInstances :
    instance.name => instance
  }
  name      = each.value.database
  instance  = each.value.name
  charset   = "utf8"
  collation = "en_US.UTF8"
}

resource "google_sql_user" "users" {
  for_each = {
    for index, instance in local.values.sqlInstances :
    instance.name => instance

  }
  name     = each.value.username
  instance = each.value.name
  password = random_password.password.result
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

