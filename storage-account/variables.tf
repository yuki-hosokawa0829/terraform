variable "prefix" {
  description = "A prefix to add to all resource names"
  type        = string
  default     = "storage"
}

variable "location" {
  description = "The Azure Region in which all resources will be created."
  type        = string
  default     = "japanwest"
}

variable "blob_allowed_origin_url" {
  description = "The URL to allow for CORS"
  type        = string
}

variable "agw_pip" {
  description = "The public IP address of the Application Gateway"
  type        = string
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