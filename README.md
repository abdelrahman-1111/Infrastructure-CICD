# Infrastructure CI/CD for NodeJS app
## Brief on the project 
creating an automated pipeline using jenkins to create an infrstructure on AWS cloud using Terraform then deploy a Nodejs app on container in the private instance configured as slave node using Ansible, The application is connected to RDS and elasticCache then expose it using a loadbalancer.
## Extra features
uploading my statefile to s3 bucket to be synchronize with the changes my contributers do and to be able to trigger it with lambda function to send me mail with every update in it using AWS SES service 
## Tools and Services i used in this project
* Terraform for deploying IaC on cloud provider
* AWS as my cloud provider
* Jenkins for creating the pipeline 
* Ansible to configure my jenkins slave node
* AWS Simple Storage Service (S3) to store my terraform statefile
* lambda function to trigger any updates on the statefile
* TLS provider to generate private and public keys to ssh the instances

### So, lets begin with the infrastructre
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
4. allow tcp on port 80 for the loadbalancer 

### Now i need to create private and public keys to be able ssh my instances securely 
I used TLS provider to generate public and private keys using TLS provider with Terraform then i create a key_pair resource to store my public key and secret manager to store my private key 

### Now i can create my instances securely 
I deployed 2 instances the first have the following configurations:
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

### create the RDS 
```
resource "aws_db_subnet_group" "private_db_group" {
  name       = "main"
  subnet_ids = [module.my_network.private2_subnet_id , module.my_network.private1_subnet_id ]

  tags = {
    Name = "My DB subnet group"
  }
}
resource "aws_elasticache_subnet_group" "private_cache_group" {
  name       = "cache-subnet-group"
  subnet_ids = [module.my_network.private2_subnet_id , module.my_network.private1_subnet_id ]
}

resource "aws_db_instance" "myDB" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  name                   = "mydb"
  username               = "hamada"
  password               = "123456789"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  port                   = 3306
  vpc_security_group_ids = [aws_security_group.db_SG.id]
  db_subnet_group_name   = aws_db_subnet_group.private_db_group.name
  ```
### create the elasticCache 
```
resource "aws_elasticache_cluster" "my_cache_DB" {
  cluster_id           = "my-cluster"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
  subnet_group_name = aws_elasticache_subnet_group.private_cache_group.name
  security_group_ids = [aws_security_group.db_SG.id]
}
```
### creating the loadbalancer 
To create a loadbalancer i need to create first a target group to include my private instance 
```
resource "aws_lb_target_group" "tg" {
    name     = "my-lb-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = module.my_network.vpc_id
}

//i need to create TG attachment to attach my instance 
resource "aws_lb_target_group_attachment" "tg_attach" {
    target_group_arn = aws_lb_target_group.tg.arn
    target_id        = aws_instance.bastionHost.id
    port             = 80
}

```
then to create loadbalancer i needed to create a loadbalancer listeners to attach the security group to my loadbalancer
```
resource "aws_lb" "alb" {
    name               = "my-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.alb_sg.id]
    subnets            = [module.my_network.public1_subnet_id, module.my_network.public2_subnet_id]

}


resource "aws_lb_listener" "alb_listener" {
    load_balancer_arn = aws_lb.alb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
    }
}
```

## Creating two tfvars files for both dev and prod workspaces 
I created two diffrenet tfvars files, each have a diffrenet declaraton for some variables as the region of the VPC as example
and now each workspace have its individual statefile saved in the same S3 bucket but in diffrenet directory under the env::/ directory.

# Jenkins setup
to setup up jenkins to run my terraform code i did the following:
1. install the terraform plugin then install its packages manually in its runnning container
![image](https://user-images.githubusercontent.com/104630009/181840046-2e9866ef-5b0a-441b-a2c8-8ca1e24f59b6.png)

2. create credentials to authorize jenkins to create my resources on AWS so i used a plugin called cloudBees AWS Credentials and saved my access and secret access keys in it 
![image](https://user-images.githubusercontent.com/104630009/181839876-769030f0-5127-4c05-910b-d7c72e113e4a.png)

3. create a jenkinsfile and push it to my repo 
```
pipeline {
    agent any
        stages {
            stage('terraform init') {
                steps {
                    withAWS(credentials: 'aws_credential', region: 'us-east-1'){
                    sh 'terraform init -upgrade -no-color'}
                }
            }
```
# Configure the private vm as a slave node 
Now i need to configure the private instance as a slave node and since i need to configure a server, ofcourse i am gonna use Ansible as my configuration managment tool but now i have a small issue which is my private instance does not have a public ip so i did the following to be able to SSH to it and configure it 
1. Install ansible on my jenkins container 
```
apt install ansible -y 
```
2. using terraform local_file to create a local file under .ssh directory in the home of the root (root/.ssh/config) and configure the public instance as a bastion server (jumpHost) 
using a proxycommand to my private instance 
```
resource "local_file" "sshconfig" {
    filename = "/root/.ssh/config"
    depends_on = [local_file.private_key]
    content = <<EOF
Host bastion
    User ubuntu
    HostName ${aws_instance.bastionHost.public_ip}
    IdentityFile "/var/jenkins_home/pk"
Host ${aws_instance.privateinstance.private_ip}
    Port 22
    User ubuntu
    ProxyCommand ssh -o StrictHostKeyChecking=no -A -W %h:%p -q bastion
    StrictHostKeyChecking no
    IdentityFile "/var/jenkins_home/pk"
EOF
}
```

3. create an ansible.cfg file to set my defaults configuration like set my default ssh_config file the one i created and the default inventory file
![image](https://user-images.githubusercontent.com/104630009/181841820-e44d2d2c-8928-4ac2-9f35-c43dda958f28.png)

4. create a file to store the private key i created using tls resource 
```
resource "local_file" "inventory" {
    filename = "/var/jenkins_home/hosts"
    content = <<EOF
[slave]
${aws_instance.privateinstance.private_ip}
EOF
}
```
5. create inventory file store the private ip of my instance 
```
resource "local_file" "private_key" {
    filename = "/var/jenkins_home/pk"
    file_permission = 0400
    content = <<EOF
${tls_private_key.ssh-key.private_key_pem}
EOF
}
```

### Now everything is set up i can create my ansible playbook to configure my private incstance 
- creating directory to be the root directory for jenkins
- java runtime (jdk-11)
- docker 
- coping the agent.jar file 
```
- name: Configure as slave
  hosts: slave
  remote_user: ubuntu
  tasks:
    - name: update
      apt:
        update_cache : yes

    - name: create Jenkins directory
      file:
        path: /home/ubuntu/jenkins
        mode : '0777'
        state: directory

    - name: install open-jdk
      apt:
        name: openjdk-11-jdk
        state: present

    - name: coping and installing agent.jar
      ansible.builtin.copy:
        src: /var/jenkins_home/workspace/terraform-aws/agent.jar
        dest: /home/ubuntu/jenkins/agent.jar
        owner: ubuntu
        group: ubuntu
        mode: '0744'

    - name: Install apt-transport-https
      ansible.builtin.apt:
          name:
            - apt-transport-https
            - ca-certificates
            - lsb-release
            - gnupg
          state: latest
          update_cache: true

    - name: Add signing key
      ansible.builtin.apt_key:
          url: "https://download.docker.com/linux/ubuntu/gpg"
          state: present

    - name: Add repository into sources list
      ansible.builtin.apt_repository:
          repo: "deb https://download.docker.com/linux/ubuntu focal stable"
          state: present
          filename: docker

    - name: Install Docker
      ansible.builtin.apt:
          name:
            - docker-ce
            - docker-ce-cli
            - containerd.io
          state: latest
          update_cache: true

    - name: Install Docker
      ansible.builtin.apt:
          name:
            - docker-ce
            - docker-ce-cli
            - containerd.io
          state: latest
          update_cache: true
```
### now i just need to create a new slave node from my jenkins UI 
![image](https://user-images.githubusercontent.com/104630009/181843824-a5abb1ee-b5c1-4dbe-ad4b-40aa35268d11.png)
# deploy Nodejs app on the slave node 
### since i need to get clone for only one branch from this repo i used the following command 
``` git clone -b <branch-name> <repo-url> ```
### then i build the code on the private instance using my jenkinsfile by choosing its tag node in my pipline but i needed first to grant the user ubuntu permmission to group docker to be able to talk to the docker daemon 
```
            stage('build the application'){
                agent { node { label 'slave-vm'} }
                steps {
                    sh '''
                        sudo usermod -aG docker ubuntu
                        cd ./Nodeapp
                        docker build -f dockerfile -t nodejsapp .
                    '''    
                }
            }
```
### now run the image and attach the needed environment variables to be linked with my created RDS and elasticCache memory 
```
            stage('deploy the application'){
                agent { node { label 'slave-vm'} }
                steps {
                sh '''
                    docker run -itd 
                    -p 3000:3000 
                    -e RDS_HOSTNAME='terraform-20220728170537991100000001.cxzwdfnbla9f.us-east-1.rds.amazonaws.com' 
                    -e RDS_USERNAME='hamada' 
                    -e RDS_PASSWORD='*******' 
                    -e RDS_PORT='3306' 
                    -e REDIS_HOSTNAME='my-cluster.ux1pec.0001.use1.cache.amazonaws.com' 
                    -e REDIS_PORT='3000' 
                    nodejsapp
                '''
                }
            }
```
