#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb
resource "azurerm_lb" "lb" {
  name                = local.values.loadBalancer.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "frontend-config"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip
resource "azurerm_public_ip" "public_ip" {
  name                = "public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool
resource "azurerm_lb_backend_address_pool" "bap" {
  name            = local.values.loadBalancer.backend.addressPool.name
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_network_interface_backend_address_pool_association" "bap_vm_association" {
  ip_configuration_name   = "${local.values.virtualMachine.name}-ip-config"
  network_interface_id    = azurerm_network_interface.nic.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.bap.id
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule
resource "azurerm_lb_rule" "ssh_rule" {
  name                           = "ssh-rule"
  loadbalancer_id                = azurerm_lb.lb.id
  frontend_ip_configuration_name = "frontend-config"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bap.id]
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 5
}
