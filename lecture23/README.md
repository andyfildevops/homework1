# Завдання 23 — Робота з Amazon S3, IAM та EC2

## Крок 1: Створення S3 бакета

1. Увійти в [AWS S3 Console](https://s3.console.aws.amazon.com/s3/)
2. Натиснути **Create bucket**
3. Ввести унікальне ім’я: `andyfildevops`
4. Вибрати регіон `us-east-1`
5. Натиснути **Create bucket**

---

## Крок 2: Налаштування IAM-ролі для EC2

1. Увійти в [IAM Console](https://console.aws.amazon.com/iam/)
2. **Create Role** → обрати **EC2**
3. Знайти і додати політику: `AmazonS3FullAccess`
4. Назвати роль: `EC2_S3_Access_Role`
5. Створити роль

---

## Крок 3: Додати політику до бакета S3

### Додати Bucket Policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowEC2RoleAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::873868729805:role/EC2_S3_Access_Role"
      },
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::andyfildevops",
        "arn:aws:s3:::andyfildevops/*"
      ]
    }
  ]
}
```

---

## Крок 4: Створення EC2 інстансу

1. Увійти в [EC2 Console](https://console.aws.amazon.com/ec2/)
2. **Launch Instance**
3. Вибрати AMI 
4. Вказати:
   - SSH-ключ: `lecture23.pem`
   - IAM Role: `EC2_S3_Access_Role`
5. Запустити інстанс

---

## Крок 5: Підключення до EC2

```bash
ssh -i ~/keys/lecture23.pem ubuntu@<EC2-PUBLIC-IP>
```

---

## Крок 6: Встановлення та налаштування AWS CLI

```bash
sudo apt update && sudo apt install -y awscli
```

```bash
aws sts get-caller-identity
```

```bash
aws configure
```

Всі поля залишити порожніми та натиснути `Enter`, якщо EC2 має IAM-роль.

---

## Крок 7: Завантаження файлу до S3

```bash
echo "Test file from EC2" > test.txt
aws s3 cp test.txt s3://andyfildevops/

echo "Hello from EC2!" > hello.txt
aws s3 cp hello.txt s3://andyfildevops/
```

---

## Крок 8: Перевірка файлів у S3

```bash
aws s3 ls s3://andyfildevops/
```

## Prepared on: 5/28/2025 By: Andrii Fil (IT Administrator, DevOps trainee)