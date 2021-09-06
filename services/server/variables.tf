variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "vm_parameters" {
  type = any
}

variable "dns_zone_name" {
  type = string
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of tags to assign to all resources."
}
