locals {
  default_tag = {
    "Env"        = "dev"
    "Automation" = "Terraform"
  }
  resource_group_name = "vamdemic"
  location            = "japaneast"
  vnet_name           = "VirtualNetwork"

  domain_name = "dev-vamdemic.work"
  subnets = {
    public_subnet = {
      name       = "PublicSubnet"
      cidr_block = "10.0.0.0/20"
    }
    private_subnet = {
      name       = "PrivateSubnet"
      cidr_block = "10.0.16.0/20"
    }
    jumpbox_subnet = {
      name       = "JumpboxSubnet"
      cidr_block = "10.0.32.0/20"
    }
  }
  server = {
    vm_size    = "Standard_B1ms"
    hostname   = "server"
    username   = "azureadmin"
    public_key = file("vamdemic.pub")
    source_image_reference = {
      publisher = "canonical"
      offer     = "0001-com-ubuntu-server-focal"
      sku       = "20_04-lts"
      version   = "latest"
    }
  }
  jumpbox = {
    vm_size    = "Standard_B1ls"
    hostname   = "jumpbox"
    username   = "azureadmin"
    public_key = file("vamdemic.pub")
    source_image_reference = {
      publisher = "canonical"
      offer     = "0001-com-ubuntu-server-focal"
      sku       = "20_04-lts"
      version   = "latest"
    }
  }
}

