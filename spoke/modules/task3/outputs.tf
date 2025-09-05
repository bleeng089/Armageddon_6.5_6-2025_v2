output "windows_vm_public_ip" {
  description = "Public IP address of the Windows VM for RDP access"
  value       = var.deploy_task_3 ? google_compute_instance.task3_windows_vm[0].network_interface[0].access_config[0].nat_ip : null
}

output "internal_lb_ip_address" {
  description = "Internal IP address of the load balancer (copy-paste into browser)"
  value       = var.deploy_task_3 ? google_compute_address.task3_internal_lb_ip[0].address : null
}

output "internal_lb_url" {
  description = "Full URL to access the internal load balancer"
  value       = var.deploy_task_3 ? "http://${google_compute_address.task3_internal_lb_ip[0].address}" : null
}

output "windows_vm_rdp_command" {
  description = "RDP command to connect to the Windows VM"
  value       = var.deploy_task_3 ? "mstsc /v:${google_compute_instance.task3_windows_vm[0].network_interface[0].access_config[0].nat_ip}" : null
}

output "internal_dns_zone_name" {
  description = "Name of the internal DNS zone"
  value       = var.deploy_task_3 ? google_dns_managed_zone.task3_internal_zone[0].name : null
  sensitive   = true
}

output "internal_lb_dns_name" {
  description = "DNS name of the internal load balancer"
  value       = var.deploy_task_3 ? "internal-lb.${google_dns_managed_zone.task3_internal_zone[0].dns_name}" : null
  sensitive   = true
}

# Additional useful outputs
output "windows_vm_name" {
  description = "Name of the Windows VM"
  value       = var.deploy_task_3 ? google_compute_instance.task3_windows_vm[0].name : null
}

output "windows_vm_zone" {
  description = "Zone where the Windows VM is deployed"
  value       = var.deploy_task_3 ? google_compute_instance.task3_windows_vm[0].zone : null
}

output "linux_mig_name" {
  description = "Name of the Linux managed instance group"
  value       = var.deploy_task_3 ? google_compute_region_instance_group_manager.task3_linux_mig[0].name : null
}

output "public_subnet_name" {
  description = "Name of the public subnet for Windows VM"
  value       = var.deploy_task_3 ? google_compute_subnetwork.task3_public_subnet[0].name : null
}