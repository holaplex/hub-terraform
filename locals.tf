locals {
  values = yamldecode(file("${path.module}/values.yaml"))
}
