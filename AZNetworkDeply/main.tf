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
  type = object({
    name = string
    cidr = string
  })

  default = {
    name = "Default"
    cidr = "10.10.10.0/24"
  }
}


resource azurerm_virtual_network
