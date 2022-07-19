# Terraform-AWS
I deployed the basic infrstructure on AWS provider using Terraform with 2 diffrenet workspaces (dev/prod) and 2 .tfvars file and uploading my statefile to s3 bucket to be synchronize with the changes my contributers do and to be able to trigger it with lambda function to send me mail with every update in it using AWS SES service 
## Tools and Services i used in this project
* Terraform for deploying IaC on cloud provider
* AWS as my cloud provider
* AWS Simple Storage Service (S3) to store my statefile
* lambda function to trigger any updates on the statefile
* TLS provider to generate private and public keys to ssh the instances
* AWS secret manager to store my private key 
### So, lets begin with the infrastructre i have deployed 
first i created a module and name it network to contains all my network configurations to be re-usable 
1. A VPC with CIDR range as a variable to be easily modified 
2. 4 subnets in it having CIDR range and availiablty zone as variables too
3. An internet gatway 
4. A NAT gatway and ElasticIP 
5. 2 route tables to assign the internet gatwa and NAT gatway to my vpc 
6. 4 route tables association as 2 for route 2 og=f my subnets to the internet gatway to be public and 2 to assign the anothers with the NAT gatway to be private
### After i setup my network infrastructure, i have to configure my firewalls, so i created the following security groups
1. allow tcp on port 22 from anywhere (to ssh my public bastion Host)
2. allow tcp on port 22 from my VPC CIDR range only > to ssh my private instance from bastion Host
3. alllow tcp on port2 3306 and 6379 from my VPC CIDR range only > to access my RDS instance and ElasticCashe cluster

### Now i need to create private and public keys to be able ssh my instances securely 
I used TLS provider to generate public and private keys using TLS provider with Terraform then i create a key_pair resource to store my public key and secret manager to store my private key 

### Now i can deploy my instances securely 
i deployed 2 instances the first have the following configurations:
* The AMI and instance type as varaibles to easily modify later
* external ip
* attached to one of the public subnets
* Attached to security group which allow the ingress from anywhere on port 22 
* Assigned to it the key_pair resource which holds my public key
* A provisioner to stores the public ip to local text file 

The Second have the following configurations:
* The AMI and instance type as varaibles to easily modify later
* Without external ip
* attached to one of the private subnets
* Attached to security group which allow the ingress from my VPC CIDR range only on port 22 
* Assigned to it the key_pair resource which holds my public key
> After copying the private key stored in the secret manager, I can now ssh into my private instance from the bastion

## Creating two tfvars files for both dev and prod workspaces 
I created two diffrenet tfvars files, each have a diffrenet declaraton for some variables as the region of the VPC as example
and now each workspace have its individual statefile saved in the same S3 bucket but in diffrenet directory under the env::/ directory.
