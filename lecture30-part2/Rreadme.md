# Terraform Import – Lecture30 Part 2

## Опис

Цей проєкт демонструє, як імпортувати наявні ресурси AWS (EC2 інстанси), створені вручну, у нову Terraform конфігурацію.

## Структура

```
Lecture30-part2/
├── ec2.tf           # опис імпортованих EC2 інстансів
```

## Ресурси для імпорту

- EC2: Public EC2 (i-043da2fced8a55b07)
- EC2: Private EC2 (i-0c7545a2d963955f8)

## Кроки

1. Ініціалізуйте Terraform:
```bash

terraform init

Initializing the backend...
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

2. Імпортуйте EC2 інстанси:
```bash

terraform import aws_instance.imported_public i-043da2fced8a55b07

aws_instance.imported_public: Importing from ID "i-043da2fced8a55b07"...
aws_instance.imported_public: Import prepared!
  Prepared aws_instance for import
aws_instance.imported_public: Refreshing state... [id=i-043da2fced8a55b07]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.


terraform import aws_instance.imported_private i-0c7545a2d963955f8

aws_instance.imported_private: Importing from ID "i-0c7545a2d963955f8"...
aws_instance.imported_private: Import prepared!
  Prepared aws_instance for import
aws_instance.imported_private: Refreshing state... [id=i-0c7545a2d963955f8]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

```

3. Перевірте стан:
```bash

terraform state show aws_instance.imported_public

subnet_id = "subnet-0d69b2c7929b9d3da"
ami = "ami-0c02fb55956c7d316"


terraform state show aws_instance.imported_private

subnet_id = "subnet-055fe7d85a5a2e298"
ami = "ami-0c02fb55956c7d316"

```

4. На основі `state show`:
   - Виправте `subnet_id` та `ami` у `ec2.tf`

5. Перевірте:
```bash

terraform plan

aws_instance.imported_private: Refreshing state... [id=i-0c7545a2d963955f8]
aws_instance.imported_public: Refreshing state... [id=i-043da2fced8a55b07]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

```

## Очікуваний результат

Terraform покаже:
```
No changes. Your infrastructure matches the configuration.
```

Це означає, що імпорт успішний, і стан відповідає конфігурації.

---

**## Prepared on: 6/24/2025 By: Andrii Fil (IT Administrator, DevOps trainee)**
