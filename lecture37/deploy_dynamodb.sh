#!/bin/bash

# Регіон
AWS_REGION=us-east-1

# Назва таблиці
TABLE_NAME="Users"

# Створення таблиці
aws dynamodb create-table \
  --region $AWS_REGION \
  --table-name $TABLE_NAME \
  --attribute-definitions AttributeName=userId,AttributeType=S \
  --key-schema AttributeName=userId,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# Очікування створення таблиці (Active)
echo "⏳ Очікуємо, поки таблиця стане ACTIVE..."
aws dynamodb wait table-exists --table-name $TABLE_NAME --region $AWS_REGION

# Включення DynamoDB Stream (зображення New and Old)
aws dynamodb update-table \
  --region $AWS_REGION \
  --table-name $TABLE_NAME \
  --stream-specification StreamEnabled=true,StreamViewType=NEW_AND_OLD_IMAGES

# Коротка пауза, щоб потік точно активувався
sleep 5

# Додавання тестового запису
aws dynamodb put-item \
  --region $AWS_REGION \
  --table-name $TABLE_NAME \
  --item '{
    "userId": {"S": "001"},
    "email": {"S": "target@example.com"},
    "name": {"S": "Test User"}
  }'

echo "✅ Таблиця $TABLE_NAME створена, Stream активовано, запис додано."
