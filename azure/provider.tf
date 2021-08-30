provider "azurerm" {
  environment     = var.cloud_name
  features {}
}

terraform {
  required_version = ">= 0.12.0"
}

