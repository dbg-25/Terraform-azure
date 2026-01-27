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
    name = my_rules
    {
        port = "80"
        name = "Allow-HTTP"
        direction = "inbound"
    },
    {
      port = "22"
      name = "allow-tcp"
      direction = "outbound"
  }}))

}


resource "azurerm_network_security_group" "MyNSG" {
  name = "NSG4L"
  location = "Canada Central"
  resource_group_name = "RG1"

  dynamic "rules" {
    for_each = var.rules
    content {
      port = var.rules.port
      name = var.rules.name
      direction = var.rules.direction
    }
}
}