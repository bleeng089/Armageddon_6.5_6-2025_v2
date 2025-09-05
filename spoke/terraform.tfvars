prefix                      = "walid1"
spoke_project_id            = "pelagic-core-467122-q4"
spoke_region                = "asia-northeast1"
spoke_credentials_path      = "../../../G-secrets/pelagic-core-467122-q4-ff9df60ae3a5.json"
spoke_subnet_cidr           = "10.191.1.0/24"
spoke_asn                   = 65001
spoke_name                  = "spoke-a"
spoke_statefile_bucket_name = "walid-spoke-a-backend"
gcs_bucket_name             = "walid-secrets-backend"

hub_state_bucket_name   = "walid-hub-backend"
hub_prefix              = "hub-state"
hub_service_account     = "admin-428@ncc-project-467401.iam.gserviceaccount.com"
spoke_to_ncc_ip_range_0 = "169.254.0.2/30"
ncc_to_spoke_peer_ip_0  = "169.254.0.1"
spoke_to_ncc_ip_range_1 = "169.254.1.2/30"
ncc_to_spoke_peer_ip_1  = "169.254.1.1"

deploy_test_vm       = true
test_vm_machine_type = "e2-micro"
test_vm_image        = "debian-cloud/debian-11"


deploy_phase2 = false
deploy_phase3 = false


#############################
####### TASK 3 CONFIG #######
#############################

# Task 3 deployment control
deploy_task_3 = true

# Task 3 specific configuration
windows_vm_region      = "northamerica-northeast1"
windows_vm_machine_type = "n4-standard-4"
linux_vm_machine_type  = "e2-medium"
task3_public_cidr      = "10.192.1.0/24"

# Group members for Task 3
group_members = [
  {
    name   = "member1"
    region = "asia-northeast1"
  },
  {
    name   = "member2"
    region = "asia-northeast1"
  }
]

# Member customizations for Linux VMs
member_customizations = [
  {
    name               = "member1"
    annual_salary      = "$140,000"
    influencer         = "Lizzo"
    background_image_url = "https://storage.googleapis.com/cloud-training/images/terraform/peaceful-place-1.jpg"
    promo_image_url    = "https://storage.googleapis.com/cloud-training/images/terraform/promo-1.jpg"
  },
  {
    name               = "member2"
    annual_salary      = "$150,000"
    influencer         = "TechInfluencer"
    background_image_url = "https://storage.googleapis.com/cloud-training/images/terraform/peaceful-place-2.jpg"
    promo_image_url    = "https://storage.googleapis.com/cloud-training/images/terraform/promo-2.jpg"
  }
]

# Other spokes for cross-communication
other_spokes = [
  {
    name  = "spoke-b"
    lb_ip = "10.191.2.100"
  }
]