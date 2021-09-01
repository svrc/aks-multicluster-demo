

resource "azurerm_user_assigned_identity" "control-plane-identity" {
  name = "tanzu-umi"
  resource_group_name  = azurerm_resource_group.platform.name
  location             = var.location 
  
     
}

resource "azurerm_kubernetes_cluster" "control-plane" {
  name                    = "${var.environment_name}-control-plane-aks"
  location                = var.location
  resource_group_name     = azurerm_resource_group.platform.name
  dns_prefix              = "${var.environment_name}-cp"
  private_cluster_enabled = true
  
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v3"
    vnet_subnet_id = azurerm_subnet.management.id
  }

  network_profile {
    network_plugin = "kubenet"
    network_policy = "calico"
    service_cidr = "10.245.0.0/16"
    dns_service_ip = "10.245.0.10"
    docker_bridge_cidr = "172.17.0.1/24"
  }

  identity {
    type = "UserAssigned"
	user_assigned_identity_id = azurerm_user_assigned_identity.control-plane-identity.id
  }

  tags = merge(
    var.tags,
    { name = "${var.environment_name}-control-plane-aks" },
  )
} 

resource "azurerm_kubernetes_cluster_node_pool" "control-plane" {
  name                  = "workers"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.control-plane.id
  vm_size               = "Standard_D4s_v3"
  availability_zones    = [1, 2, 3]
  enable_auto_scaling   = true
  os_disk_size_gb       = 1024
  min_count             = 3
  max_count             = 6
  vnet_subnet_id = azurerm_subnet.management.id
  tags = merge(
    var.tags,
    { name = "${var.environment_name}-control-plane-aks-workers" },
  )
     lifecycle {
    ignore_changes = [
	 node_labels, node_taints
	]
  }
  
}
