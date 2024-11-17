output "iis_public" {
  value = azurerm_public_ip.pip02.ip_address
}

output "nginx_public" {
  value = azurerm_public_ip.pip01.ip_address
}