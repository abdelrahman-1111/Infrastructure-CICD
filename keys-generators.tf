# creating a key-pair to ssh my instances
resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
#saving the public key in key-pair resource to attach it with my instances 
resource "aws_key_pair" "generated_key" {
  key_name   = "ssh-key"
  public_key = tls_private_key.ssh-key.public_key_openssh
}
#creating secrets manager to hold my private key 
resource "aws_secretsmanager_secret" "my-key-holder" {
  name                    = "my-key-holder"
  recovery_window_in_days = 0
}
#attach my private key to the sercrets manager
resource "aws_secretsmanager_secret_version" "mysecret-version" {
  secret_id     = aws_secretsmanager_secret.my-key-holder.id
  secret_string = tls_private_key.ssh-key.private_key_pem
}