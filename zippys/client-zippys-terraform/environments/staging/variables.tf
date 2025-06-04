variable "app_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "app_service_plan_name" {
  type = string
}

variable "access_restrictions_enabled" {
  type    = bool
  default = false
}