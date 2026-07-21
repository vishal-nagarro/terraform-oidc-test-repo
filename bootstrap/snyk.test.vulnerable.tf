# NOTE: This file intentionally contains insecure IaC configurations.
# Purpose: validate that Snyk IaC scanning is correctly detecting findings in this repo.
# Remove this file once the Snyk scan verification is complete.

resource "azurerm_network_security_group" "snyk_test" {
  name                = "snyk-test-nsg"
  location            = var.location
  resource_group_name = module.resource_group["agents"].name

  security_rule {
    name                       = "AllowSSHFromAnywhere"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowRDPFromAnywhere"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_storage_account" "snyk_test" {
  name                            = "snyktestinsecurestorage"
  location                        = var.location
  resource_group_name             = module.resource_group["state"].name
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  enable_https_traffic_only       = false
  min_tls_version                 = "TLS1_0"
  allow_nested_items_to_be_public = true
  public_network_access_enabled   = true

  network_rules {
    default_action = "Allow"
  }
}

resource "azurerm_key_vault" "snyk_test" {
  name                        = "snyk-test-kv"
  location                    = var.location
  resource_group_name         = module.resource_group["state"].name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  enable_rbac_authorization   = true

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}
