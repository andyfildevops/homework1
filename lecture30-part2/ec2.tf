resource "aws_instance" "imported_public" {
  ami           = "ami-0c02fb55956c7d316"  
  instance_type = "t2.micro"
  subnet_id     = "subnet-0d69b2c7929b9d3da"  

  tags = {
    Name = "Public EC2"
  }
}

resource "aws_instance" "imported_private" {
  ami           = "ami-0c02fb55956c7d316"  
  instance_type = "t2.micro"
  subnet_id     = "subnet-055fe7d85a5a2e298"     

  tags = {
    Name = "Private EC2"
  }
}
