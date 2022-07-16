resource "aws_db_subnet_group" "private_db_group" {
  name       = "main"
  subnet_ids = [module.my_network.private2_subnet_id]

  tags = {
    Name = "My DB subnet group"
  }
}
resource "aws_db_instance" "myDB" {
  allocated_storage      = 2
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  name                   = "mydb"
  username               = var.RDS_user
  password               = var.RDS_pass
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  port                   = 3306
  vpc_security_group_ids = ["aws_security_group.db_SG.id"]
  db_subnet_group_name   = "aws_db_subnet_group.private_db_group.name"
}

