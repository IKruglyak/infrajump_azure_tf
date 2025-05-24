resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = local.resource_group_name
  location            = local.location
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

resource "azurerm_public_ip" "nat" {
  name                = "${var.vnet_name}-nat-pip"
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "nat" {
  name                = "${var.vnet_name}-nat"
  location            = local.location
  resource_group_name = local.resource_group_name
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "nat_pip" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet" "private_subnet" {
  name                 = var.subnet_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
  service_endpoints    = [
    "Microsoft.ContainerRegistry",
    "Microsoft.Web",
    "Microsoft.KeyVault",
    "Microsoft.Storage",
    "Microsoft.ServiceBus"
  ]

  delegation {
    name = "container-apps-delegation"
    service_delegation {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

resource "azurerm_subnet" "app_gateway_subnet" {
  name                 = "app-gateway-subnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet_nat_gateway_association" "nat_assoc" {
  subnet_id      = azurerm_subnet.private_subnet.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vnet_name}-nsg"
  location            = local.location
  resource_group_name = local.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "deny-all-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-all-outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https-outbound"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-dns-outbound"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "app_gateway_nsg" {
  name                = "${var.vnet_name}-app-gateway-nsg"
  location            = local.location
  resource_group_name = local.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "allow-gateway-manager"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-azure-load-balancer"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-all-outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.private_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "app_gateway_nsg_association" {
  subnet_id                 = azurerm_subnet.app_gateway_subnet.id
  network_security_group_id = azurerm_network_security_group.app_gateway_nsg.id
} 