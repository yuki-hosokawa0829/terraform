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
  default     = "4d55c914-726b-4a03-b002-54c4bf217ad5"
}

variable "usr_tenant_id" {
  description = "Tenant ID"
  default     = "9781ab08-ef7d-4e4f-b6f0-c595b7a023cb"
}

variable "usr_client_id" {
  description = "Service Principal ID"
  default     = "78fedf0d-7c87-4643-b4dc-13062b0752ed"
}

variable "usr_client_secret" {
  description = "Password for the Administrator account"
  default     = "eQ28Q~S5MT4nodAKe3MrLD_mnVQyb7zXP3HanaxE"
}

locals {
  shared_key = "pZrmoQ96qX6fl5baKNnTUN10wqwoocE2" #Known after Deployment of AVW Hub GW
}