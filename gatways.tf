resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "igw"
  }
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "nat"
  }
  depends_on = [aws_internet_gateway.igw]
}
resource "aws_eip" "eip" {
  depends_on = [aws_internet_gateway.igw]
}