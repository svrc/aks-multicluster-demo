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
  
  lifecycle {
    ignore_changes = [
	  tags
	]
  }
}




resource "azurerm_subnet" "management" {
  name = "${var.environment_name}-management-subnet"

  enforce_private_link_endpoint_network_policies = true
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.platform.name
  address_prefix       = var.management_subnet_cidr
  lifecycle {
    ignore_changes = [
	  service_endpoints
	]
  }
}

resource "azurerm_subnet_network_security_group_association" "jumpbox" {
  subnet_id                 = azurerm_subnet.management.id
  network_security_group_id = azurerm_network_security_group.jumpbox.id

  depends_on = [
    azurerm_subnet.management,
    azurerm_network_security_group.jumpbox
  ]
}

resource "azurerm_subnet" "cluster1" {
  name = "${var.environment_name}-cluster1-subnet"


  enforce_private_link_endpoint_network_policies = true
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.platform.name
  address_prefix       = cidrsubnet("10.0.0.0/16", 8, 10)
  lifecycle {
    ignore_changes = [
	  service_endpoints
	]
  }
	
}

resource "azurerm_subnet" "cluster2" {
  name = "${var.environment_name}-cluster2-subnet"

  enforce_private_link_endpoint_network_policies = true
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.platform.name
  address_prefix       = cidrsubnet("10.0.0.0/16", 8, 9)
  lifecycle {
    ignore_changes = [
	  service_endpoints
	]
  }

  
}

resource "azurerm_route_table" "platform" {
  name                = "${var.environment_name}-platform-route-table"
  resource_group_name  = azurerm_resource_group.platform.name
  
  location            = var.location

  route {
    name                   = "google"
    address_prefix         = "10.150.0.0/20"
    next_hop_type          = "VirtualNetworkGateway"
  }
  
  lifecycle {
    ignore_changes = [
	 route, tags
	]
  }

}

resource "azurerm_route_table" "cluster1" {
  name                = "${var.environment_name}-cluster1-route-table"
  resource_group_name  = azurerm_resource_group.platform.name
  location            = var.location
  route {
    name                   = "google"
    address_prefix         = "10.150.0.0/20"
    next_hop_type          = "VirtualNetworkGateway"
  }
  
   lifecycle {
    ignore_changes = [
	 route, tags
	]
  }
}

resource "azurerm_route_table" "cluster2" {
  name                = "${var.environment_name}-cluster2-route-table"
  resource_group_name  = azurerm_resource_group.platform.name
  location            = var.location

  route {
    name                   = "google"
    address_prefix         = "10.150.0.0/20"
    next_hop_type          = "VirtualNetworkGateway"
  }
  
   lifecycle {
    ignore_changes = [
	 route, tags
	]
  }
}

resource "azurerm_subnet_route_table_association" "management-route-table" {
  subnet_id      = azurerm_subnet.management.id
  route_table_id = azurerm_route_table.platform.id
}

resource "azurerm_subnet_route_table_association" "cluster2-route-table" {
  subnet_id      = azurerm_subnet.cluster2.id
  route_table_id = azurerm_route_table.cluster2.id
}

resource "azurerm_subnet_route_table_association" "cluster1-route-table" {
  subnet_id      = azurerm_subnet.cluster1.id
  route_table_id = azurerm_route_table.cluster1.id
}
