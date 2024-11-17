#rg
resource "azurerm_resource_group" "rg" {
    name        = "rg-lnx"
    location    = "eastus2"
}

#vnet
resource "azurerm_virtual_network" "vnet" {
  name = "vnet-lnx"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space = ["10.100.0.0/24"]
}

#subnet
resource "azurerm_subnet" "subnet" {
  name = "subnet-lnx"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.100.0.0/24"]
}

#nsg
resource "azurerm_network_security_group" "nsg" {
  name = "nsg-lnx"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location

  security_rule {
    name = "HTTP_in"
    priority = "101"
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

#join NSG Subnet
resource "azurerm_subnet_network_security_group_association" "nsg" {
  subnet_id = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

#ip public
resource "azurerm_public_ip" "pip01" {
  name = "pip01-lnx"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  allocation_method = "Dynamic"
}

#nic
resource "azurerm_network_interface" "nic01" {
  name = "nic01-lnx"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip01.id
  }
}

#proxy nginx
resource "azurerm_linux_virtual_machine" "nginx" {
  name                = "nginx-lnx"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  disable_password_authentication = false
  admin_username      = "lnxuser"
  admin_password = "!q2w3e4r5t"
  network_interface_ids = [
    azurerm_network_interface.nic01.id,
  ]

  # admin_ssh_key {
  #   username   = "lnxuser"
  #   public_key = file("~/.ssh/id_rsa.pub")
  # }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  custom_data = filebase64("scripts/deploy_nginx.sh")
}

#ip public (iis)
resource "azurerm_public_ip" "pip02" {
  name = "pip02-lnx"  
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  allocation_method = "Dynamic"
}

#nic (iis)
resource "azurerm_network_interface" "nic02" {
  name = "nic02-lnx"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip02.id
  }
}

#win iis
resource "azurerm_windows_virtual_machine" "iis" {
  name = "iis-lnx"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "lnxuser"
  admin_password = "!q2w3e4r"
  network_interface_ids = [
    azurerm_network_interface.nic02.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

}

#enable WinRM
resource "azurerm_virtual_machine_extension" "enable_winrm" {
  name                 = "enable_winrm"
  virtual_machine_id   = azurerm_windows_virtual_machine.iis.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
 {
  "commandToExecute": "powershell -encodedCommand ${textencodebase64(file("scripts/winrm.ps1"), "UTF-16LE")}"
 }
SETTINGS
}


output "iis_public" {
  value = azurerm_public_ip.pip02.ip_address
}

output "nginx_public" {
  value = azurerm_public_ip.pip01.ip_address
}