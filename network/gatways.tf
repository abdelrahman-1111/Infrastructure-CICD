# creating the internet gatway for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "igw"
  }
}
# creating the NAT gatway for private subnets with elastic ip id attached to it and the public subnet where it can get a public route
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "nat"
  }
  depends_on = [aws_internet_gateway.igw]
}
#the created elastic ip for the NAT gatway
resource "aws_eip" "eip" {
  depends_on = [aws_internet_gateway.igw]
}