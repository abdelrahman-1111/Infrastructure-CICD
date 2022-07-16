output vpc_id {
  value       = aws_vpc.my-vpc.id
#   sensitive   = true
}
output public1_subnet_id {
  value       = aws_subnet.public1.id
#   sensitive   = true
}
output public2_subnet_id {
  value       = aws_subnet.public2.id
#   sensitive   = true
}
output private1_subnet_id {
  value       = aws_subnet.private1.id
#   sensitive   = true
}
output private2_subnet_id {
  value       = aws_subnet.private2.id
#   sensitive   = true
}
output vpc_CIDR {
  value     = var.vpc_CIDR
}
