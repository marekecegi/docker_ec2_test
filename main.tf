provider "aws" {
  region = "eu-central-1"
}
resource "aws_vpc" "Demo-VPC" {
  cidr_block = "172.31.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "Demo-VPC"
  }
}
resource "aws_eip" "Demo-EIP"  {
  instance = aws_instance.Demo-EC2.id
  domain = "vpc"
  tags = {
    Name = "Demo-EIP"
  }
}
resource "aws_internet_gateway" "Demo-IGW" {
  vpc_id = aws_vpc.Demo-VPC.id
  tags = {
    Name = "Demo-IGW"
  }
}
resource "aws_subnet" "Demo-SUBNET" {
  cidr_block = "172.31.16.0/20"
  vpc_id = aws_vpc.Demo-VPC.id
  availability_zone = "eu-central-1a"
  tags = {
    Name = "Demo-SUBNET"
  }
}
resource "aws_security_group" "DEMO-SG" {
	name = "DEMO-SG"
  vpc_id = aws_vpc.Demo-VPC.id
	ingress {
		cidr_blocks = [
		  "0.0.0.0/0"
		]
	from_port = 22
		to_port = 22
		protocol = "tcp"
	}
  ingress {
		cidr_blocks = [
		  "0.0.0.0/0"
		]
	from_port = 80
		to_port = 80
		protocol = "tcp"
	}
  ingress {
		cidr_blocks = [
		  "0.0.0.0/0"
		]
	from_port = 3000
		to_port = 3000
		protocol = "tcp"
	}
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
 tags = {
    Name = "DEMO-SG"
  }
}
resource "aws_route_table" "Demo-Routes" {
  vpc_id = aws_vpc.Demo-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Demo-IGW.id
  }
  tags = {
    Name = "Demo-Routes"
  }
}
resource "aws_route_table_association" "Demo-ASS" {
  subnet_id = aws_subnet.Demo-SUBNET.id
  route_table_id = aws_route_table.Demo-Routes.id
}
resource "aws_instance" "Demo-EC2" {
  ami = "ami-0fb820135757d28fd"
  instance_type = "t2.micro"
  key_name = "key-ppk"
  security_groups = [aws_security_group.DEMO-SG.id]
  tags = {
    Name = "Demo-EC2"
  }
  user_data = "${file("cloud-config.yaml")}"
  subnet_id = aws_subnet.Demo-SUBNET.id
}
