variable "prefix" {
  description = "A prefix to add to all resource names"
  type        = string
  default     = "postgres"
}

variable "location" {
  description = "The Azure Region in which all resources will be created."
  type        = string
  default     = "japaneast"
}

variable "network_range" {
  description = "The address space that is used by the virtual network."
  type        = string
  default     = "192.168.0.0/24"
}

variable "number_of_subnets" {
  description = "The number of subnets to create within the virtual network."
  type        = number
  default     = 2
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

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "client_id" {
  description = "The Azure client ID"
  type        = string
}

variable "client_secret" {
  description = "The Azure client secret"
  type        = string
}

variable "tenant_id" {
  description = "The Azure tenant ID"
  type        = string
}