variable "name" {
  type        = string
  description = "A 7 character name identifier, such as 'test'"
  validation {
    condition     = length(var.name) < 8
    error_message = "The id value must be max 7 chars."
  }
}

variable "location" {
  type        = string
  description = "Azure region for deployment of services, such as 'westeurope'"
}

variable "core_vnet" {
  type        = string
  description = "Name of the core VNET"
}

variable "vnet_address_space" {
  type        = string
  description = "VNET Address Space, such as '10.0.0.0/22'"
}
