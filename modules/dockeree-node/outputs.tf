output "hostnames" {
  value = ["${vsphere_virtual_machine.dockeree.*.name}"]
}

output "node_ips" {
  value = ["${vsphere_virtual_machine.dockeree.*.default_ip_address}"]
}

output "resource_ids" {
  value = ["${vsphere_virtual_machine.dockeree.*.id}"]
}
