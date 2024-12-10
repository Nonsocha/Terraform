resource "aws_vpc" "custom" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "CustomVPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom.id

  tags = {
    Name = "CustomVPC-IGW"
  }
}

resource "aws_subnet" "public_subnets" {
  count             = 2
  vpc_id            = aws_vpc.custom.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet-${count.index}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom.id

  tags = {
    Name = "CustomVPC-Public-RouteTable"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_rt_assoc" {
  count          = 2
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}
