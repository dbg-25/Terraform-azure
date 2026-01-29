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



variable "team_access" {
  type = list(object({
    team_name          = string
    object_id          = string
    secret_permissions = list(string)
  }))

  default = [
    {
      team_name          = "Admins"
      object_id          = "11111111-1111-1111-1111-111111111111"
      secret_permissions = ["Get", "List", "Set", "Delete"]
    },
    {
      team_name          = "Developers"
      object_id          = "22222222-2222-2222-2222-222222222222"
      secret_permissions = ["Get", "List"]
    }
  ]
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "vault-rg"
  location = "Canada Central"
}

resource "azurerm_key_vault" "main" {
  name                = "my-app-vault-xyz"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

dynamic "access_policy" {
  for_each = var.team_access
  iterator = team

  content {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = team.value.object_id
    secret_permissions = team.value.secret_permissions

  }
}

}

variable "subnet_config" {
  type = map(object({
    cidr_range = string
    nsg_id     = string
  }))

  default = {
    "Frontend" = {
      cidr_range = "10.0.1.0/24"
      nsg_id     = "/subscriptions/.../nsg-front"
    },
    "Backend" = {
      cidr_range = "10.0.2.0/24"
      nsg_id     = "/subscriptions/.../nsg-back"
    }
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "production-vnet"
  location            = "Canada Central"
  resource_group_name = "Networking-RG"
  address_space       = ["10.0.0.0/16"]

  dynamic "subnet"{
    for_each = var.subnet_config
    iterator = sub

    content {
      name = sub.Key
      address_prefixes = sub.value.cidr_range
      security_group = sub.value.nsg_id
    }
  }



}