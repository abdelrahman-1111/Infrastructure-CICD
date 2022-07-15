
resource "aws_instance" "bastionHost" {
  ami                         = "ami-052efd3df9dad4825"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public1.id
  key_name                    = aws_key_pair.generated_key.key_name
  associate_public_ip_address = true
  security_groups             = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "bastionHost"
  }
}
resource "aws_instance" "privateinstance" {
  ami             = "ami-052efd3df9dad4825"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private1.id
  security_groups = [aws_security_group.allow_3000.id]
  key_name        = aws_key_pair.generated_key.key_name
  tags = {
    Name = "private-instance"
  }
}