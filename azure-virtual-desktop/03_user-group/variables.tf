variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "avd"
}

variable "aad_domain" {
  description = "Azure AD Domain"
  default     = "yourazureaddomain.onmicrosoft.com"
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
  avd_user_name = [
    "avduser01",
    "avduser02"
  ]
  avd_user_group_name = "TestAVDUserGroup"

  app_group_name = "avd-dag"
}