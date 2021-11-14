output "vms" {
  value = concat(vsphere_virtual_machine.vsphere_virtual_machine_primary.*.name, vsphere_virtual_machine.vsphere_virtual_machine_secondary.*.name)
}