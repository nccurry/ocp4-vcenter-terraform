variable "cluster_id" {
  description = "Unique identifier for OpenShift cluster"
}

variable "vcenter_server_name" {
  description = "vCenter server name to deploy resources into"
}

variable "vcenter_datacenter_name" {
  description = "Name of vCenter datacenter to deploy resources into"
}

variable "vcenter_cluster_name" {
  description = "Name of vCenter cluster to deploy resources into"
}

variable "vcenter_datastore_name" {
  description = "Name of vCenter datastore to deploy resources into"
}

variable "vcenter_network_name" {
  description = "Name of vCenter network to deploy resources into"
}

variable "vcenter_api_user" {
  description = "vCenter user for deploying resources"
}

variable "vcenter_api_password" {
  description = "vCenter password for deploying resources"
}

variable "vcenter_storage_user" {
  description = "vCenter user for dynamic OpenShift storage"
}

variable "vcenter_storage_password" {
  description = "vCenter password for dynamic OpenShift storage"
}

variable "vcenter_folder_path" {
  description = "vCenter directory to deploy cluster resources into"
}

variable "rhcos_template_name" {
  description = "Name of the RHCOS template in vCenter"
}

variable "bootstrap_vm" {
  description = "Dictionary of bootstrap name/mac pair"
  type = object({name = string, mac = string})
}

variable "bootstrap_cpus" {
  description = "Number of vCpus for bootstrap host"
}
variable "bootstrap_memory" {
  description = "Memory in MB for bootstrap host"
}

variable "bootstrap_disk" {
  description = "Storage in GB for bootstrap host disk"
}

variable "bootstrap_ignition_url" {
  description = "HTTP url to bootstrap ignition file"
}

variable "master_cpus" {
  description = "Number of vCpus for master host"
}
variable "master_memory" {
  description = "Memory in MB for master host"
}

variable "master_disk" {
  description = "Storage in GB for master host disk"
}

variable "master_ignition_path" {
  description = "Path to master ignition file"
}

variable "master_vm_list" {
  description = "List of dictionaries of master name/mac pairs"
  type = list(object({name = string, mac = string}))
}

variable "worker_cpus" {
  description = "Number of vCpus for worker host"
}
variable "worker_memory" {
  description = "Memory in MB for worker host"
}

variable "worker_disk" {
  description = "Storage in GB for worker host disk"
}

variable "worker_ignition_path" {
  description = "Path to worker ignition file"
}

variable "worker_vm_count" {
  description = "Number of worker virtual machines to deploy"
}

variable "worker_vm_list" {
  description = "List of dictionaries of worker name/mac pairs"
  type = list(object({name = string, mac = string}))
}
