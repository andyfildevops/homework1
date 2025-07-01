resource "aws_subnet" "public" {
  vpc_id     = var.vpc_id
  cidr_block = var.public_subnet_cidr
  availability_zone = var.az
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = var.vpc_id
  cidr_block = var.private_subnet_cidr
  availability_zone = var.az

  tags = {
    Name = "Private Subnet"
  }
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

variable "vpc_id" {}
variable "public_subnet_cidr" {}
variable "private_subnet_cidr" {}
variable "az" {}
