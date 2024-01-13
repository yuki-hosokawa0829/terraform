# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "regions" {
  description = "Regional variables"
  type        = map(any)
}

variable "resource_group_name" {
  description = "Name of Resource Group"
}

locals {
  admin_user_id = "76b54525-1913-491c-a304-6c4dc3b18458"
}