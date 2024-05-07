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

variable "subnet_ids" {
  description = "The subnet IDs to which the service endpoint will be added."
  type        = list(string)
}

locals {
  sku_name             = "Basic"
  sqldatabase_username = "sqldbadmin"
  sqldatabase_password = "Password1234!"
}