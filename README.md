# terraform-vSphere-docker-ee
A Terraform Module for to run Docker Enterprise Edition (EE) on vSphere using Terraform and Packer

````
export TF_VAR_vsphere_password=<vsphere password>
export TF_VAR_terraform_password=<password for 'terraform' account on the image>
cp terraform.tfvars.sample terraform.tfvars
<edit terraform.tfvars for your environment>
terraform init
terraform apply -var-file pod1.tfvars
````
