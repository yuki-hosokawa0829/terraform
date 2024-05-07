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

variable "database_username" {
  description = "The username for the database."
  type        = string
}

variable "database_password" {
  description = "The password for the database."
  type        = string
  sensitive   = true
}