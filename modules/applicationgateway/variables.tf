variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "network_interface_id" {
  type = string
}

variable "subnet" {
  type = string
}

variable "dns_zone_name" {
  type = string
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of tags to assign to all resources."
}
