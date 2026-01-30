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

variable "account_tier" {
    type = string
}
variable "resource_group_name" {
    type = string
}
variable "account_replication_type" {
    type = string
}
variable "location" {
    type = string
}
variable "name" {
    type = string
}

resource "azurerm_storage_account" "storage_account" {
    account_tier = var.account_tier
    resource_group_name = var.resource_group_name
    account_replication_type = var.account_replication_type
    location = var.location
    name = var.name
}