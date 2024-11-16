terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "terraformgitactions"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    tenant_id            = "${ secrets.AZURE_TENANT_ID }"
    subscription_id      = "${ secrets.AZURE_SUBSCRIPTION_ID }"
  }
}