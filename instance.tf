provider "aws"{
region = "ap-southeast-1"
}
resource "aws_vpc" "tfvpc"{
tags = {
Name = "hjn-vpc"
}
cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "tfprivate"{
tags = {
Name = "private_subnet"
}
vpc_id = aws_vpc.tfvpc.id
cidr_block = "10.0.1.0/24"
}
resource "aws_subnet" "tfpublic"{
tags = {
Name = "public_subnet"
}
vpc_id = aws_vpc.tfvpc.id
cidr_block = "10.0.2.0/24"
}
resource "aws_route_table" "tftable_private"{
tags = {
Name = "private-RT-table"
}
vpc_id = aws_vpc.tfvpc.id
}
resource "aws_route_table" "tftable_public"{
tags = {
Name = "public-RT-table"
}
vpc_id = aws_vpc.tfvpc.id
}
resource "aws_eip" "tfeip"{
domain = "vpc"
tags = {
Name = "myip"
}
}
resource "aws_internet_gateway" "tfigw"{
tags ={
Name = "hjnigw"
}
vpc_id = aws_vpc.tfvpc.id
}
resource "aws_nat_gateway" "tfnat"{
tags = {
Name = "hjnNat"
}
allocation_id = aws_eip.tfeip.id
subnet_id = aws_subnet.tfpublic.id
}
resource "aws_route_table_association" "tfassociation_private"{
route_table_id = aws_route_table.tftable_private.id
subnet_id = aws_subnet.tfprivate.id
}
resource "aws_route_table_association" "tfassociation_public"{
route_table_id = aws_route_table.tftable_public.id
subnet_id = aws_subnet.tfpublic.id
}
resource "aws_route" "tfroute_private"{
route_table_id = aws_route_table.tftable_private.id
nat_gateway_id = aws_nat_gateway.tfnat.id
destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route" "tfroute_public"{
route_table_id = aws_route_table.tftable_public.id
gateway_id = aws_internet_gateway.tfigw.id
destination_cidr_block = "0.0.0.0/0"
}
resource "aws_security_group" "tfsg"{
vpc_id = aws_vpc.tfvpc.id
tags = {
Name = "hjnsg"
}
ingress {
description = "This is for the SSh"
from_port = "22"
to_port = "22"
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
description = "This is for the Http"
from_port = "80"
to_port = "80"
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
}
resource "aws_instance" "tfec2"{
tags = {
Name = "ansible_master"
}
ami = "ami-0c76ffacce8b1be85"
instance_type = "t2.medium"
key_name = "SING"
vpc_security_group_ids = [aws_security_group.tfsg.id]
subnet_id = aws_subnet.tfpublic.id
associate_public_ip_address = true
user_data = <<-EOF
#!/bin/bash
dnf install docker -y
systemctl enable docker
systemctl start docker
EOF
}

