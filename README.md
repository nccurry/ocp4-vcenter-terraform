# OpenShift 4 vCenter Terraform Deployment

The following process can be used to deploy an OpenShift 4 cluster into vCenter using terraform.

## Architectural Assumptions

* IP Addresses will be assigned by mapping MAC addresses on the DHCP server to MAC addresses on the RHCOS hosts.
* A seperate utility server will be used for terraform and serving the bootstrap ignition file

## Environmental Prerequisites

 * [Firewall Rules](https://docs.openshift.com/container-platform/4.1/installing/installing_vsphere/installing-vsphere.html#installation-network-user-infra_installing-vsphere)
 * [DNS Entires](https://docs.openshift.com/container-platform/4.1/installing/installing_vsphere/installing-vsphere.html#installation-dns-user-infra_installing-vsphere)
 * [Load Balancer Configuration](https://docs.openshift.com/container-platform/4.1/installing/installing_vsphere/installing-vsphere.html#installation-network-user-infra_installing-vsphere)
 * DHCP Server with preconfigured IP -> MAC mapping
 * Communication to Red Hat services on the internet
    * cloud.openshift.com
    * quay.io 
    * registry.connect.redhat.com
    * registry.redhat.io
    * api.openshift.com/api/upgrades_info/v1/graph
    * infogw.api.openshift.com
    * operatorhub.io
    * cloudfront.net

## vCenter Prerequisites

vCenter must be version 6.5 or 6.7u.

Two service accounts need to be created in vCenter. The first for terraform and the second for OpenShift storage. The vCenter documentation for 6.7 permissions can be found [here](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.security.doc/GUID-ED56F3C4-77D0-49E3-88B6-B99B8B437B62.html). 

### vCenter Terraform Service Account

This service account will need the following permissions

```
TBD
```

### vCenter OpenShift Storage Service Account

This service account will need the permissions specified [here](https://vmware.github.io/vsphere-storage-for-kubernetes/documentation/vcp-roles.html)

## Deploy cluster

### Input parameters

Copy the [main.yml.example](vars/main.yml.example) file to ```vars/main.yml``` and fill in all of the deployment parameters. 

### Deploying a cluster

```
$ ./playbooks/deploy_cluster.yml -v 
```

### Tearing down a cluster

```
$ ./playbooks/teardown_cluster.yml -v

```

## Logging in to RHCOS hosts

Logging in to RHCOS hosts is generally discouraged, but sometimes its nice to see whats going on. Red Hat CoreOS uses the ```core``` user.

```shell
ssh -i /path/to/id_rsa core@<bootstrap host>
```

## Monitor installation process

The following gets run from the utility server to complete the installation

```shell
# From utility host
OCP4_INSTALL_DIR=/path/to/dir
openshift-install --dir=${OCP4_INSTALL_DIR} wait-for bootstrap-complete --log-level debug

# From bootstrap host
journalctl -b -f -u bootkube.service
```

