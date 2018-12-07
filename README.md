# terraform-vSphere-docker-ee
A Terraform Module for to run Docker Enterprise Edition (EE) on vSphere using Terraform and Packer

````
export TF_VAR_vsphere_password=<vsphere password>
export TF_VAR_root_password=<image root password>
terraform init
terraform apply -var-file pod1.tfvars
````
