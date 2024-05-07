variable "prefix" {
  description = "A prefix to add to all resource names"
  type        = string
}

variable "location" {
  description = "The Azure Region in which all resources will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which all resources will be created."
  type        = string
}

variable "postgres_subnet_id" {
  description = "The subnet ID to which the Postgres service endpoint will be added."
  type        = string
}


variable "private_dns_zone_id" {
  description = "The ID of the private DNS zone to which the server will be linked."
  type        = string
}

variable "administrator_login" {
  description = "The administrator login for the server."
  type        = string
}

variable "administrator_password" {
  description = "The administrator password for the server."
  type        = string
  sensitive   = true
}

locals {
  sku_name       = "Basic"
  admin_username = "sqldbadmin"
  admin_password = "Password1234!"
}