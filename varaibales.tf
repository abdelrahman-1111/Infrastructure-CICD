variable "region" {
  type    = string
  default = "us-east-1"
}
variable "vpc_CIDR" {
  type    = string
  default = "10.0.0.0/16"
}
variable "public_subnet1_CIDR" {
  type    = string
  default = "10.0.1.0/24"
}
variable "public_subnet2_CIDR" {
  type    = string
  default = "10.0.2.0/24"
}
variable "private_subnet1_CIDR" {
  type    = string
  default = "10.0.3.0/24"
}
variable "private_subnet2_CIDR" {
  type    = string
  default = "10.0.4.0/24"
}
variable "instances_AMI" {
  type    = string
  default = "ami-052efd3df9dad4825"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "RDS_user" {
  type      = string
  sensitive = true
  default = "test"
}
variable "RDS_pass" {
  type      = string
  sensitive = true
  default = "test"
}
