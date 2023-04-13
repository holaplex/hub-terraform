locals {
  values = yamldecode(file("${path.module}/values.yaml"))
  sg_inbounds = distinct(flatten([
    for each_rule in local.values.securityGroup.rules.inbounds : [
      for port in each_rule.ports : {
        ip_addres   = each_rule.ip_address
        description = each_rule.description
        port_range  = port
      }
  ]]))
  sg_outbounds = distinct(flatten([
    for each_rule in local.values.securityGroup.rules.outbounds : [
      for port in each_rule.ports : {
        ip_address  = each_rule.ip_address
        description = each_rule.description
        port_range  = port
      }
  ]]))
}
