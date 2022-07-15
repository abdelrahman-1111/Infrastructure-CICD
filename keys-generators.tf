
resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "ssh-key"
  public_key = tls_private_key.ssh-key.public_key_openssh
}
resource "aws_secretsmanager_secret" "my-key-holder" {
  name                    = "my-key-holder"
  recovery_window_in_days = 0
}
resource "aws_secretsmanager_secret_version" "mysecret-version" {
  secret_id     = aws_secretsmanager_secret.my-key-holder.id
  secret_string = tls_private_key.ssh-key.private_key_pem
}