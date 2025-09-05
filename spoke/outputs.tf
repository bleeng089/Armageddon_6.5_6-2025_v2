output "spoke_subnet_cidr" {
  value = module.ncc_spoke.spoke_subnet_cidr
}

output "spoke_asn" {
  value = module.ncc_spoke.spoke_asn
}

output "spoke_vpn_gateway_id" {
  value = module.ncc_spoke.spoke_vpn_gateway_id
}

output "spoke_test_vm_name" {
  value = module.ncc_spoke.spoke_test_vm_name
}

output "spoke_test_vm_internal_ip" {
  value = module.ncc_spoke.spoke_test_vm_internal_ip
}


output "spoke_test_vm_self_link" {
  value = module.ncc_spoke.spoke_test_vm_self_link
}

output "spoke_vpn_tunnel_ids" {
  value = module.ncc_spoke.spoke_vpn_tunnel_ids
}

####################################
######### Task 3 OUTPUTS ###########
####################################

output "windows_vm_public_ip" {
  description = "Public IP address of the Windows VM for RDP access"
  value       = module.task3.windows_vm_public_ip
}

output "internal_lb_ip_address" {
  description = "Internal IP address of the load balancer (copy-paste into browser)"
  value       = module.task3.internal_lb_ip_address
}

output "internal_lb_url" {
  description = "Full URL to access the internal load balancer"
  value       = module.task3.internal_lb_url
}

output "windows_vm_rdp_command" {
  description = "RDP command to connect to the Windows VM"
  value       = module.task3.windows_vm_rdp_command
}

output "internal_dns_zone_name" {
  description = "Name of the internal DNS zone"
  value       = module.task3.internal_dns_zone_name
  sensitive   = true
}

output "internal_lb_dns_name" {
  description = "DNS name of the internal load balancer"
  value       = module.task3.internal_lb_dns_name
  sensitive   = true
}

output "windows_vm_name" {
  description = "Name of the Windows VM"
  value       = module.task3.windows_vm_name
}

output "windows_vm_zone" {
  description = "Zone where the Windows VM is deployed"
  value       = module.task3.windows_vm_zone
}

output "linux_mig_name" {
  description = "Name of the Linux managed instance group"
  value       = module.task3.linux_mig_name
}

output "public_subnet_name" {
  description = "Name of the public subnet for Windows VM"
  value       = module.task3.public_subnet_name
}

