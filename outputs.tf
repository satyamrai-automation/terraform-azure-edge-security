output "public_ips" {
  description = "Public IP objects"
  value       = azurerm_public_ip.pip
}

output "public_ip_ids" {
  description = "Map of Public IP IDs"
  value       = { for k, v in azurerm_public_ip.pip : k => v.id }
}

output "public_ip_addresses" {
  description = "Map of allocated Public IPv4 addresses"
  value       = { for k, v in azurerm_public_ip.pip : k => v.ip_address }
}

output "bastion_hosts" {
  description = "Azure Bastion objects"
  value       = azurerm_bastion_host.bastion
}

output "bastion_host_ids" {
  description = "Map of Bastion Host IDs"
  value       = { for k, v in azurerm_bastion_host.bastion : k => v.id }
}

output "bastion_host_dns_names" {
  description = "Map of Bastion Host FQDNs for browser-based access"
  value       = { for k, v in azurerm_bastion_host.bastion : k => v.dns_name }
}

output "load_balancers" {
  description = "Load Balancer objects"
  value       = azurerm_lb.lb
}

output "load_balancer_ids" {
  description = "Map of Load Balancer IDs"
  value       = { for k, v in azurerm_lb.lb : k => v.id }
}

output "application_gateways" {
  description = "Application Gateway objects"
  value       = azurerm_application_gateway.appgw
}

output "application_gateway_ids" {
  description = "Map of Application Gateway IDs"
  value       = { for k, v in azurerm_application_gateway.appgw : k => v.id }
}

output "firewalls" {
  description = "Azure Firewall objects"
  value       = azurerm_firewall.fw
}

output "firewall_ids" {
  description = "Map of Azure Firewall IDs"
  value       = { for k, v in azurerm_firewall.fw : k => v.id }
}

output "firewall_private_ips" {
  description = "Map of Azure Firewall private IPs (for UDR next-hop configuration)"
  value       = { for k, v in azurerm_firewall.fw : k => v.ip_configuration[0].private_ip_address }
}
