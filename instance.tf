provider "aws"{
region = "ap-southeast-1"
}
resource "aws_vpc" "tfvpc"{
tags = {
Name = "VPCA"
}
cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "tfsubnet_private"{
tags = {
Name = "Private"
}
vpc_id = aws_vpc.tfvpc.id
cidr_block = "10.0.1.0/24"
}
resource "aws_subnet" "tfsubnet_public"{
tags = {
Name = "Public"
}
vpc_id = aws_vpc.tfvpc.id
cidr_block = "10.0.2.0/24"
map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "tfgateway"{
tags = {
Name = "myigw"
}
vpc_id = aws_vpc.tfvpc.id
}
resource "aws_eip" "tfeip"{
tags = {
Name = "Elastic_ip"
}
}
resource "aws_nat_gateway" "tfnat"{
tags = {
Name = "myNAT"
}
allocation_id = aws_eip.tfeip.id
subnet_id = aws_subnet.tfsubnet_public.id
}
resource "aws_route_table" "tftable_private"{
tags = {
Name = "Private"
}
vpc_id = aws_vpc.tfvpc.id
}
resource "aws_route_table" "tftable_public"{
tags = {
Name = "Public"
}
vpc_id = aws_vpc.tfvpc.id
}
resource "aws_route_table_association" "private_associate"{
route_table_id = aws_route_table.tftable_private.id
subnet_id = aws_subnet.tfsubnet_private.id
}
resource "aws_route_table_association" "public_associate"{
route_table_id = aws_route_table.tftable_public.id
subnet_id = aws_subnet.tfsubnet_public.id
}
resource "aws_route" "tfroute1"{
route_table_id = aws_route_table.tftable_private.id
destination_cidr_block = "0.0.0.0/0"
nat_gateway_id = aws_nat_gateway.tfnat.id
}
resource "aws_route" "tfroute2"{
route_table_id = aws_route_table.tftable_public.id
destination_cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.tfgateway.id
}
resource "aws_security_group" "tfsg"{
vpc_id = aws_vpc.tfvpc.id
tags = {
Name = "mysecuritygroup"
}
ingress{
description = "This is for the remote access of instance"
from_port = "22"
to_port = "22"
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
}
resource "aws_instance" "tfec2-1"{
tags = {
Name = "ansible-master"
}
ami = "ami-0c76ffacce8b1be85"
count = 2
instance_type = "t2.micro"
key_name = "SING"
vpc_security_group_ids = [aws_security_group.tfsg.id]
subnet_id = aws_subnet.tfsubnet_public.id
associate_public_ip_address = true
}




