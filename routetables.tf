
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "my-public-route-table"
  }
}
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "my-private-route-table"
  }
}
resource "aws_route_table_association" "public1-link" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public-route-table.id
}
resource "aws_route_table_association" "public2-link" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public-route-table.id
}
resource "aws_route_table_association" "private1-link" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.public-route-table.id
}
resource "aws_route_table_association" "private2-link" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.public-route-table.id
}
