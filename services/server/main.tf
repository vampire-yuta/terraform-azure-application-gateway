module "vm" {
  source = "../../modules/vm/linux/"

  service_name        = var.service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  private_subnet_id   = var.private_subnet_id
  vm_parameters       = var.vm_parameters
  tags                = var.tags
}

module "applicationgateway" {
  source = "../../modules/applicationgateway/"

  service_name         = var.service_name
  location             = var.location
  resource_group_name  = var.resource_group_name
  network_interface_id = module.vm.vm_netowrk_interface_id
  subnet               = var.public_subnet_id
  dns_zone_name        = var.dns_zone_name
  tags                 = var.tags
}
