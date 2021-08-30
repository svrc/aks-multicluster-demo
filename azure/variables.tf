variable "subscription_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "environment_name" {
  type = string
}

variable "location" {
  type = string
}

variable "hosted_zone" {
  description = "Hosted zone name (e.g. foo.example.com)"
  type        = string
}

variable "jumpbox_vm_size" {
  type = string
  default = "Standard_D2s_v3"
}

variable "cloud_name" {
  description = "The Azure cloud environment to use. Available values at https://www.terraform.io/docs/providers/azurerm/#environment"
  default     = "public"
  type        = string
}

variable "tags" {
  description = "Key/value tags to assign to all resources."
  default     = {}
  type        = map(string)
}

variable "vnet_cidr" {
  default = "10.0.0.0/16"
  type    = string
}

variable "management_subnet_cidr" {
  default = "10.0.8.0/26"
  type    = string
}



variable "workloads_subnet_cidr" {
  default = "10.0.4.0/22"
  type    = string
}

variable "iaas_configuration_environment_azurecloud" {
  default = "AzureCloud"
  type    = string
}