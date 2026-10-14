# 🛡️ Terraform Azure Edge & Perimeter Security Module 

Production-ready Terraform child module managing Azure perimeter security, zero-trust remote access, Layer 4/7 load balancing, and network firewalls.

---

## 🌟 Managed Resources

This module consolidates 5 essential perimeter and traffic delivery resources:

1. **[`azurerm_public_ip`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip)**: Static/dynamic standard public IP addresses for gateways.
2. **[`azurerm_bastion_host`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host)**: Managed browser-based zero-trust RDP/SSH access without public IPs on VMs.
3. **[`azurerm_lb`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb)**: Layer 4 ultra-low latency load balancer (internal and public) with health probes and rules.
4. **[`azurerm_application_gateway`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway)**: Layer 7 Application Delivery Controller with SSL termination, URL path-based routing, and WAF support.
5. **[`azurerm_firewall`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall)**: Stateful cloud-native network firewall with L3-L7 rule filtering.

---

## 🔐 Azure Permissions

* **Contributor Role:** ✅ **100% Supported**. All resources belong to `Microsoft.Network/*`. No elevated Owner or User Access Administrator rights required.

---

## 🚀 Consumption in Root Modules (`Rally-tech-infra`)

### 1. In `environments/dev/main.tf`:
```hcl
module "edge_security" {
  source = "git::https://github.com/satyamrai-automation/terraform-azure-edge-security.git?ref=v1.0.0"

  public_ips           = var.public_ips
  bastion_hosts        = var.bastion_hosts
  load_balancers       = var.load_balancers
  application_gateways = var.application_gateways
  firewalls            = var.firewalls

  depends_on = [module.networking]
}
```

### 2. In `environments/dev/terraform.tfvars`:
```hcl
public_ips = {
  "pip-bastion" = {
    name                = "pip-bastion-dev-centralindia"
    location            = "centralindia"
    resource_group_name = "rg-rally-dev-centralindia"
  }
}

bastion_hosts = {
  "bastion-dev" = {
    name                = "bas-rally-dev-centralindia"
    location            = "centralindia"
    resource_group_name = "rg-rally-dev-centralindia"
    subnet_id           = "/subscriptions/.../subnets/AzureBastionSubnet"
    public_ip_key       = "pip-bastion"
  }
}
```

---

## 📥 Inputs

| Name | Type | Description | Default | Required |
| :--- | :--- | :--- | :---: | :---: |
| `public_ips` | `map(object)` | Public IP addresses for load balancers, bastions, and firewalls | `{}` | No |
| `bastion_hosts` | `map(object)` | Azure Bastion hosts for secure zero-trust management | `{}` | No |
| `load_balancers` | `map(object)` | L4 load balancers with frontend IPs, health probes, and balancing rules | `{}` | No |
| `application_gateways` | `map(object)` | L7 application gateways with listeners and routing rules | `{}` | No |
| `firewalls` | `map(object)` | Azure Firewalls for centralized egress filtering | `{}` | No |

---

## 📤 Outputs

| Name | Description |
| :--- | :--- |
| `public_ips` | Complete map of created Public IP objects |
| `public_ip_ids` | Map of Public IP resource IDs |
| `public_ip_addresses` | Map of allocated Public IP addresses |
| `bastion_hosts` | Complete map of Azure Bastion objects |
| `bastion_host_ids` | Map of Bastion Host IDs |
| `bastion_host_dns_names` | Map of Bastion Host FQDNs for browser-based access |
| `load_balancers` | Complete map of Load Balancer objects |
| `load_balancer_ids` | Map of Load Balancer IDs |
| `application_gateways` | Complete map of Application Gateway objects |
| `application_gateway_ids` | Map of Application Gateway IDs |
| `firewalls` | Complete map of Azure Firewall objects |
| `firewall_ids` | Map of Azure Firewall IDs |
| `firewall_private_ips` | Map of Azure Firewall private IPs (for UDR next-hop routing) |
