variable "public_ips" {
  description = "Public IP addresses for edge ingress and perimeter gateways"
  type = map(object({
    name              = string
    location          = string
    resource_group_name = string
    allocation_method = optional(string, "Static")
    sku               = optional(string, "Standard")
    zones             = optional(list(string))
    tags              = optional(map(string))
  }))
  default = {}
}

variable "bastion_hosts" {
  description = "Azure Bastion hosts for zero-trust browser RDP/SSH access"
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    sku                 = optional(string, "Standard")
    subnet_id           = string # Requires subnet named 'AzureBastionSubnet'
    public_ip_key       = optional(string)
    public_ip_id        = optional(string)
    tags                = optional(map(string))
  }))
  default = {}
}

variable "load_balancers" {
  description = "Layer 4 Azure Load Balancers (public or internal)"
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    sku                 = optional(string, "Standard")
    frontend_ip_configurations = list(object({
      name                          = string
      subnet_id                     = optional(string)
      private_ip_address            = optional(string)
      private_ip_address_allocation = optional(string, "Dynamic")
      public_ip_key                 = optional(string)
      public_ip_id                  = optional(string)
    }))
    probes = optional(list(object({
      name                = string
      protocol            = string
      port                = number
      request_path        = optional(string)
      interval_in_seconds = optional(number, 15)
      number_of_probes    = optional(number, 2)
    })), [])
    rules = optional(list(object({
      name                           = string
      protocol                       = string
      frontend_port                  = number
      backend_port                   = number
      frontend_ip_configuration_name = string
      probe_name                     = optional(string)
      idle_timeout_in_minutes        = optional(number, 4)
      enable_floating_ip             = optional(bool, false)
    })), [])
    tags = optional(map(string))
  }))
  default = {}
}

variable "application_gateways" {
  description = "Layer 7 Application Gateways with SSL termination and URL routing"
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    sku = object({
      name     = string # Standard_v2 or WAF_v2
      tier     = string # Standard_v2 or WAF_v2
      capacity = optional(number, 2)
    })
    subnet_id     = string
    public_ip_key = optional(string)
    public_ip_id  = optional(string)

    frontend_ports = list(object({
      name = string
      port = number
    }))

    backend_address_pools = list(object({
      name         = string
      ip_addresses = optional(list(string))
      fqdns        = optional(list(string))
    }))

    backend_http_settings = list(object({
      name                  = string
      cookie_based_affinity = optional(string, "Disabled")
      port                  = number
      protocol              = string
      request_timeout       = optional(number, 60)
    }))

    http_listeners = list(object({
      name                           = string
      frontend_port_name             = string
      protocol                       = string
      ssl_certificate_name           = optional(string)
    }))

    request_routing_rules = list(object({
      name                       = string
      rule_type                  = optional(string, "Basic")
      http_listener_name         = string
      backend_address_pool_name  = string
      backend_http_settings_name = string
      priority                   = number
    }))

    tags = optional(map(string))
  }))
  default = {}
}

variable "firewalls" {
  description = "Azure Firewalls with stateful packet filtering"
  type = map(object({
    name                = string
    location            = string
    resource_group_name = string
    sku_name            = optional(string, "AZFW_VNet")
    sku_tier            = optional(string, "Standard")
    subnet_id           = string # Requires subnet named 'AzureFirewallSubnet'
    public_ip_key       = optional(string)
    public_ip_id        = optional(string)
    firewall_policy_id  = optional(string)
    tags                = optional(map(string))
  }))
  default = {}
}
