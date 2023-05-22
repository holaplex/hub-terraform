resource "azurerm_virtual_machine" "vm" {
  name                  = local.values.virtualMachine.name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = local.values.virtualMachine.type

  storage_os_disk {
    name              = "co-signer-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = local.values.virtualMachine.diskSizeGb
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = local.values.virtualMachine.image.sku
    version   = local.values.virtualMachine.image.version
  }


  os_profile {
    computer_name  = local.values.virtualMachine.hostname
    admin_username = local.values.virtualMachine.adminUsername
    admin_password = random_password.password.result
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${local.values.virtualMachine.adminUsername}/.ssh/authorized_keys"
      key_data = local.values.virtualMachine.ssh_public_key
    }
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "${local.values.virtualMachine.name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${local.values.virtualMachine.name}-ip-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "random_password" "password" {
  length  = 30
  special = false
}
