locals {
  location = "East US"
  azrg     = azurerm_resource_group.thudlab-rg.name
  vnetname = azurerm_virtual_network.thudlab-vnet.name
  sbn1     = azurerm_subnet.thudprox-subnet-1.id
  pub1     = azurerm_public_ip.thudprox-ip.id
  nsgname  = azurerm_network_security_group.thudlab-nsg.name
  nsgid    = azurerm_network_security_group.thudlab-nsg.id
}

resource "azurerm_resource_group" "thudlab-rg" {
  name     = "thudlab-rg"
  location = local.location

}

resource "azurerm_virtual_network" "thudlab-vnet" {
  name                = "thudlab-vnet"
  resource_group_name = local.azrg
  location            = local.location
  address_space       = ["10.130.0.0/16"]

}

resource "azurerm_public_ip" "thudprox-ip" {
  name                = "thudprox-ip"
  resource_group_name = local.azrg
  location            = local.location
  allocation_method   = "Static"

}

resource "azurerm_subnet" "thudprox-subnet-1" {
  name                 = "thudprox-subnet-1"
  resource_group_name  = local.azrg
  virtual_network_name = azurerm_virtual_network.thudlab-vnet.name
  address_prefixes     = ["10.130.1.0/24"]

}

resource "azurerm_network_interface" "thudprox-nic-1" {
  name                = "thudprox-nic-1"
  location            = local.location
  resource_group_name = local.azrg

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.sbn1
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = local.pub1
  }
}

resource "azurerm_network_security_group" "thudlab-nsg" {
  name                = "thudlab-nsg"
  resource_group_name = local.azrg
  location            = local.location
}

resource "azurerm_network_security_rule" "thudprox-rule" {
  name                        = "thudprox-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "22"
  destination_port_range      = "22"
  source_address_prefix       = "xxx.xxx.xxx.xxx" #your ip
  destination_address_prefix  = "*"
  resource_group_name         = local.azrg
  network_security_group_name = local.nsgname
}

resource "azurerm_subnet_network_security_group_association" "subnetassociation" {
  subnet_id                 = local.sbn1
  network_security_group_id = local.nsgid
}

resource "azurerm_linux_virtual_machine" "thudprox-vm" {
  name                            = "thudprox-vm"
  resource_group_name             = local.azrg
  location                        = local.location
  size                            = "Standard_B1s"
  admin_username                  = "XXXXXXXXXXX" # your username
  admin_password                  = "xxxxxxxxxxxxxxxxxxxxx" #your password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.thudprox-nic-1.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
