# Create public subnet for Windows VM in a different region
resource "google_compute_subnetwork" "task3_public_subnet" {
  count                  = var.deploy_task_3 ? 1 : 0
  provider               = google
  name                   = "${var.prefix}-spoke-${var.spoke_name}-task3-public-subnet"
  project                = var.spoke_project_id
  region                 = var.windows_vm_region
  network                = var.spoke_vpc_id
  ip_cidr_range          = var.task3_public_cidr
  private_ip_google_access = true
}

# Create router for public subnet
resource "google_compute_router" "task3_public_router" {
  count      = var.deploy_task_3 ? 1 : 0
  provider   = google
  name       = "${var.prefix}-spoke-${var.spoke_name}-task3-public-router"
  project    = var.spoke_project_id
  region     = var.windows_vm_region
  network    = var.spoke_vpc_id
}

# Create NAT for public subnet
resource "google_compute_router_nat" "task3_public_nat" {
  count    = var.deploy_task_3 ? 1 : 0
  provider = google
  name     = "${var.prefix}-spoke-${var.spoke_name}-task3-public-nat"
  router   = var.deploy_task_3 ? google_compute_router.task3_public_router[0].name : null
  project  = var.spoke_project_id
  region   = var.windows_vm_region

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "MANUAL_ONLY"

  subnetwork {
    name                    = var.deploy_task_3 ? google_compute_subnetwork.task3_public_subnet[0].id : null
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ips = var.deploy_task_3 ? [google_compute_address.task3_public_nat_ip[0].self_link] : []
}

# NAT IP address for public subnet
resource "google_compute_address" "task3_public_nat_ip" {
  count        = var.deploy_task_3 ? 1 : 0
  provider     = google
  name         = "${var.prefix}-spoke-${var.spoke_name}-task3-public-nat-ip"
  project      = var.spoke_project_id
  region       = var.windows_vm_region
  address_type = "EXTERNAL"
}

# Firewall rule for RDP access to Windows VM
resource "google_compute_firewall" "task3_rdp_access" {
  count    = var.deploy_task_3 ? 1 : 0
  provider = google
  name     = "${var.prefix}-spoke-${var.spoke_name}-task3-allow-rdp"
  project  = var.spoke_project_id
  network  = var.spoke_vpc_id

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.prefix}-spoke-${var.spoke_name}-task3-windows-vm"]
}

# Firewall rule for Windows to Linux communication
resource "google_compute_firewall" "task3_windows_to_linux" {
  count    = var.deploy_task_3 ? 1 : 0
  provider = google
  name     = "${var.prefix}-spoke-${var.spoke_name}-task3-windows-to-linux"
  project  = var.spoke_project_id
  network  = var.spoke_vpc_id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_tags = ["${var.prefix}-spoke-${var.spoke_name}-task3-windows-vm"]
  target_tags = [for member in var.group_members : "${var.prefix}-spoke-${var.spoke_name}-task3-${member.name}-linux-vm"]
}

# Windows VM in public subnet
resource "google_compute_instance" "task3_windows_vm" {
  count        = var.deploy_task_3 ? 1 : 0
  provider     = google
  name         = "${var.prefix}-spoke-${var.spoke_name}-task3-windows-vm"
  project      = var.spoke_project_id
  zone         = "${var.windows_vm_region}-a"
  machine_type = var.windows_vm_machine_type
  tags         = ["${var.prefix}-spoke-${var.spoke_name}-task3-windows-vm"]

  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-2022"
    }
  }

  network_interface {
    subnetwork = var.deploy_task_3 ? google_compute_subnetwork.task3_public_subnet[0].id : null
    access_config {
      # Ephemeral public IP
    }
  }

  metadata = {
    windows-startup-script-ps1 = <<EOF
      # Add hosts entry for internal load balancer
      Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "`n${var.deploy_task_3 ? google_compute_address.task3_internal_lb_ip[0].address : ""} internal-lb.${var.spoke_name}.local"
      
      # Add entries for other spokes' internal load balancers
      ${join("\n", [for spoke in var.other_spokes : 
        "Add-Content -Path \"C:\\Windows\\System32\\drivers\\etc\\hosts\" -Value \"`n${spoke.lb_ip} internal-lb.${spoke.name}.local\"" 
      ])}
    EOF
  }
}

# Internal load balancer IP address
resource "google_compute_address" "task3_internal_lb_ip" {
  count        = var.deploy_task_3 ? 1 : 0
  provider     = google
  name         = "${var.prefix}-spoke-${var.spoke_name}-task3-internal-lb-ip"
  project      = var.spoke_project_id
  region       = var.spoke_region
  subnetwork   = var.spoke_subnet_id
  address_type = "INTERNAL"
}

# Internal load balancer
resource "google_compute_forwarding_rule" "task3_internal_lb" {
  count                 = var.deploy_task_3 ? 1 : 0
  provider              = google
  name                  = "${var.prefix}-spoke-${var.spoke_name}-task3-internal-lb"
  project               = var.spoke_project_id
  region                = var.spoke_region
  load_balancing_scheme = "INTERNAL"
  backend_service       = var.deploy_task_3 ? google_compute_region_backend_service.task3_linux_backend[0].self_link : null
  ip_address            = var.deploy_task_3 ? google_compute_address.task3_internal_lb_ip[0].address : null
  ip_protocol           = "TCP"
  ports                 = ["80"]
  subnetwork            = var.spoke_subnet_id
}

# Backend service for internal load balancer
resource "google_compute_region_backend_service" "task3_linux_backend" {
  count                 = var.deploy_task_3 ? 1 : 0
  provider              = google
  name                  = "${var.prefix}-spoke-${var.spoke_name}-task3-linux-backend"
  project               = var.spoke_project_id
  region                = var.spoke_region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = var.deploy_task_3 ? [google_compute_health_check.task3_linux_hc[0].id] : []

  backend {
    group = var.deploy_task_3 ? google_compute_region_instance_group_manager.task3_linux_mig[0].instance_group : null
  }
}

# Health check for Linux VMs
resource "google_compute_health_check" "task3_linux_hc" {
  count              = var.deploy_task_3 ? 1 : 0
  provider           = google
  name               = "${var.prefix}-spoke-${var.spoke_name}-task3-linux-hc"
  project            = var.spoke_project_id
  check_interval_sec = 5
  timeout_sec        = 5
  
  tcp_health_check {
    port = 80
  }
}

# Linux VM instance template
resource "google_compute_instance_template" "task3_linux_template" {
  count        = var.deploy_task_3 ? 1 : 0
  provider     = google
  name         = "${var.prefix}-spoke-${var.spoke_name}-task3-linux-template"
  project      = var.spoke_project_id
  machine_type = var.linux_vm_machine_type
  tags         = [for member in var.group_members : "${var.prefix}-spoke-${var.spoke_name}-task3-${member.name}-linux-vm"]

  disk {
    source_image = "debian-cloud/debian-12"
    boot         = true
  }

  network_interface {
    subnetwork = var.spoke_subnet_id
  }

  metadata_startup_script = templatefile("${path.module}/scripts/webserver.sh", {
    member_customizations = jsonencode(var.member_customizations)
  })
}

# Managed instance group for Linux VMs
resource "google_compute_region_instance_group_manager" "task3_linux_mig" {
  count                = var.deploy_task_3 ? 1 : 0
  provider             = google
  name                 = "${var.prefix}-spoke-${var.spoke_name}-task3-linux-mig"
  project              = var.spoke_project_id
  region               = var.spoke_region
  base_instance_name   = "${var.prefix}-spoke-${var.spoke_name}-task3-linux-vm"
  
  version {
    instance_template = var.deploy_task_3 ? google_compute_instance_template.task3_linux_template[0].id : null
  }

  target_size = 2

  distribution_policy {
    zones = [
      "${var.spoke_region}-a",
      "${var.spoke_region}-b"
    ]
  }

  named_port {
    name = "http"
    port = 80
  }
}

# Individual Linux VMs for each member
resource "google_compute_instance" "task3_linux_vms" {
  for_each     = var.deploy_task_3 ? { for idx, member in var.group_members : member.name => member } : {}
  provider     = google
  name         = "${var.prefix}-spoke-${var.spoke_name}-task3-${each.value.name}-linux-vm"
  project      = var.spoke_project_id
  zone         = "${var.spoke_region}-a"
  machine_type = var.linux_vm_machine_type
  tags         = ["${var.prefix}-spoke-${var.spoke_name}-task3-${each.value.name}-linux-vm"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = var.spoke_subnet_id
  }

  metadata_startup_script = templatefile("${path.module}/scripts/webserver.sh", {
    member_customizations = jsonencode([var.member_customizations[index(var.group_members, each.value)]])
  })
}