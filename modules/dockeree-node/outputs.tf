output "hostnames" {
  value = ["${vsphere_virtual_machine.dockeree.*.name}"]
}

output "public_ips" {
  value = ["${vsphere_virtual_machine.dockeree.*.default_ip_address}"]
}
