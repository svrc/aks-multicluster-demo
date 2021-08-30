resource "azurerm_virtual_network" "platform" {
  name                = "${var.environment_name}-platform"
  depends_on          = [azurerm_resource_group.platform]
  resource_group_name = azurerm_resource_group.platform.name
  address_space       = [var.vnet_cidr]
  location            = var.location


  tags = merge(
    var.tags,
    { name = "${var.environment_name}-platform" },
  )
}


resource "azurerm_subnet" "management" {
  name = "${var.environment_name}-management-subnet"

  enforce_private_link_endpoint_network_policies = true
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.platform.name
  address_prefix       = var.management_subnet_cidr

}

resource "azurerm_subnet_network_security_group_association" "jumpbox" {
  subnet_id                 = azurerm_subnet.management.id
  network_security_group_id = azurerm_network_security_group.jumpbox.id

  depends_on = [
    azurerm_subnet.management,
    azurerm_network_security_group.jumpbox
  ]
}

resource "azurerm_subnet" "workloads" {
  name = "${var.environment_name}-workloads-subnet"

  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.platform.name
  address_prefix       = var.workloads_subnet_cidr

}

# resource "azurerm_subnet_network_security_group_association" "workloads" {
#   subnet_id                 = azurerm_subnet.workloads.id
#   network_security_group_id = azurerm_network_security_group.platform-vms.id

#   depends_on = [
#     azurerm_subnet.workloads,
#     azurerm_network_security_group.platform-vms
#   ]
# }
