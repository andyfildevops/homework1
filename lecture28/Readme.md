# CloudFormation Stack: VPC + EC2 + IAM Role + S3 Bucket

Шаблон cf-vpc-ec2-s3.yaml створює інфраструктуру AWS, яка включає:
- VPC із публічною підмережею
- EC2 інстанс з IAM роллю
- IAM роль з доступом до S3
- Приватний S3 Bucket із політикою та версіонуванням

## Параметри
- `BucketName` — унікальне для всього AWS ім’я бакету

## Кроки запуску через CLI

1. Встановіть змінну з унікальним ім’ям бакету:
```bash

export BUCKET_NAME=andrii-fil-bucket-20250613

```

2. Створіть стек:
```bash

aws cloudformation create-stack \
  --stack-name vpc-ec2-s3-stack \
  --template-body file://cf-vpc-ec2-s3.yaml \
  --parameters ParameterKey=BucketName,ParameterValue=$BUCKET_NAME \
  --capabilities CAPABILITY_NAMED_IAM
  
  {
    "StackId": "arn:aws:cloudformation:us-east-1:873868729805:stack/vpc-ec2-s3-stack/dc9094a0-487d-11f0-ac24-0affd196613d"
}

```

3. Дочекайтеся створення:
```bash

aws cloudformation wait stack-create-complete --stack-name vpc-ec2-s3-stack

```

4. Перегляньте публічну IP-адресу EC2 та ім’я бакету:
```bash

aws cloudformation describe-stacks \
  --stack-name vpc-ec2-s3-stack \
  --query "Stacks[0].Outputs"
  
  [
    {
        "OutputKey": "InstancePublicIP",
        "OutputValue": "44.213.102.134",
        "Description": "Public IP of the EC2 instance"
    },
    {
        "OutputKey": "CreatedBucketName",
        "OutputValue": "andrii-fil-bucket-20250613",
        "Description": "Name of created S3 bucket"
    }
]

```

## Перевірка змін (Drift Detection)

```bash

aws cloudformation detect-stack-drift --stack-name vpc-ec2-s3-stack
{
    "StackDriftDetectionId": "60b6b070-487e-11f0-b303-0affd2c73157"
}


aws cloudformation describe-stack-drift-detection-status \
  --stack-drift-detection-id 60b6b070-487e-11f0-b303-0affd2c73157
{
    "StackId": "arn:aws:cloudformation:us-east-1:873868729805:stack/vpc-ec2-s3-stack/dc9094a0-487d-11f0-ac24-0affd196613d",
    "StackDriftDetectionId": "60b6b070-487e-11f0-b303-0affd2c73157",
    "StackDriftStatus": "IN_SYNC",
    "DetectionStatus": "DETECTION_COMPLETE",
    "DriftedStackResourceCount": 0,   ##############   <- 0   ##############
    "Timestamp": "2025-06-13T17:46:47.415000+00:00"
}

```

Внесіть зміни. Наприклад додайте новий тег до EC2 інстансу.
** 01-Drift.png **

```bash

aws cloudformation detect-stack-drift --stack-name vpc-ec2-s3-stack
{
    "StackDriftDetectionId": "c3c33790-4880-11f0-aaba-0ef5edef2bf9" ##############   <- Новий ID   ##############
}


aws cloudformation describe-stack-drift-detection-status   --stack-drift-detection-id c3c33790-4880-11f0-aaba-0ef5edef2bf9
{
    "StackId": "arn:aws:cloudformation:us-east-1:873868729805:stack/vpc-ec2-s3-stack/dc9094a0-487d-11f0-ac24-0affd196613d",
    "StackDriftDetectionId": "c3c33790-4880-11f0-aaba-0ef5edef2bf9",
    "StackDriftStatus": "DRIFTED",
    "DetectionStatus": "DETECTION_COMPLETE",
    "DriftedStackResourceCount": 1,  ##############   <- 1   ##############
    "Timestamp": "2025-06-13T18:03:52.585000+00:00"

```

** 02-Drift.png **


## Видалення стека

```bash

aws cloudformation delete-stack --stack-name vpc-ec2-s3-stack

aws cloudformation wait stack-delete-complete --stack-name vpc-ec2-s3-stack

```

---


## Prepared on: 6/13/2025 By: Andrii Fil (IT Administrator, DevOps trainee)
