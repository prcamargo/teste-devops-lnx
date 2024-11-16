resource "local_file" "inventory_file" {
  content = templatefile("./ansible/inventory.template",
  {
    iis_lnx = [resource.azurerm_windows_virtual_machine.pip02] #windows
    nginx_lnx = [resource.azurerm_linux_virtual_machine.pip01] #linux
  }
  )
  filename = "./inventory"
}