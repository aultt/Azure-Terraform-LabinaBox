# Single Region POC Landing Zone
Terraform deployment to build a single region Hub and Spoke Landing Zone to enable building out POC and performance tests.

# Dependencies
Engineer deploying needs to have the following:
1. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/azure-get-started)
3. [Visual Studio Code](https://code.visualstudio.com/)
4. [Clone of GitHub Repo](https://github.com/aultt/Azure-Terraform-LabinaBox) 

# Build and Test
Prior to deploying you will want to look over and confirm/modify variables within the deployment.  

## Template Variable Files
A Sample variable file has been provided for each Level with the required variables which should be configured.  Variable files are named level2_template.tfvars and level3_template.tfvars. Any additional variables you would like to change can be added to these files. Once updated you can run the following terraform init -var-file=levle2_template.tfvars followed by terraform apply -var-file=level2_template.tfvars from within the directory.  

## Level 2
Terraform module will deploy all the networking and shared services required.

### Variables which must be updated
1. poc_subscription_id
2. corp_prefix 
3. jump_host_password
4. vpn_shared_key *
5. gateway_ip_address *
6. domain_name *
7. domain_ip *
8. domain_NetbiosName *
9. domain_admin_password * 
* Not needed if you you take defaults as Hybrid connectivity is disabled.  Variable needs to be defined so leave in file.

## Level 3
Terraform module deploys NVA appliance and JumpHost/Dev Machine.  

### Variables which must be updated
1. poc_subscription_id
2. corp_prefix 
3. local_admin_password

## TODO Items: 
1. Only Defaults have been tested to date
2. Modify Domain Controller configuration to create a new domain.
3. Provide a switch to choose if you are creating a new domain or using an existing
4. Add validation to Variables


