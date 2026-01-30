terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.58.0"
    }
  }
}

provider "azurerm" {
  features {
    
  }
}



module "storage_account" {
  source = "./modules/StorageAccount"
  name = "test"
  account_replication_type = "test"
  location = "test"
  account_tier = "test"
  resource_group_name = "test"

}
