# Define Terraform provider and backend configuration
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
  backend "gcs" {
    bucket      = "walid-spoke-a-backend"
    prefix      = "spoke-a-state"
    credentials = "../../../G-secrets/pelagic-core-467122-q4-ff9df60ae3a5.json"
  }
}

provider "google" {
  project     = var.spoke_project_id
  region      = var.spoke_region
  credentials = var.spoke_credentials_path
}

# NCC Spoke module 
module "ncc_spoke" {
  source                      = "./modules/ncc-spoke-module"
  prefix                      = var.prefix
  spoke_project_id            = var.spoke_project_id
  spoke_region                = var.spoke_region
  spoke_credentials_path      = var.spoke_credentials_path
  spoke_subnet_cidr           = var.spoke_subnet_cidr
  spoke_asn                   = var.spoke_asn
  spoke_name                  = var.spoke_name
  spoke_statefile_bucket_name = var.spoke_statefile_bucket_name
  gcs_bucket_name             = var.gcs_bucket_name

  hub_state_bucket_name = var.hub_state_bucket_name
  hub_prefix            = var.hub_prefix
  hub_service_account   = var.hub_service_account

  spoke_to_ncc_ip_range_0 = var.spoke_to_ncc_ip_range_0
  ncc_to_spoke_peer_ip_0  = var.ncc_to_spoke_peer_ip_0
  spoke_to_ncc_ip_range_1 = var.spoke_to_ncc_ip_range_1
  ncc_to_spoke_peer_ip_1  = var.ncc_to_spoke_peer_ip_1

  deploy_test_vm       = var.deploy_test_vm
  test_vm_machine_type = var.test_vm_machine_type
  test_vm_image        = var.test_vm_image

  deploy_phase2 = var.deploy_phase2
  deploy_phase3 = var.deploy_phase3

  providers = {
    google = google
  }
}

#############################
######### TASK 3 ############
#############################

module "task3" {
  source = "./modules/task3"
  # Spoke configuration
  prefix            = var.prefix
  spoke_project_id  = var.spoke_project_id
  spoke_region      = var.spoke_region
  spoke_name        = var.spoke_name

  # Pass the VPC and subnet information from NCC spoke module
  spoke_vpc_id    = module.ncc_spoke.spoke_vpc_id
  spoke_subnet_id = module.ncc_spoke.spoke_subnet_id

  # Task 3 configuration
  windows_vm_region      = var.windows_vm_region
  windows_vm_machine_type = var.windows_vm_machine_type
  linux_vm_machine_type  = var.linux_vm_machine_type
  task3_public_cidr      = var.task3_public_cidr

  # Group members
  group_members = var.group_members

  # Member customizations
  member_customizations = var.member_customizations

  # Other spokes for cross-communication
  other_spokes = var.other_spokes

  # Task 3 deployment control
  deploy_task_3 = var.deploy_task_3
  providers = {
    google = google
  }
}