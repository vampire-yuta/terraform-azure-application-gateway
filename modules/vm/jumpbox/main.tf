resource "azurerm_public_ip" "public_ip" {
  name                = "${var.service_name}-public-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"

  tags = merge({
    Name    = "${var.service_name}-public-ip"
    Service = var.service_name
    },
    var.tags
  )
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.service_name}-network-interface"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "public"
    subnet_id                     = var.public_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = merge({
    Name    = "${var.service_name}-network-interface"
    Service = var.service_name
    },
    var.tags
  )
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.service_name}-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_parameters["vm_size"]
  admin_username      = var.vm_parameters["username"]
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = var.vm_parameters["username"]
    public_key = var.vm_parameters["public_key"]
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.service_name}-storage-os-disk"
  }

  source_image_reference {
    publisher = var.vm_parameters.source_image_reference["publisher"]
    offer     = var.vm_parameters.source_image_reference["offer"]
    sku       = var.vm_parameters.source_image_reference["sku"]
    version   = var.vm_parameters.source_image_reference["version"]
  }

  tags = merge({
    Name    = "${var.service_name}-vm"
    Service = var.service_name
    },
    var.tags
  )
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.service_name}-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags = merge({
    Name    = "${var.service_name}-nsg"
    Service = var.service_name
    },
    var.tags
  )
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "ssh"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
