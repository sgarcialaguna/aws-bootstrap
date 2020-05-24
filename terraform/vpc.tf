provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "webserver" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    name = "aws-bootstrap"
  }
}

resource "aws_subnet" "subnetAZ1" {
  vpc_id                  = aws_vpc.webserver.id
  availability_zone       = "eu-central-1a"
  cidr_block              = "10.0.0.0/18"
  map_public_ip_on_launch = true
  tags = {
    name = "aws-bootstrap"
    az   = "eu-central-1a"
  }
}

resource "aws_subnet" "subnetAZ2" {
  vpc_id                  = aws_vpc.webserver.id
  availability_zone       = "eu-central-1b"
  cidr_block              = "10.0.64.0/18"
  map_public_ip_on_launch = true
  tags = {
    name = "aws-bootstrap"
    az   = "eu-central-1b"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.webserver.id
  tags = {
    name = "aws-bootstrap"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.webserver.id
  tags = {
    name = "aws-bootstrap"
  }
}

resource "aws_route" "default_public_route" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "route_table_associationAZ1" {
  route_table_id = aws_route_table.route_table.id
  subnet_id      = aws_subnet.subnetAZ1.id
}

resource "aws_route_table_association" "route_table_associationAZ2" {
  route_table_id = aws_route_table.route_table.id
  subnet_id      = aws_subnet.subnetAZ2.id
}
