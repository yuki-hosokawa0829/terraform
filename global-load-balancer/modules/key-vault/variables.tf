variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "resource_group_name" {
  description = "The name of Rsource Group"
}

variable "regions" {
  description = "Info about Regions"
}

locals {
  admin_user_id = "76b54525-1913-491c-a304-6c4dc3b18458"
}