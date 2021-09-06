# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.73.0"
    }
  }
  # backend "azurerm" {
  #   resource_group_name = "tstate"
  #   container_name      = "tstate"
  #   key                 = "terraform.tfstate"
  # }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Configure the Microsoft Azure Provider
resource "azurerm_resource_group" "resource_group" {
  name     = local.resource_group_name
  location = local.location
  tags = merge({
    },
    local.default_tag
  )
}

# Azure DNS
resource "azurerm_dns_zone" "public" {
  name                = local.domain_name
  resource_group_name = azurerm_resource_group.resource_group.name
  tags = merge({
    Name    = "public-dns-zone"
    Service = "common"
    },
    local.default_tag
  )
}

# Virtual Network
module "network" {
  source = "./modules/network"

  location             = azurerm_resource_group.resource_group.location
  resource_group_name  = azurerm_resource_group.resource_group.name
  subnet_parameters    = local.subnets
  virtual_network_name = "VirtualNetwork"
  tags                 = local.default_tag
}

# Server VM
module "server" {
  source = "./services/server"

  service_name        = "seerver"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  private_subnet_id   = module.network.subnet_ids.private_subnet
  public_subnet_id    = module.network.subnet_ids.public_subnet
  vm_parameters       = local.server
  dns_zone_name       = azurerm_dns_zone.public.name
  tags                = local.default_tag
}

# jumpbox VM
module "jumpbox" {
  source = "./modules/vm/jumpbox/"

  service_name        = "jumpbox"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  public_subnet_id    = module.network.subnet_ids.jumpbox_subnet
  vm_parameters       = local.jumpbox
  tags                = local.default_tag
}