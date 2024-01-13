# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "resource_group_name" {
  description = "Name of the Resource group in which to deploy session host"
}

variable "sessionhost_subnet_id" {
  description = "ID for subnet of session host"
}

variable "hostpool_name" {
  description = "Name of the Azure Virtual Desktop host pool"
}

variable "rdsh_count" {}

variable "domain_user_upn" {
  description = "Username for domain join (do not include domain name as this is appended)"
}

variable "domain_user_password" {
  description = "Password of the user to authenticate with the domain"
}

variable "sessionhost_vm_size" {
  description = "Size of the sessionhost machine to deploy"
}

variable "domain_name" {
  description = "Name of the domain to join"
}

variable "domain_path" {
  description = "dc=yourdomain,dc=com"
}

variable "ou_path" {
  description = "OU for session host"
}

variable "local_admin_username" {
  description = "local admin username"
}

variable "local_admin_password" {
  description = "local admin password"
}

variable "registration_token" {
  description = "registration token for host pool"
}