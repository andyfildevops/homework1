output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.subnet.public_subnet_id
}

output "private_subnet_id" {
  value = module.subnet.private_subnet_id
}

output "public_ec2_id" {
  value = module.ec2.public_ec2_id
}

output "private_ec2_id" {
  value = module.ec2.private_ec2_id
}
