# creating security group to allow the ssh traffic on port 22 in my created vpc for the public instances
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = module.my_network.vpc_id

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}
#creating security group to allow the ssh traffic on port 22 
#any traffic comes on port 3000 from my VPC CIDR range in my created vpc 
#for the private instances
resource "aws_security_group" "allow_3000" {
  name        = "allow_3000"
  description = "Allow 3000 inbound traffic"
  vpc_id      = module.my_network.vpc_id
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [module.my_network.vpc_CIDR]
  }
  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.my_network.vpc_CIDR]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_3000"
  }
}
resource "aws_security_group" "db_SG" {
  name        = "db_SG"
  description = "Allow 3306 inbound traffic"
  vpc_id      = module.my_network.vpc_id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [module.my_network.vpc_CIDR]
  }
  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.my_network.vpc_CIDR]
  }
  ingress {
    description = "elasticCache port from VPC "
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [module.my_network.vpc_CIDR]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "db_SG"
  }
}
resource "aws_security_group" "alb_sg" {
  name        = "alb sg"
  description = "my alb security group"
  vpc_id      = module.my_network.vpc_id

  ingress {
    description = "80 from any traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "my-alb-sg"
  }
}