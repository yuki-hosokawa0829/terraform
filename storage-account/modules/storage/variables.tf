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

variable "blob_allowed_origin_url" {
  description = "The URL to allow for CORS"
  type        = string
}

variable "agw_pip" {
  description = "The public IP address of the Application Gateway"
  type        = string
}

variable "storage_type" {
  description = "The type of storage account to create"
  type        = number
}