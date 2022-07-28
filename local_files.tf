resource "local_file" "inventory" {
    filename = "./hosts"
    content = <<EOF
[slave]
${aws_instance.privateinstance.private_ip}
EOF
}


resource "local_file" "private_key" {
    filename = "./pk"
    file_permission = 0400
    content = <<EOF
${tls_private_key.ssh-key.private_key_pem}
EOF
}

resource "local_file" "sshconfig" {
    filename = "/jenkins_home/.ssh/config"
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
