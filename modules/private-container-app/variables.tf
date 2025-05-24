variable "create_resource_group" {
  description = "Whether to create a new resource group"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "private-app-rg"
}

variable "resource_group_location" {
  description = "Location of the resource group"
  type        = string
  default     = "westeurope"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "private-app-vnet"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "private-subnet"
}

variable "subnet_address_prefix" {
  description = "Address prefix for the subnet (must be at least /23 for Container Apps)"
  type        = string
  default     = "10.0.0.0/23"
}

variable "container_app_name" {
  description = "Name of the container app"
  type        = string
  default     = "private-app"
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
  default     = "nginx:latest"
}

variable "front_door_name" {
  description = "Name of the Front Door instance"
  type        = string
  default     = "private-app-fd"
}

variable "front_door_domain" {
  description = "Domain name for Front Door"
  type        = string
  default     = "privateapp"
}

variable "app_gateway_name" {
  description = "Name of the Application Gateway"
  type        = string
  default     = "private-app-gw"
}

variable "app_gateway_sku" {
  description = "SKU of the Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Project     = "PrivateApp"
    ManagedBy   = "Terraform"
  }
} 