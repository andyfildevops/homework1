resource "aws_instance" "public_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  associate_public_ip_address = true

  tags = {
    Name = "Public EC2"
  }
}

resource "aws_instance" "private_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_id

  tags = {
    Name = "Private EC2"
  }
}

output "public_ec2_id" {
  value = aws_instance.public_ec2.id
}

output "private_ec2_id" {
  value = aws_instance.private_ec2.id
}

variable "ami_id" {}
variable "instance_type" {}
variable "public_subnet_id" {}
variable "private_subnet_id" {}
