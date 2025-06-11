#!/bin/bash

set -e

# --- 1. Змінні ---
REGION="us-east-1"
VPC_NAME="library-vpc"
SG_NAME="library-sg"
SUBNET_GROUP_NAME="library-subnet-group"
RDS_ID="library-db"
PASSWORD="StrongPassword1234!"  # Заміни на свій
MY_IP=$(curl -s ifconfig.me)/32

echo "Регіон: $REGION"
echo "Ваш IP: $MY_IP"

# --- 2. Створити VPC ---
echo "Створення VPC..."
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 \
  --query 'Vpc.VpcId' --output text --region $REGION)

aws ec2 create-tags --resources $VPC_ID \
  --tags Key=Name,Value=$VPC_NAME --region $REGION

# Увімкнути DNS
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support --region $REGION
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames --region $REGION

# --- 3. Internet Gateway + Route Table ---
echo "Створення Internet Gateway і маршрутів..."
IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.InternetGatewayId' --output text --region $REGION)

aws ec2 attach-internet-gateway \
  --vpc-id $VPC_ID --internet-gateway-id $IGW_ID --region $REGION

RT_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID \
  --query 'RouteTable.RouteTableId' --output text --region $REGION)

aws ec2 create-route --route-table-id $RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID --region $REGION

# --- 4. Сабнети у двох AZ ---
echo "Створення сабнетів у двох AZ..."
AZS=($(aws ec2 describe-availability-zones \
  --query "AvailabilityZones[*].ZoneName" \
  --output text --region $REGION))

SUBNET1_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.1.0/24 \
  --availability-zone ${AZS[0]} \
  --query 'Subnet.SubnetId' --output text --region $REGION)

SUBNET2_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.2.0/24 \
  --availability-zone ${AZS[1]} \
  --query 'Subnet.SubnetId' --output text --region $REGION)

aws ec2 associate-route-table --subnet-id $SUBNET1_ID --route-table-id $RT_ID --region $REGION
aws ec2 associate-route-table --subnet-id $SUBNET2_ID --route-table-id $RT_ID --region $REGION

aws ec2 modify-subnet-attribute --subnet-id $SUBNET1_ID --map-public-ip-on-launch --region $REGION
aws ec2 modify-subnet-attribute --subnet-id $SUBNET2_ID --map-public-ip-on-launch --region $REGION

# --- 5. Security Group ---
echo "Створення security group..."
SG_ID=$(aws ec2 create-security-group \
  --group-name $SG_NAME \
  --description "Allow MySQL from my IP" \
  --vpc-id $VPC_ID \
  --query 'GroupId' --output text --region $REGION)

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 3306 \
  --cidr $MY_IP \
  --region $REGION

# --- 6. DB Subnet Group ---
echo "Створення DB Subnet Group..."
aws rds create-db-subnet-group \
  --db-subnet-group-name $SUBNET_GROUP_NAME \
  --db-subnet-group-description "For RDS in 2 AZs" \
  --subnet-ids $SUBNET1_ID $SUBNET2_ID \
  --region $REGION

# --- 7. Створити RDS ---
echo "Створення RDS MySQL інстансу..."
aws rds create-db-instance \
  --db-instance-identifier $RDS_ID \
  --db-instance-class db.t3.micro \
  --engine mysql \
  --master-username admin \
  --master-user-password "$PASSWORD" \
  --allocated-storage 20 \
  --vpc-security-group-ids $SG_ID \
  --db-subnet-group-name $SUBNET_GROUP_NAME \
  --publicly-accessible \
  --no-multi-az \
  --region $REGION

echo "RDS створено. Перевіряй статус у:"
echo "aws rds describe-db-instances --db-instance-identifier $RDS_ID --region $REGION"
