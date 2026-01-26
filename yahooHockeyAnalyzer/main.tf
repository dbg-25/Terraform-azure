terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.0"
    }

  }
  backend "azurerm" {
    resource_group_name  = "stateFilesRG"
    storage_account_name = "tfstatestoreaccgnrhoczs"
    container_name       = "terraformstoragecontainer"
    key                  = "yahooHockeyAnalyzer.tfstate"
  }
}

provider "azurerm" {
  features {

  }
  subscription_id = "d5bdc6bd-69ad-4216-8136-44d024273eb6"
}

resource "random_string" "rand" {
  length  = 8
  special = false
  upper   = false
}


resource "azurerm_resource_group" "rg-hockey-analyzer" {
  name     = var.myRg
  location = var.location
}

resource "azurerm_service_plan" "hockey-analyzer-sp" {
  name                = "hockey-analyzer"
  resource_group_name = azurerm_resource_group.rg-hockey-analyzer.name
  location            = var.location
  os_type             = var.OSType
  sku_name            = var.sku
}


resource "azurerm_storage_account" "hockey-analyzer-storage" {
  name                     = "hastorage${random_string.rand.result}"
  resource_group_name      = azurerm_resource_group.rg-hockey-analyzer.name
  account_tier             = var.acc-tier
  location                 = var.location
  account_replication_type = var.repl-type
}

resource "azurerm_storage_container" "hockey-analyzer-container" {
  name                 = "hockey-analyzer-container"
  storage_account_name = azurerm_storage_account.hockey-analyzer-storage.name
}

resource "azurerm_linux_function_app" "linux_function_app" {
  name                = "hockey-analyzer-app${random_string.rand.result}"
  resource_group_name = azurerm_resource_group.rg-hockey-analyzer.name
  location            = var.location

  service_plan_id            = azurerm_service_plan.hockey-analyzer-sp.id
  storage_account_name       = azurerm_storage_account.hockey-analyzer-storage.name
  storage_account_access_key = azurerm_storage_account.hockey-analyzer-storage.primary_access_key

  site_config {
    application_stack {
      python_version = "3.9"
    }
  }

}