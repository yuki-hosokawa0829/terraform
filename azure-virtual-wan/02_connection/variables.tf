variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "wan"
}

variable "location02" {
  description = "The Azure Region in which a hub resources in this example should be created."
  default     = "JapanEast"
}

variable "usr_subscription_id" {
  description = "The Azure Subscription ID"
  default     = "your-azure-subscription-id"
}

variable "usr_tenant_id" {
  description = "Tenant ID"
  default     = "your-entra-id-tenant-id"
}

variable "usr_client_id" {
  description = "Service Principal ID"
  default     = "your-terraform-service-principal-id"
}

variable "usr_client_secret" {
  description = "Password for the Administrator account"
  default     = "your-terraform-service-principal-secrets"
}

locals {
  shared_key = "pZrmoQ96qX6fl5baKNnTUN10wqwoocE2" #Known after Deployment of AVW Hub GW
}