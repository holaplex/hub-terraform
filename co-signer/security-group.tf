#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
resource "azurerm_network_security_group" "nsg" {
  name                = local.values.securityGroup.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  #inbound rules
  dynamic "security_rule" {
    for_each = { for index, entry in local.sg_outbounds : "${entry.ip_address}.${entry.description}.${entry.port_range}" => merge(entry, { index = index }) }

    content {
      name                       = "allow_inbound_${security_rule.value.index}"
      priority                   = 200 + security_rule.value.index
      description                = security_rule.value.description
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = security_rule.value.ip_address
      source_port_range          = "*"
      destination_port_range     = security_rule.value.port_range
      destination_address_prefix = "*"

    }
  }

  #outbound rules
  dynamic "security_rule" {
    for_each = { for index, entry in local.sg_outbounds : "${entry.ip_address}.${entry.description}.${entry.port_range}" => merge(entry, { index = index }) }

    content {
      name                       = "allow_outbound_${security_rule.value.index}"
      priority                   = 400 + security_rule.value.index
      description                = security_rule.value.description
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefix      = "*"
      destination_port_range     = security_rule.value.port_range
      destination_address_prefix = security_rule.value.ip_address
    }
  }
}

