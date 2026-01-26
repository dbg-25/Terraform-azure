terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.58.0"
    }
  }
}

provider "azurerm" {
  features {}
}


variable "networks" {
  type = list(object({
    name = string
    cidr = string
  }))

  default = [{
    name = "Default"
    cidr = "10.10.10.0/24"
  }]
}


resource "azurerm_virtual_network" "myNet" {
    for_each = { for item in var.networks: item.name => item}
    name = each.value.name
    address_space = each.value.cidr
    location = "canada central"
    resource_group_name = "test-rg"
}
