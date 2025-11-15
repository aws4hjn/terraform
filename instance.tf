resource "aws_vpc" "tfvpc"{
cidr_block = "10.0.0.0/16"
tags = {
Name = "VPCA"
}
}
resource "aws_subnet" "tfsubnet"{
vpc_id = aws_vpc.tfvpc.id
availability_zone = "ap-southeast-1a" 
cidr_block = "10.0.1.0/24"
tags = {
Name = "Private_subnet"
}
}
resource "aws_internet_gateway" "tfigw"{
vpc_id = aws_vpc.tfvpc.id
tags = {
Name = "myigw"
}
}
resource "aws_route_table" "tfrt"{
vpc_id = aws_vpc.tfvpc.id
tags = {
Name = "privateRT"
}
}
resource "aws_route_table_association" "tfassociation"{
subnet_id = aws_subnet.tfsubnet.id
route_table_id = aws_route_table.tfrt.id
}
resource "aws_route" "tfroute"{
route_table_id = aws_route_table.tfrt.id
gateway_id = aws_internet_gateway.tfigw.id
destination_cidr_block = "0.0.0.0/0"
}
resource "aws_security_group" "tfsg"{
tags = {
Name = "my-sg"
}
vpc_id = aws_vpc.tfvpc.id
description = "This is my security group"
ingress {
description = "This is for the ssh"
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["10.0.0.0/16"]
}
}
resource "aws_instance" "tfec2"{
tags = {
Name = "ec2-hjn"
}
ami = "ami-0c56f26c1d3277bcb"
instance_type = "t2.micro"
vpc_security_group_ids = [aws_security_group.tfsg.id]
key_name = "SING"
subnet_id = aws_subnet.tfsubnet.id
associate_public_ip_address = true

}












