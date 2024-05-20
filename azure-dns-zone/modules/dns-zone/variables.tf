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

variable "host_name" {
  description = "The host name for the text record"
  type        = string
}

variable "text_record" {
  description = "The text record to create"
  type        = string
}

variable "ttl" {
  description = "The TTL for the text record"
  type        = number
}