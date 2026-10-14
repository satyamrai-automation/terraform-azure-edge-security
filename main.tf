resource "azurerm_public_ip" "pip" {
  for_each = var.public_ips

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = lookup(each.value, "allocation_method", "Static")
  sku                 = lookup(each.value, "sku", "Standard")
  zones               = lookup(each.value, "zones", null)
  tags                = lookup(each.value, "tags", null)
}

resource "azurerm_bastion_host" "bastion" {
  for_each = var.bastion_hosts

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku                 = lookup(each.value, "sku", "Standard")
  tags                = lookup(each.value, "tags", null)

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = each.value.subnet_id
    public_ip_address_id = lookup(each.value, "public_ip_key", null) != null ? azurerm_public_ip.pip[each.value.public_ip_key].id : each.value.public_ip_id
  }
}

resource "azurerm_lb" "lb" {
  for_each = var.load_balancers

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku                 = lookup(each.value, "sku", "Standard")
  tags                = lookup(each.value, "tags", null)

  dynamic "frontend_ip_configuration" {
    for_each = each.value.frontend_ip_configurations
    content {
      name                          = frontend_ip_configuration.value.name
      subnet_id                     = lookup(frontend_ip_configuration.value, "subnet_id", null)
      private_ip_address            = lookup(frontend_ip_configuration.value, "private_ip_address", null)
      private_ip_address_allocation = lookup(frontend_ip_configuration.value, "private_ip_address_allocation", "Dynamic")
      public_ip_address_id          = lookup(frontend_ip_configuration.value, "public_ip_key", null) != null ? azurerm_public_ip.pip[frontend_ip_configuration.value.public_ip_key].id : lookup(frontend_ip_configuration.value, "public_ip_id", null)
    }
  }

  dynamic "probe" {
    for_each = lookup(each.value, "probes", [])
    content {
      name                = probe.value.name
      protocol            = probe.value.protocol
      port                = probe.value.port
      request_path        = lookup(probe.value, "request_path", null)
      interval_in_seconds = lookup(probe.value, "interval_in_seconds", 15)
      number_of_probes    = lookup(probe.value, "number_of_probes", 2)
    }
  }

  dynamic "rule" {
    for_each = lookup(each.value, "rules", [])
    content {
      name                           = rule.value.name
      protocol                       = rule.value.protocol
      frontend_port                  = rule.value.frontend_port
      backend_port                   = rule.value.backend_port
      frontend_ip_configuration_name = rule.value.frontend_ip_configuration_name
      probe_name                     = lookup(rule.value, "probe_name", null)
      idle_timeout_in_minutes        = lookup(rule.value, "idle_timeout_in_minutes", 4)
      enable_floating_ip             = lookup(rule.value, "enable_floating_ip", false)
    }
  }
}

resource "azurerm_application_gateway" "appgw" {
  for_each = var.application_gateways

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  tags                = lookup(each.value, "tags", null)

  sku {
    name     = each.value.sku.name
    tier     = each.value.sku.tier
    capacity = lookup(each.value.sku, "capacity", 2)
  }

  gateway_ip_configuration {
    name      = "${each.value.name}-gw-ipc"
    subnet_id = each.value.subnet_id
  }

  frontend_ip_configuration {
    name                 = "${each.value.name}-fe-ipc"
    public_ip_address_id = lookup(each.value, "public_ip_key", null) != null ? azurerm_public_ip.pip[each.value.public_ip_key].id : each.value.public_ip_id
  }

  dynamic "frontend_port" {
    for_each = each.value.frontend_ports
    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }

  dynamic "backend_address_pool" {
    for_each = each.value.backend_address_pools
    content {
      name         = backend_address_pool.value.name
      ip_addresses = lookup(backend_address_pool.value, "ip_addresses", null)
      fqdns        = lookup(backend_address_pool.value, "fqdns", null)
    }
  }

  dynamic "backend_http_settings" {
    for_each = each.value.backend_http_settings
    content {
      name                  = backend_http_settings.value.name
      cookie_based_affinity = lookup(backend_http_settings.value, "cookie_based_affinity", "Disabled")
      port                  = backend_http_settings.value.port
      protocol              = backend_http_settings.value.protocol
      request_timeout       = lookup(backend_http_settings.value, "request_timeout", 60)
    }
  }

  dynamic "http_listener" {
    for_each = each.value.http_listeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = "${each.value.name}-fe-ipc"
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = http_listener.value.protocol
      ssl_certificate_name           = lookup(http_listener.value, "ssl_certificate_name", null)
    }
  }

  dynamic "request_routing_rule" {
    for_each = each.value.request_routing_rules
    content {
      name                       = request_routing_rule.value.name
      rule_type                  = lookup(request_routing_rule.value, "rule_type", "Basic")
      http_listener_name         = request_routing_rule.value.http_listener_name
      backend_address_pool_name  = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
      priority                   = request_routing_rule.value.priority
    }
  }
}

resource "azurerm_firewall" "fw" {
  for_each = var.firewalls

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku_name            = lookup(each.value, "sku_name", "AZFW_VNet")
  sku_tier            = lookup(each.value, "sku_tier", "Standard")
  firewall_policy_id  = lookup(each.value, "firewall_policy_id", null)
  tags                = lookup(each.value, "tags", null)

  ip_configuration {
    name                 = "firewall-ip-config"
    subnet_id            = each.value.subnet_id
    public_ip_address_id = lookup(each.value, "public_ip_key", null) != null ? azurerm_public_ip.pip[each.value.public_ip_key].id : each.value.public_ip_id
  }
}
