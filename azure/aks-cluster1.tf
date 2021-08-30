resource "azurerm_subnet" "cluster1" {
  name = "${var.environment_name}-cluster1-subnet"


  enforce_private_link_endpoint_network_policies = true
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.platform.name
  address_prefix       = cidrsubnet("10.0.0.0/16", 8, 10)
}

resource "azurerm_kubernetes_cluster" "cluster1" {
  name                    = "${var.environment_name}-cluster1-aks"
  location                = var.location
  resource_group_name     = azurerm_resource_group.platform.name
  dns_prefix              = "${var.environment_name}-c1"
  private_cluster_enabled = true
  
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v3"
    vnet_subnet_id = azurerm_subnet.cluster1.id
  }

  network_profile {
    network_plugin = "kubenet"
    network_policy = "calico"
    service_cidr = "10.245.0.0/16"
    dns_service_ip = "10.245.0.10"
    docker_bridge_cidr = "172.17.0.1/24"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(
    var.tags,
    { name = "${var.environment_name}-cluster1-aks" },
  )
} 

resource "azurerm_kubernetes_cluster_node_pool" "cluster1" {
  name                  = "workers"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.cluster1.id
  vm_size               = "Standard_D4s_v3"
  availability_zones    = [1, 2, 3]
  enable_auto_scaling   = true
  os_disk_size_gb       = 1024
  min_count             = 3
  max_count             = 6
  vnet_subnet_id = azurerm_subnet.cluster1.id
  tags = merge(
    var.tags,
    { name = "${var.environment_name}-cluster1-aks-workers" },
  )
}
