resource "azurerm_public_ip" "jumpbox" {
  name                    = "${var.environment_name}-jumpbox-public-ip"
  location                = var.location
  resource_group_name     = azurerm_resource_group.platform.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30

  tags = merge(
    var.tags,
    { name = "${var.environment_name}-jumpbox-public-ip" },
  )
}

resource "azurerm_network_security_group" "jumpbox" {
  name                = "${var.environment_name}-jumpbox-network-sg"
  location            = var.location
  resource_group_name = azurerm_resource_group.platform.name

  security_rule = [ 
   {
      access                                     = "Allow"
      description                                = ""
      destination_address_prefix                 = "10.0.8.4"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_range                     = "*"
      destination_port_ranges                    = []
      direction                                  = "Inbound"
      name                                       = "ssh"
      priority                                   = 200
      protocol                                   = "TCP"
      source_address_prefix                      = "Internet"
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      source_port_range                          = "*"
      source_port_ranges                         = []
   },
  {
      access                                     = "Allow"
      description                                = ""
      destination_address_prefix                 = "10.0.0.0/16"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_range                     = "*"
      destination_port_ranges                    = []
      direction                                  = "Inbound"
      name                                       = "icmp_google"
      priority                                   = 230
      protocol                                   = "ICMP"
      source_address_prefix                      = "10.150.0.0/20"
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      source_port_range                          = "*"
      source_port_ranges                         = []
   },
   {
      access                                     = "Allow"
      description                                = ""
      destination_address_prefix                 = "10.0.0.0/16"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_range                     = "22"
      destination_port_ranges                    = []
      direction                                  = "Inbound"
      name                                       = "ssh_google"
      priority                                   = 210
      protocol                                   = "TCP"
      source_address_prefix                      = "10.150.0.0/20"
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      source_port_range                          = "*"
      source_port_ranges                         = []
   },
    {
      access                                     = "Allow"
      description                                = ""
      destination_address_prefix                 = "10.0.0.0/16"
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      destination_port_range                     = "443"
      destination_port_ranges                    = []
      direction                                  = "Inbound"
      name                                       = "https_google"
      priority                                   = 211
      protocol                                   = "TCP"
      source_address_prefix                      = "10.150.0.0/20"
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      source_port_range                          = "*"
      source_port_ranges                         = []
   }
  ]
  tags = merge(
    var.tags,
    { name = "${var.environment_name}-jumpbox-network-sg" },
  )
}

resource "tls_private_key" "jumpbox_ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "azurerm_network_interface" "jumpbox_nic" {
    name                        = "${var.environment_name}-jumpbox-nic"
    location                    = var.location
    resource_group_name         = azurerm_resource_group.platform.name

    ip_configuration {
        name                          = "jumpbox-ip-config"
        subnet_id                     = azurerm_subnet.management.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.jumpbox.id
    }
    
    tags = merge(
    var.tags,
    { name = "${var.environment_name}-jumpbox-nic" },
   )  
}


resource "azurerm_linux_virtual_machine" "jumpbox_vm" {
    name                  = "${var.environment_name}-jumpbox-vm"
    location              = var.location
    resource_group_name   = azurerm_resource_group.platform.name
    network_interface_ids = [azurerm_network_interface.jumpbox_nic.id]
    size                  = "${var.jumpbox_vm_size}"

    os_disk {
        name              = "os-disk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "${var.environment_name}-jumpbox-vm"
    admin_username = "tanzu"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "tanzu"
        public_key     = tls_private_key.jumpbox_ssh.public_key_openssh
    }


    tags = merge(
    var.tags,
    { name = "${var.environment_name}-jumpbox-vm" },
   )  
   
   lifecycle { 
    prevent_destroy = true                                                                                                              
   }  
}

resource "null_resource" "jumpbox" {
  
    provisioner "remote-exec" {
      connection {
          user = "tanzu"
          private_key = tls_private_key.jumpbox_ssh.private_key_pem
          host = azurerm_public_ip.jumpbox.ip_address
      } 
      inline = [
        "sudo  curl -L https://carvel.dev/install.sh | sudo bash",
        "curl -LO \"https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\" && sudo mv kubectl /usr/local/bin && sudo chmod +x /usr/local/bin/kubectl",
        "curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.7.6 bash", 
        "echo export PATH=\"$PATH:/home/tanzu/istio-1.7.6/bin\"\\nalias k=kubectl\\nalias kc=\"kubectl config\"\\n >> .bashrc",
        "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
      ]
    }
}
