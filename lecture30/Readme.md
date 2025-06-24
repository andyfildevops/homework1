# Advanced Terraform VPC Project

## Опис

Цей проєкт демонструє використання модулів Terraform для створення базової інфраструктури в AWS:
- VPC
- Публічна та приватна підмережі
- EC2 інстанси в кожній підмережі

## Структура проєкту

```
lecture30/
├── main.tf
├── variables.tf
├── outputs.tf
├── modules/
│   ├── vpc/
│   │   └── main.tf
│   ├── subnet/
│   │   └── main.tf
│   └── ec2/
│       └── main.tf
```

## Кроки запуску

1. Ініціалізуйте Terraform:
```bash

terraform init

Initializing the backend...
Initializing modules...
- ec2 in modules/ec2
- subnet in modules/subnet
- vpc in modules/vpc
Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Installing hashicorp/aws v6.0.0...
- Installed hashicorp/aws v6.0.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

3. Перевірте конфігурацію:
```bash

terraform validate

Success! The configuration is valid.


terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # module.ec2.aws_instance.private_ec2 will be created
  + resource "aws_instance" "private_ec2" {
      + ami                                  = "ami-0c02fb55956c7d316"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
...
...
...

      + tags                                 = {
          + "Name" = "MyVPC"
        }
      + tags_all                             = {
          + "Name" = "MyVPC"
        }
    }

Plan: 5 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + private_ec2_id    = (known after apply)
  + private_subnet_id = (known after apply)
  + public_ec2_id     = (known after apply)
  + public_subnet_id  = (known after apply)
  + vpc_id            = (known after apply)

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if
you run "terraform apply" now.
 
```

4. Застосуйте зміни:
```bash

terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # module.ec2.aws_instance.private_ec2 will be created
  + resource "aws_instance" "private_ec2" {
      + ami                                  = "ami-0c02fb55956c7d316"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
...
...
...
      + tags                                 = {
          + "Name" = "MyVPC"
        }
      + tags_all                             = {
          + "Name" = "MyVPC"
        }
    }

Plan: 5 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + private_ec2_id    = (known after apply)
  + private_subnet_id = (known after apply)
  + public_ec2_id     = (known after apply)
  + public_subnet_id  = (known after apply)
  + vpc_id            = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.vpc.aws_vpc.main: Creating...
module.vpc.aws_vpc.main: Creation complete after 2s [id=vpc-0c0a36224df41d8ac]
module.subnet.aws_subnet.private: Creating...
module.subnet.aws_subnet.public: Creating...
module.subnet.aws_subnet.private: Creation complete after 1s [id=subnet-055fe7d85a5a2e298]
module.ec2.aws_instance.private_ec2: Creating...
module.subnet.aws_subnet.public: Still creating... [00m11s elapsed]
module.ec2.aws_instance.private_ec2: Still creating... [00m11s elapsed]
module.subnet.aws_subnet.public: Creation complete after 13s [id=subnet-0d69b2c7929b9d3da]
module.ec2.aws_instance.public_ec2: Creating...
module.ec2.aws_instance.private_ec2: Still creating... [00m21s elapsed]
module.ec2.aws_instance.public_ec2: Still creating... [00m10s elapsed]
module.ec2.aws_instance.private_ec2: Still creating... [00m31s elapsed]
module.ec2.aws_instance.public_ec2: Still creating... [00m20s elapsed]
module.ec2.aws_instance.private_ec2: Creation complete after 35s [id=i-0c7545a2d963955f8]
module.ec2.aws_instance.public_ec2: Still creating... [00m31s elapsed]
module.ec2.aws_instance.public_ec2: Creation complete after 34s [id=i-043da2fced8a55b07]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

private_ec2_id = "i-0c7545a2d963955f8"
private_subnet_id = "subnet-055fe7d85a5a2e298"
public_ec2_id = "i-043da2fced8a55b07"
public_subnet_id = "subnet-0d69b2c7929b9d3da"
vpc_id = "vpc-0c0a36224df41d8ac"

```

## Очікувані ресурси

- VPC з CIDR `10.0.0.0/16`
- Публічна підмережа `10.0.1.0/24`
- Приватна підмережа `10.0.2.0/24`
- EC2 у публічній підмережі з публічним IP
- EC2 у приватній підмережі без публічного IP


**  01-EC2-us-east-1.png  **
**  02-VPC.png  **
**  03-Subnets.png  **

---

**## Prepared on: 6/24/2025 By: Andrii Fil (IT Administrator, DevOps trainee)**
