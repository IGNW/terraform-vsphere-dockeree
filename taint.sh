terraform taint -module=docker-manager-primary vsphere_virtual_machine.dockeree
terraform taint -module=docker-manager vsphere_virtual_machine.dockeree
terraform taint -module=docker-worker vsphere_virtual_machine.dockeree
terraform taint -module=docker-dtr vsphere_virtual_machine.dockeree
