resource "aws_vpc" "mypro-vpc" {
cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "terraform-vpc"
  }
}

resource "aws_internet_gateway" "mypro-ig" {
  vpc_id = aws_vpc.mypro-vpc.id
  tags = {
    Name = "terraform-ig"
  }
}

resource "aws_subnet" "my-public-subnet" {
  vpc_id     = aws_vpc.mypro-vpc.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "terraform-public-subnet"
  }
}

resource "aws_subnet" "my-private-subnet" {
  vpc_id     = aws_vpc.mypro-vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "terraform-private-subnet"
  }
}

resource "aws_route_table" "mypro-rt" {
  vpc_id = aws_vpc.mypro-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mypro-ig.id
  }

  tags = {
    Name = "terraform-public-rt"
  }
}

resource "aws_route_table" "my-private-rt" {
  vpc_id = aws_vpc.mypro-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my-nat-gw.id
  }

  tags = {
    Name = "terraform-private-rt"
  }
}

resource "aws_route_table_association" "public-association" {
  subnet_id      = aws_subnet.my-public-subnet.id
  route_table_id = aws_route_table.mypro-rt.id
}

resource "aws_route_table_association" "private-association" {
  subnet_id      = aws_subnet.my-private-subnet.id
  route_table_id = aws_route_table.my-private-rt.id
}

resource "aws_eip" "terraform-eip" {
  vpc = true
  tags = {
    Name = "terraform-eip"
  }
}

resource "aws_nat_gateway" "my-nat-gw" {
  allocation_id = aws_eip.terraform-eip.id
  subnet_id     = aws_subnet.my-private-subnet.id
  tags = {
    Name = "terraform-nat-gw"
  }
}
