#
# Provider
#

# https://www.terraform.io/docs/providers/vsphere/index.html
provider "vsphere" {
  user                 = var.vcenter_api_user
  password             = var.vcenter_api_password
  vsphere_server       = var.vcenter_server_name
  allow_unverified_ssl = true
}

#
# Data
#

# https://www.terraform.io/docs/providers/vsphere/d/datacenter.html
data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter_name
}

# https://www.terraform.io/docs/providers/vsphere/d/compute_cluster.html
data "vsphere_compute_cluster" "compute_cluster" {
  name          = var.vcenter_cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# https://www.terraform.io/docs/providers/vsphere/d/datastore.html
data "vsphere_datastore" "datastore" {
  name          = var.vcenter_datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# https://www.terraform.io/docs/providers/vsphere/d/network.html
data "vsphere_network" "network" {
  name          = var.vcenter_network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# https://www.terraform.io/docs/providers/vsphere/d/virtual_machine.html
data "vsphere_virtual_machine" "template" {
  name          = var.rhcos_template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# https://www.terraform.io/docs/providers/ignition/index.html
data "ignition_config" "bootstrap" {
  append {
    source = var.bootstrap_ignition_url
  }
}

#
# Resources
#

# https://www.terraform.io/docs/providers/vsphere/r/virtual_machine.html
resource "vsphere_virtual_machine" "bootstrap" {
  name             = "ocp-${var.cluster_id}-bootstrap"
  resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id 
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.bootstrap_cpus
  memory           = var.bootstrap_memory
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  folder           = var.vcenter_folder_path
  enable_disk_uuid = "true"

  wait_for_guest_net_timeout  = "0"
  wait_for_guest_net_routable = "false"

  network_interface {
    network_id = data.vsphere_network.network.id
    use_static_mac = true
    mac_address = var.bootstrap_vm_mac
  }

  disk {
    label            = "disk0"
    size             = var.bootstrap_disk
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  vapp {
    properties = {
      guestinfo.ignition.config.data          = base64encode(data.ignition_config.bootstrap.rendered)
      guestinfo.ignition.config.data.encoding = "base64"
    }
  }
}

# https://www.terraform.io/docs/providers/vsphere/r/virtual_machine.html
resource "vsphere_virtual_machine" "master" {
  count = 3

  name             = "ocp-${var.cluster_id}-master-${count.index}"
  resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id 
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.master_cpus
  memory           = var.master_memory
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  folder           = var.vcenter_folder_path
  enable_disk_uuid = "true"

  wait_for_guest_net_timeout  = "0"
  wait_for_guest_net_routable = "false"

  network_interface {
    network_id = data.vsphere_network.network.id
    use_static_mac = true
    mac_address = var.master_vm_mac_list[count.index]
  }

  disk {
    label            = "disk0"
    size             = var.master_disk
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  vapp {
    properties = {
      guestinfo.ignition.config.data          = base64encode(file(var.master_ignition_path))
      guestinfo.ignition.config.data.encoding = "base64"
    }
  }
}

# https://www.terraform.io/docs/providers/vsphere/r/virtual_machine.html
resource "vsphere_virtual_machine" "worker" {
  count = var.worker_vm_count

  name             = "ocp-${var.cluster_id}-worker-${count.index}"
  resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id 
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.worker_cpus
  memory           = var.worker_memory
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  folder           = var.vcenter_folder_path
  enable_disk_uuid = "true"

  wait_for_guest_net_timeout  = "0"
  wait_for_guest_net_routable = "false"

  network_interface {
    network_id = data.vsphere_network.network.id
    use_static_mac = true
    mac_address = var.worker_vm_mac_list[count.index]
  }

  disk {
    label            = "disk0"
    size             = var.worker_disk
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  vapp {
    properties = {
      guestinfo.ignition.config.data          = base64encode(file(var.worker_ignition_path))
      guestinfo.ignition.config.data.encoding = "base64"
    }
  }
}