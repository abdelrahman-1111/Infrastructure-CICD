#creating the bastionHost instance with ubunti AMI in public-subnet1
#having the public security group which allow any ssh on port 22 from anywhere
resource "aws_instance" "bastionHost" {
  ami                         = var.instances_AMI
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public1.id
  key_name                    = aws_key_pair.generated_key.key_name #attach the public key i created and saved its private one in secrets manager
  associate_public_ip_address = true                                #to provide it with public ip 
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "bastionHost"
  }
}
#creating the private instance with same ubunto AMI in private1-subnet 
#having security group allow any traffic on port 3000 and ssh protocol on port 22 from my vpc CIDR range only
resource "aws_instance" "privateinstance" {
  ami                    = var.instances_AMI
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private1.id
  vpc_security_group_ids = [aws_security_group.allow_3000.id]
  key_name               = aws_key_pair.generated_key.key_name #attach the public key i created and saved its private one in secrets manager
  tags = {
    Name = "private-instance"
  }
}