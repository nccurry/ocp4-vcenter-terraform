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

## Configure utility server 

```shell
# Configure HTTPD for service ignition files
sudo yum -y install httpd
sudo mkdir -p /var/www/html/ignition
sudo systemctl enable httpd
sudo systemctl start httpd
sudo firewall-cmd --permanent --service http
sudo firewall-cmd --reload

# Install terraform
TERRAFORM_VERSION=0.12.7
TERRAFORM_URL=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
wget ${TERRAFORM_URL}
sudo unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/

# Install openshift-install
OCP_INSTALL_VERSION=4.1.13
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP4_INSTALL_VERSION}/openshift-install-linux-${OCP4_INSTALL_VERSION}.tar.gz
tar -zxvf openshift-install-linux-${OCP4_INSTALL_VERSION}.tar.gz
sudo mv openshift-install /usr/local/bin/openshift-install
```

## Create install-config.yml

Documentation for values in the OpenShift 4 installation file can be found in the official documentation under [Sample install-config.yaml file for VMware vSphere](https://docs.openshift.com/container-platform/4.1/installing/installing_vsphere/installing-vsphere.html#installation-vsphere-config-yaml_installing-vsphere)

## Fill out terraform.tfvars

An example file can be found at [terraform.tfvars.example](terraform.tfvars.example). Copy it and replace the values.

## Generate ignition files

 You will need to regenerate the ignition configuration every 24 hours as the certificates for cluster installation expire.

```shell
# Delete old ignition files
OCP4_INSTALL_DIR=/path/to/dir
rm -rf ${OCP4_INSTALL_DIR}
mkdir -p ${OCP4_INSTALL_DIR}

# Regenerate ignition files
openshift-install create ignition-configs --dir=${OCP4_INSTALL_DIR}

# Copy bootstrap ignition file to web server directory
cp -f ${OCP4_INSTALL_DIR}/bootstrap.ign /var/www/html/ignition/bootstrap.ign
```

## Run terraform

The following must be run from this directory.

```shell
OCP4_TERRAFORM_VARS_PATH=/path/to/terraform.tfvars

# Initialize terraform
terraform init

# Deploy infrastructure
terraform apply -var-file=${OCP4_TERRAFORM_VARS_PATH} -auto-approve

# Teardown infrastructure
terraform apply -var-file=${OCP4_TERRAFORM_VARS_PATH} -auto-approve
```

## Monitor installation process

The following gets run from the utility server to complete the installation

```shell
OCP4_INSTALL_DIR=/path/to/dir
openshift-install --dir=${OCP4_INSTALL_DIR} wait-for bootstrap-complete --log-level debug
```

## Logging in to RHCOS hosts

Logging in to RHCOS hosts is generally discouraged, but sometimes its nice to see whats going on. Red Hat CoreOS uses the ```core``` user.

```shell
ssh -i /path/to/id_rsa core@<bootstrap host>
```