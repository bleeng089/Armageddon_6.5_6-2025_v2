# Spoke configuration
variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "spoke_project_id" {
  description = "The GCP spoke project ID"
  type        = string
}

variable "spoke_region" {
  description = "The GCP spoke region"
  type        = string
}

variable "spoke_name" {
  description = "Name of the spoke"
  type        = string
}

# VPC and subnet references
variable "spoke_vpc_id" {
  description = "ID of the existing spoke VPC"
  type        = string
}

variable "spoke_subnet_id" {
  description = "ID of the existing spoke subnet"
  type        = string
}

# Task 3 configuration
variable "windows_vm_region" {
  description = "Region for the Windows VM (different from spoke region)"
  type        = string
}

variable "windows_vm_machine_type" {
  description = "Machine type for Windows VM"
  type        = string
  default     = "n4-standard-4"
}

variable "linux_vm_machine_type" {
  description = "Machine type for Linux VMs"
  type        = string
  default     = "e2-medium"
}

variable "task3_public_cidr" {
  description = "CIDR for Task 3 public subnet"
  type        = string
  default     = "10.192.1.0/24"
}

# Group members configuration
variable "group_members" {
  description = "List of group members with their regions"
  type = list(object({
    name   = string
    region = string
  }))
}

# Member customization
variable "member_customizations" {
  description = "Customization details for each member's Linux VM"
  type = list(object({
    name               = string
    annual_salary      = string
    influencer         = string
    background_image_url = string
    promo_image_url    = string
  }))
}

# Other spokes configuration for cross-spoke communication
variable "other_spokes" {
  description = "List of other spokes for cross-communication"
  type = list(object({
    name  = string
    lb_ip = string
  }))
  default = []
}

# Task 3 deployment control
variable "deploy_task_3" {
  description = "Whether to deploy Task 3 resources"
  type        = bool
  default     = false
}