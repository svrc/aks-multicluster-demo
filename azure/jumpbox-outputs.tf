locals {
  stable_config_jumpbox = {
    tenant_id        = var.tenant_id
    subscription_id  = var.subscription_id
    client_id        = var.client_id
    client_secret    = var.client_secret
    location         = var.location
    environment_name = var.environment_name
    cloud_name       = var.cloud_name

    network_name        = azurerm_virtual_network.platform.name
    resource_group_name = azurerm_resource_group.platform.name

    management_subnet_name    = azurerm_subnet.management.name
    management_subnet_id      = azurerm_subnet.management.id
    management_subnet_cidr    = azurerm_subnet.management.address_prefix
    management_subnet_gateway = cidrhost(azurerm_subnet.management.address_prefix, 1)
    management_subnet_range   = cidrhost(azurerm_subnet.management.address_prefix, 10)


    jumpbox_security_group_name  = azurerm_network_security_group.jumpbox.name
    jumpbox_ssh_private_key          = tls_private_key.jumpbox_ssh.private_key_pem
    jumpbox_ssh_public_key           = tls_private_key.jumpbox_ssh.public_key_openssh
    jumpbox_private_ip           = cidrhost(azurerm_subnet.management.address_prefix, 5)
    jumpbox_public_ip            = azurerm_public_ip.jumpbox.ip_address
  #  jumpbox_dns                  = "${azurerm_dns_a_record.jumpbox.name}.${azurerm_dns_a_record.jumpbox.zone_name}"

    iaas_configuration_environment_azurecloud = var.iaas_configuration_environment_azurecloud

   # platform_vms_security_group_name = azurerm_network_security_group.platform-vms.name

    workloads_subnet_name    = azurerm_subnet.workloads.name
    workloads_subnet_id      = azurerm_subnet.workloads.id
    workloads_subnet_cidr    = azurerm_subnet.workloads.address_prefix
    workloads_subnet_gateway = cidrhost(azurerm_subnet.workloads.address_prefix, 1)
    workloads_subnet_range   = cidrhost(azurerm_subnet.workloads.address_prefix, 10)

    control_plane_kubeconfig = azurerm_kubernetes_cluster.control-plane.kube_config_raw
    cluster1_kubeconfig = azurerm_kubernetes_cluster.cluster1.kube_config_raw
    cluster2_kubeconfig = azurerm_kubernetes_cluster.cluster2.kube_config_raw
    
  }
}

output "stable_config_jumpbox" {
  value     = jsonencode(local.stable_config_jumpbox)
  sensitive = true
}
