variable "resource_group_name" {
  description = "The name of the resource group in which all resources will be created."
  type        = string
}

variable "domain_name" {
  description = "The domain name to create"
  type        = string
}

variable "subdomain_name" {
  description = "The subdomain name to create"
  type        = string
}