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


variable "rules" {
  type = list(object({
    port      = string
    name      = string
    direction = string
    priority  = number # Added priority as it is required for NSGs
  }))

  default = [
    {
      port      = "80"
      name      = "Allow-HTTP"
      direction = "Inbound"
      priority  = 100
    },
    {
      port      = "22"
      name      = "Allow-SSH"
      direction = "Inbound" # Fixed direction (Outbound for SSH usually doesn't make sense for ingress rules here)
      priority  = 110
    }
  ]
}


resource "azurerm_network_security_group" "MyNSG" {
  name = "NSG4L"
  location = "Canada Central"
  resource_group_name = "RG1"

  dynamic "security_rules" {
    for_each = var.rules
    content {
      port = security_rules.value.port
      name = security_rules.value.name
      direction = security_rules.value.direction
    }
}
}