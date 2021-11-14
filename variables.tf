#
# vCenter Server
#
variable "vcenter_server" {
  description = "vCenter Server hostname or IP"
  type        = string
}

variable "vcenter_user" {
  description = "vCenter Server username"
  type        = string
}

variable "vcenter_password" {
  description = "vCenter Server password"
  type        = string
}

variable "vcenter_insecure_ssl" {
  description = "Allow insecure connection to the vCenter server (unverified SSL certificate)"
  type        = bool
  default     = false
}

#
# Content Library
#
variable content_library_item_url {
  description = "OVA template URL"
  type = string
  default = "https://packages.vmware.com/photon/4.0/Rev1/ova/photon-ova-4.0-ca7c9e9330.ova"
}

variable content_library_name {
  description = "Name of the content library used to import the template"
  type = string
}

variable content_library_description {
  description = "Description of content library used to import the template"
  type = string
}

variable content_library_item_name {
  description = "Name of the imported OVA template VM"
  type = string
}

variable content_library_item_description {
  description = "Description of the imported OVA template VM"
  type = string
}

#
# vSphere
#
variable "vsphere_datacenter_str" {
  type    = string
}

variable "vsphere_compute_cluster_str" {
  type    = string
}

variable "vsphere_resource_pool_str" {
  type = string
}

variable "vsphere_datastore_str" {
  type    = string
  default = "vsanDatastore"
}

variable "vsphere_storage_policy_str" {
  type    = string
  default = "vSAN Default Storage Policy"
}

variable "vsphere_distributed_virtual_switch_str" {
  type    = string
  default = "DSwitch"
}

variable "vsphere_network_str" {
  type    = string
  default = "DPortGroup"
}

#
# Network
#
variable "network_domain_str" {
  type = string
  default = "home.lab"
}

variable "network_dns_suffix_list" {
  type = list(string)
}

variable "network_ipv4_subnet_str" {
  type    = string
}

variable "network_ipv4_subnet_ips_list" {
  type    = list(string)
}

variable "network_ipv4_subnet_gw_str" {
  type = string
}

variable "network_ipv4_dns_list" {
  type = list(string)
}

#
# VM
#
variable "vm_prefix_str" {
  description = "The prefix used for the VM name"
  type    = string
  default = "testvm"
}

variable "vm_count" {
  description = "The number of VM to create"
  type    = number
  default = 3
}

variable "vm_cpu" {
  description = "The number of vCPU"
  type    = number
  default = 2
}

variable "vm_memory_gb" {
  description = "The amount of RAM in GB"
  type    = number
  default = 4
}

variable "vm_os_disk_gb" {
  description = "The size of the OS disk"
  type    = number
  default = 40
}

variable "vm_data_disk_count" {
  description = "The quantity of shared disks"
  type    = number
  default = 2
}

variable "vm_data_disk_gb" {
  description = "The size of the shared data disks"
  type    = number
  default = 100
}

#
# EOF
#