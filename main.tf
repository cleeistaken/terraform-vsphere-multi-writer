#
# vSphere Provider
#
provider "vsphere" {
  vsphere_server       = var.vcenter_server
  user                 = var.vcenter_user
  password             = var.vcenter_password
  allow_unverified_ssl = var.vcenter_insecure_ssl
}

#
# vSphere
#
data "vsphere_datacenter" "vsphere_datacenter_0" {
  name = var.vsphere_datacenter_str
}

data "vsphere_compute_cluster" "vsphere_compute_cluster_0" {
  name          = var.vsphere_compute_cluster_str
  datacenter_id = data.vsphere_datacenter.vsphere_datacenter_0.id
}

resource "vsphere_resource_pool" "vsphere_resource_pool_0" {
  name                    = var.vsphere_resource_pool_str
  parent_resource_pool_id = data.vsphere_compute_cluster.vsphere_compute_cluster_0.resource_pool_id
}

data "vsphere_datastore" "vsphere_datastore_0" {
  name          = var.vsphere_datastore_str
  datacenter_id = data.vsphere_datacenter.vsphere_datacenter_0.id
}

data "vsphere_storage_policy" "vsphere_storage_policy_0" {
  name = var.vsphere_storage_policy_str
}

data "vsphere_distributed_virtual_switch" "vsphere_distributed_virtual_switch_0" {
  name          = var.vsphere_distributed_virtual_switch_str
  datacenter_id = data.vsphere_datacenter.vsphere_datacenter_0.id
}

data "vsphere_network" "vsphere_network_0" {
  name                            = var.vsphere_network_str
  datacenter_id                   = data.vsphere_datacenter.vsphere_datacenter_0.id
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.vsphere_distributed_virtual_switch_0.id
}

#
# Content Library
#
resource "vsphere_content_library" "vsphere_content_library_0" {
  name            = var.content_library_name
  description     = var.content_library_description
  storage_backing = [data.vsphere_datastore.vsphere_datastore_0.id]
}

resource "vsphere_content_library_item" "vsphere_content_library_item_0" {
  name        = var.content_library_item_name
  description = var.content_library_item_description
  library_id  = vsphere_content_library.vsphere_content_library_0.id
  file_url    = var.content_library_item_url
}

#
# This is the first VM that will hold the shared disk
#
resource "vsphere_virtual_machine" "vsphere_virtual_machine_primary" {
  count = 1
  name  = format("%s-%02d", var.vm_prefix_str, count.index + 1)

  # Template boot mode (efi or bios)
  #firmware = var.template_boot

  # Resource pool for created VM
  resource_pool_id = vsphere_resource_pool.vsphere_resource_pool_0.id

  # Datastore and Storage Policy
  datastore_id      = data.vsphere_datastore.vsphere_datastore_0.id
  storage_policy_id = data.vsphere_storage_policy.vsphere_storage_policy_0.id

  # CPU and Memory
  num_cpus = var.vm_cpu
  memory   = var.vm_memory_gb * 1024

  network_interface {
    network_id  = data.vsphere_network.vsphere_network_0.id
    ovf_mapping = "eth0"
  }

  # OS Disk
  disk {
    label       = format("%s-%02d-os-disk0", var.vm_prefix_str, count.index + 1)
    size        = var.vm_os_disk_gb
    unit_number = 0
  }

  dynamic "disk" {
    # The OS disk has unit number 0 so we shift the range by 1 in
    # order to make the data disk unit number start from 1.
    for_each = range(1, var.vm_data_disk_count + 1)

    content {
      label             = format("%s-%02d-data-disk%02d", var.vm_prefix_str, count.index + 1, disk.value)
      size              = var.vm_data_disk_gb
      storage_policy_id = data.vsphere_storage_policy.vsphere_storage_policy_0.id
      disk_sharing      = "sharingMultiWriter"
      unit_number       = disk.value
    }
  }

  clone {
    template_uuid = vsphere_content_library_item.vsphere_content_library_item_0.id

    customize {
      linux_options {
        host_name = format("%s-%02d", var.vm_prefix_str, count.index + 2)
        domain    = var.network_domain_str
      }

      network_interface {
        ipv4_address = var.network_ipv4_subnet_ips_list[count.index + 1]
        ipv4_netmask = regex("/([0-9]{1,2})$", var.network_ipv4_subnet_str)[0]
      }

      ipv4_gateway    = var.network_ipv4_subnet_gw_str
      dns_server_list = var.network_ipv4_dns_list
      dns_suffix_list = var.network_dns_suffix_list

    }
  }
}

resource "vsphere_virtual_machine" "vsphere_virtual_machine_secondary" {
  count = var.vm_count - 1
  name  = format("%s-%02d", var.vm_prefix_str, count.index + 2)

  # Template boot mode (efi or bios)
  #firmware = var.template_boot

  # Resource pool for created VM
  resource_pool_id = vsphere_resource_pool.vsphere_resource_pool_0.id

  # Datastore and Storage Policy
  datastore_id      = data.vsphere_datastore.vsphere_datastore_0.id
  storage_policy_id = data.vsphere_storage_policy.vsphere_storage_policy_0.id

  num_cpus = var.vm_cpu
  memory   = var.vm_memory_gb * 1024

  network_interface {
    network_id  = data.vsphere_network.vsphere_network_0.id
    ovf_mapping = "eth0"
  }

  disk {
    label       = format("%s-%02d-os-disk0", var.vm_prefix_str, count.index + 2)
    size        = var.vm_os_disk_gb
    unit_number = 0
  }

  dynamic "disk" {

    for_each = range(1, var.vm_data_disk_count + 1)

    content {
      attach          = true
      datastore_id    = data.vsphere_datastore.vsphere_datastore_0.id
      path            = vsphere_virtual_machine.vsphere_virtual_machine_primary[0].disk[disk.value].path
      label           = format("%s-%02d-data-disk%02d", var.vm_prefix_str, count.index + 2, disk.value)
      disk_sharing    = "sharingMultiWriter"
      unit_number     = disk.value
      controller_type = "scsi"
    }
  }


  clone {
    template_uuid = vsphere_content_library_item.vsphere_content_library_item_0.id

    customize {
      linux_options {
        host_name = format("%s-%02d", var.vm_prefix_str, count.index + 2)
        domain    = var.network_domain_str
      }

      network_interface {
        ipv4_address = var.network_ipv4_subnet_ips_list[count.index + 1]
        ipv4_netmask = regex("/([0-9]{1,2})$", var.network_ipv4_subnet_str)[0]
      }

      ipv4_gateway    = var.network_ipv4_subnet_gw_str
      dns_server_list = var.network_ipv4_dns_list
      dns_suffix_list = var.network_dns_suffix_list

    }
  }
}

# Anti-affinity rule
resource "vsphere_compute_cluster_vm_anti_affinity_rule" "gfs_vm_anti_affinity_rule" {
  count               = var.vm_count > 0 ? 1 : 0
  name                = "vm-anti-affinity-rule"
  compute_cluster_id  = data.vsphere_compute_cluster.vsphere_compute_cluster_0.id
  virtual_machine_ids = concat(vsphere_virtual_machine.vsphere_virtual_machine_primary.*.id, vsphere_virtual_machine.vsphere_virtual_machine_secondary.*.id)
}

