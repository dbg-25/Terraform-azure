
#Terraform Providers
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.0"
    }
  }
  backend "azurerm" {
      resource_group_name   = "stateFilesRG"
      storage_account_name  = "tfstatestoreaccgnrhoczs"
      container_name        = "terraformstoragecontainer"
      key                   = "setup.tfstate"
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

#string to append to storage account to ensure uniqueness
resource "random_string" "rand" {
  length  = 8
  special = false
  upper   = false
}

#RG creation
resource "azurerm_resource_group" "stateFilesRG" {
  name     = "stateFilesRG"
  location = var.location
}

# Create a storage account and a container for Terraform state files
resource "azurerm_storage_account" "stateStorageAccount" {
  account_tier             = var.storageAccountTier
  account_replication_type = var.storageAccountReplicationType
  resource_group_name      = azurerm_resource_group.stateFilesRG.name
  location                 = var.location
  name                     = "tfstatestoreacc${random_string.rand.result}"

}

#Storage container for state files
resource "azurerm_storage_container" "stateStorageContainer" {
  name                  = "terraformstoragecontainer"
  storage_account_name  = azurerm_storage_account.stateStorageAccount.name
  container_access_type = "private"
}

#monitor group to alert when budget is reached
resource "azurerm_monitor_action_group" "admins" {
  name                = "adminAlerts"
  resource_group_name = azurerm_resource_group.stateFilesRG.name
  short_name          = "adminAlerts"
  email_receiver {
    email_address = var.adminReceiver
    name          = "sendToAdmin"
  }
}

#date to pull real ID
data "azurerm_subscription" "current" {}


#budget to watch and ensure sub does not exceed threshold
resource "azurerm_consumption_budget_subscription" "tfSTateBudget" {
  name            = "tfStateBudget"
  subscription_id = data.azurerm_subscription.current.id
  amount          = 5
  time_period {
    start_date = "2026-01-01T00:00:00Z"
  }
  notification {
    enabled        = true
    threshold      = 90
    operator       = "EqualTo"
    threshold_type = "Forecasted"
    contact_groups = [azurerm_monitor_action_group.admins.id]
  }
}