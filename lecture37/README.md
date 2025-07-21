# Проєкт: Автоматична розсилка листів через AWS Lambda та DynamoDB

Цей проєкт демонструє, як реалізувати автоматичне надсилання електронних листів користувачам на основі подій у таблиці DynamoDB за допомогою Lambda-функції та Amazon SES.


### Крок 1: Створення таблиці DynamoDB
Запустіть файл `deploy_dynamodb.sh`, щоб:
- створити таблицю `Users` з первинним ключем `userId`;
- увімкнути потокову трансляцію змін (DynamoDB Streams);
- додати тестовий запис користувача.

### Крок 2: Створення IAM ролей для Lambda
Файл `trust-policy.json` 
```bash

aws iam create-role --role-name lambda-dynamodb-ses-role \
  --assume-role-policy-document file://trust-policy.json
  
```

Після створення ролі прикріпіть політики:
- `AWSLambdaBasicExecutionRole`
- `AmazonDynamoDBReadOnlyAccess`
- `AmazonSESFullAccess`

```bash

aws iam attach-role-policy \
  --role-name lambda-dynamodb-ses-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws iam attach-role-policy \
  --role-name lambda-dynamodb-ses-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonSESFullAccess

aws iam attach-role-policy \
  --role-name lambda-dynamodb-ses-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess


# Перевіряємо

aws iam list-attached-role-policies --role-name lambda-dynamodb-ses-role
{
    "AttachedPolicies": [
        {
            "PolicyName": "AmazonSESFullAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AmazonSESFullAccess"
        },
        {
            "PolicyName": "AWSLambdaBasicExecutionRole",
            "PolicyArn": "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
        },
        {
            "PolicyName": "AmazonDynamoDBReadOnlyAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
        }
    ]
}

```

Файл `stream-permissions.json` 

```bash

aws iam put-role-policy \
  --role-name lambda-dynamodb-ses-role \
  --policy-name LambdaDynamoDBStreamAccess \
  --policy-document file://stream-permissions.json
  
aws lambda create-event-source-mapping \
  --function-name SendEmailOnNewUser \
  --event-source-arn "$STREAM_ARN" \
  --starting-position LATEST \
  --batch-size 1 \
  --enabled
{
    "UUID": "b839c897-83ee-459a-83bc-e5c3af1c32c7",
    "StartingPosition": "LATEST",
    "BatchSize": 1,
    "MaximumBatchingWindowInSeconds": 0,
    "ParallelizationFactor": 1,
    "EventSourceArn": "arn:aws:dynamodb:us-east-1:873868729805:table/Users/stream/2025-07-15T17:48:04.575",
    "FunctionArn": "arn:aws:lambda:us-east-1:873868729805:function:SendEmailOnNewUser",
    "LastModified": "2025-07-15T20:02:42.627000+02:00",
    "LastProcessingResult": "No records processed",
    "State": "Creating",
    "StateTransitionReason": "User action",
    "DestinationConfig": {
        "OnFailure": {}
    },
    "MaximumRecordAgeInSeconds": -1,
    "BisectBatchOnFunctionError": false,
    "MaximumRetryAttempts": -1,
    "TumblingWindowInSeconds": 0,
    "FunctionResponseTypes": [],
    "EventSourceMappingArn": "arn:aws:lambda:us-east-1:873868729805:event-source-mapping:b839c897-83ee-459a-83bc-e5c3af1c32c7"
}  

# Перевіряємо

aws lambda list-event-source-mappings \
  --function-name SendEmailOnNewUser \
  --query "EventSourceMappings[0].State"
  
"Enabled"


```


### Крок 3: Lambda-функція
Файл `lambda_function.py` містить код на Python 3.12. Ця функція:
- зчитує події `INSERT` з DynamoDB Stream;
- надсилає листи на основі email та name з події.

Пакування та створення функції:
```bash

zip function.zip lambda_function.py

adding: lambda_function.py (deflated 49%)


aws lambda create-function \
  --function-name SendEmailOnNewUser \
  --runtime python3.12 \
  --role arn:aws:iam::873868729805:role/lambda-dynamodb-ses-role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip
  
{
    "FunctionName": "SendEmailOnNewUser",
    "FunctionArn": "arn:aws:lambda:us-east-1:873868729805:function:SendEmailOnNewUser",
    "Runtime": "python3.12",
    "Role": "arn:aws:iam::873868729805:role/lambda-dynamodb-ses-role",
    "Handler": "lambda_function.lambda_handler",
    "CodeSize": 553,
    "Description": "",
    "Timeout": 3,
    "MemorySize": 128,
    "LastModified": "2025-07-15T17:55:52.151+0000",
    "CodeSha256": "3J/Ln1IDn/g+n2l9g/f1Xo7oRh/TMmiAfKDtWBRwW+U=",
    "Version": "$LATEST",
    "TracingConfig": {
        "Mode": "PassThrough"
    },
    "RevisionId": "f8552930-619a-4cc6-a5f0-50ec1b968ac3",
    "State": "Pending",
    "StateReason": "The function is being created.",
    "StateReasonCode": "Creating",
    "PackageType": "Zip",
    "Architectures": [
        "x86_64"
    ],
    "EphemeralStorage": {
        "Size": 512
    },
    "SnapStart": {
        "ApplyOn": "None",
        "OptimizationStatus": "Off"
    },
    "RuntimeVersionConfig": {
        "RuntimeVersionArn": "arn:aws:lambda:us-east-1::runtime:aa140c0e9a9c41d993cb36eaf76013968a27ec935d7665a4368d6b0ba10a0f7e"
    },
    "LoggingConfig": {
        "LogFormat": "Text",
        "LogGroup": "/aws/lambda/SendEmailOnNewUser"
    }
}
  
```

### Крок 4: Підключення до DynamoDB Stream

#### a) Отримати ARN потоку:

```bash

STREAM_ARN=$(aws dynamodb describe-table \
  --region us-east-1 \
  --table-name Users \
  --query "Table.LatestStreamArn" --output text)
echo "STREAM ARN: $STREAM_ARN"

STREAM ARN: arn:aws:dynamodb:us-east-1:873868729805:table/Users/stream/2025-07-15T17:48:04.575
  
```

#### b) Створити Event Source Mapping:
```bash

aws dynamodb describe-table --table-name Users \
  --query "Table.LatestStreamArn" --output text
  
```

#### Тестовий запуск тригера

```bash

aws dynamodb put-item \
  --region us-east-1 \
  --table-name Users \
  --item '{
    "userId": {"S": "004"},
    "email": {"S": "andy.fil.devops@outlook.com"},
    "name": {"S": "Test 4"}
  }'

```


### Крок 5: Налаштування Amazon SES
Виконайте в **AWS Console**:
- Перейдіть до Amazon SES;
- Додайте та підтвердьте email (або домен) для надсилання;
- Замініть email у `lambda_function.py` на підтверджену адресу.

---

## Вміст проєкту

| Файл | Опис |
|------|------|
| `deploy_dynamodb.sh`      | Bash-скрипт для створення таблиці та першого запису |
| `lambda_function.py`      | Код Lambda-функції |
| `trust-policy.json`       | Політика IAM |
| `stream-permissions.json` | Політика IAM |
| `README.md`               | Поточна інструкція з реалізації проєкту |

---

**Проєкт реалізовано повністю через WSL та AWS CLI (крім підтвердження email SES, що виконується вручну).**

---

**## Prepared on: 2025-07-15 By: Andrii Fil (IT Administrator, DevOps trainee)**