# Azure Private Container App with Front Door

This Terraform module creates a secure, private container application infrastructure in Azure, accessible only through Azure Front Door. The infrastructure includes:

- Virtual Network with private subnet
- Azure Container App running in private subnet
- Application Gateway as internal proxy
- Azure Front Door for secure external access
- Network Security Groups for traffic control

## Requirements

- Azure subscription
- Terraform >= 1.0.0
- Azure provider >= 3.0.0

## Usage

```hcl
module "private_container_app" {
  source = "./modules/private-container-app"

  resource_group_name    = "my-resource-group"
  location              = "westeurope"
  vnet_name             = "my-vnet"
  container_app_name    = "my-container-app"
  front_door_name       = "my-front-door"
  front_door_domain     = "myapp"
  app_gateway_name      = "my-app-gateway"

  tags = {
    Environment = "Production"
    Project     = "MyApp"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region | `string` | `"westeurope"` | no |
| vnet_name | Name of the virtual network | `string` | n/a | yes |
| vnet_address_space | VNet address space | `string` | `"10.0.0.0/16"` | no |
| subnet_name | Name of the subnet | `string` | `"private-subnet"` | no |
| subnet_address_prefix | Subnet address prefix | `string` | `"10.0.1.0/24"` | no |
| container_app_name | Name of the container app | `string` | n/a | yes |
| container_image | Container image to deploy | `string` | `"nginx:latest"` | no |
| front_door_name | Name of Front Door instance | `string` | n/a | yes |
| front_door_domain | Front Door domain name | `string` | n/a | yes |
| app_gateway_name | Name of Application Gateway | `string` | n/a | yes |
| app_gateway_sku | SKU for Application Gateway | `string` | `"Standard_v2"` | no |
| tags | Tags for all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| front_door_host_name | Front Door host name |
| container_app_name | Container App name |
| container_app_fqdn | Container App FQDN |
| app_gateway_public_ip | Application Gateway public IP |
| vnet_name | Virtual Network name |
| subnet_name | Subnet name |

## Security

- Container App is deployed in a private subnet
- NSG rules deny all inbound traffic by default
- All external access is through Front Door
- HTTPS is enforced for all external connections
- Private endpoints are used where applicable

## Deployment

1. Initialize Terraform:
```bash
terraform init
```

2. Review the planned changes:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

## Notes

- The Container App is not directly accessible from the internet
- All traffic must go through Front Door → Application Gateway → Container App
- The module uses self-signed certificates for HTTPS
- Network Security Groups are configured to deny all inbound traffic by default 