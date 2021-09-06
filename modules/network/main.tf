resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
  tags = merge({
    },
    var.tags
  )
}

resource "azurerm_subnet" "subnet" {
  for_each                                       = var.subnet_parameters
  name                                           = lookup(each.value, "name")
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = [lookup(each.value, "cidr_block", null)]
  service_endpoints                              = lookup(each.value, "service_endpoints", null)
  enforce_private_link_endpoint_network_policies = lookup(each.value, "enforce_private_link_endpoint_network_policies", false)
}
