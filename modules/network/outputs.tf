output "subnet_ids" {
  value = tomap({
    for i, subnet in azurerm_subnet.subnet : i => subnet.id
  })
}


output "virtual_network_id" {
  value = azurerm_virtual_network.vnet.id

}