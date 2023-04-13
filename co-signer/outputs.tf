output "load_balancer_public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "generated_password" {
  value     = random_password.password.result
  sensitive = true
}
