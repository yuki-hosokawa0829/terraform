variable "prefix" {
  description = "A prefix to add to all resource names"
  type        = string
  default     = "dns"
}

variable "domain_name" {
  description = "The domain name to create"
  type        = string
}

variable "subdomain_name" {
  description = "The subdomain name to create"
  type        = string
}

variable "location" {
  description = "The Azure Region in which all resources will be created."
  type        = string
  default     = "japaneast"
}

variable "text_record" {
  description = "The text record to create"
  type        = map(string)
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