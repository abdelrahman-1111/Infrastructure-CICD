output vpc_id {
  value       = aws_vpc.my-vpc.id
#   sensitive   = true
}
output public1_subnet_id {
  value       = aws_subnet.public1_subnet_id.id
#   sensitive   = true
}
output public2_subnet_id {
  value       = aws_subnet.public2_subnet_id.id
#   sensitive   = true
}
output private1_subnet_id {
  value       = aws_subnet.private1_subnet_id.id
#   sensitive   = true
}
output private2_subnet_id {
  value       = aws_subnet.private2_subnet_id.id
#   sensitive   = true
}

