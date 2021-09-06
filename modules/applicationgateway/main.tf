locals {
  backend_address_pool_name       = "${var.service_name}-beap"
  http_frontend_port_name         = "${var.service_name}-http-feport"
  https_frontend_port_name        = "${var.service_name}-https-feport"
  frontend_ip_configuration_name  = "${var.service_name}-feip"
  http_setting_name               = "${var.service_name}-be-htst"
  http_listener_name              = "${var.service_name}-http-lstn"
  https_listener_name             = "${var.service_name}-https-lstn"
  http_request_routing_rule_name  = "${var.service_name}-http-rqrt"
  https_request_routing_rule_name = "${var.service_name}-https-rqrt"
  redirect_configuration_name     = "${var.service_name}-rdrcfg"
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.service_name}-appgateway-public-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge({
    Name    = "${var.service_name}-appgateway-public-ip"
    Service = var.service_name
    },
    var.tags
  )
}

resource "azurerm_application_gateway" "network" {
  name                = "${var.service_name}-appgateway"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = var.subnet
  }

  frontend_port {
    name = local.http_frontend_port_name
    port = 80
  }

  frontend_port {
    name = local.https_frontend_port_name
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    affinity_cookie_name  = "ApplicationGatewayAffinity"
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.http_frontend_port_name
    protocol                       = "Http"
  }

  http_listener {
    name                           = local.https_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.https_frontend_port_name
    protocol                       = "Https"
    ssl_certificate_name           = "server"
  }

  ssl_certificate {
    name     = "server"
    data     = filebase64("./server.pfx")
    password = "password"
  }

  redirect_configuration {
    include_path         = true
    include_query_string = true
    name                 = "tohttps"
    redirect_type        = "Permanent"
    target_listener_name = local.https_listener_name
  }

  request_routing_rule {
    name                        = local.http_request_routing_rule_name
    rule_type                   = "Basic"
    http_listener_name          = local.http_listener_name
    redirect_configuration_name = "tohttps"
  }

  request_routing_rule {
    name                       = local.https_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.https_listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  waf_configuration {
    enabled                  = true
    file_upload_limit_mb     = 100
    firewall_mode            = "Detection"
    max_request_body_size_kb = 128
    request_body_check       = true
    rule_set_type            = "OWASP"
    rule_set_version         = 3.2
  }

  tags = merge({
    Name    = "${var.service_name}-appgateway"
    Service = var.service_name
    },
    var.tags
  )
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "example" {
  network_interface_id    = var.network_interface_id
  ip_configuration_name   = "${var.service_name}-internal"
  backend_address_pool_id = azurerm_application_gateway.network.backend_address_pool[0].id
}

resource "azurerm_dns_a_record" "lb_dns_record" {
  name                = var.service_name
  zone_name           = var.dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.public_ip.id
}
