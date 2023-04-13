resource "azurerm_resource_group" "rg" {
  name     = local.values.resourceGroup.name
  location = local.values.resourceGroup.location
}
