resource "azurerm_network_interface" "nic" {
  name                = "${var.service_name}-network-interface"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "${var.service_name}-internal"
    subnet_id                     = var.private_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge({
    Name    = "${var.service_name}-network-interface"
    Service = var.service_name
    },
    var.tags
  )
}

resource "azurerm_virtual_machine" "vm" {
  name                = "${var.service_name}-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  vm_size             = var.vm_parameters["vm_size"]
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]


  storage_os_disk {
    name            = azurerm_managed_disk.root.name
    os_type         = "Linux"
    managed_disk_id = azurerm_managed_disk.root.id
    create_option   = "Attach"
  }

  tags = merge({
    Name    = "${var.service_name}-vm"
    Service = var.service_name
    },
    var.tags
  )
}

resource "azurerm_managed_disk" "root" {
  name                 = "${var.service_name}-root-disk"
  resource_group_name  = var.resource_group_name
  location             = var.location
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Copy"
  os_type              = "Linux"
  source_resource_id   = var.snapshot_disk_id

  tags = merge({
    Name    = "${var.service_name}-root-disk"
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

resource "azurerm_network_security_rule" "http" {
  name                        = "http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
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
