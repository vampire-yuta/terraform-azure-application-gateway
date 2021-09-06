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

variable "snapshot_disk_id" {
  type = string
}

variable "vm_parameters" {
  type = any
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of tags to assign to all resources."
}