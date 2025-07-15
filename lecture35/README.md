# Моніторинг з Prometheus, Grafana, Loki через AWS CLI

## КРОК 1. Створення інфраструктури в AWS

### 1. Створіть VPC:
```bash

VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 \
  --query 'Vpc.VpcId' --output text)

aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support "{\"Value\":true}"
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames "{\"Value\":true}"

```

### 2. Створіть Subnet:
```bash

SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.1.0/24 \
  --availability-zone us-east-1a --query 'Subnet.SubnetId' --output text)
  
```

### 3. Створіть Internet Gateway:
```bash

IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.InternetGatewayId' --output text)

aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID

```

### 4. Створіть Route Table і маршрут:
```bash

RT_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID \
  --query 'RouteTable.RouteTableId' --output text)

aws ec2 create-route --route-table-id $RT_ID \
  --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID

aws ec2 associate-route-table --route-table-id $RT_ID --subnet-id $SUBNET_ID

```

### 5. Створіть Key Pair (якщо потрібно):
```bash

aws ec2 create-key-pair --key-name flask-key \
  --query 'KeyMaterial' --output text > flask-key.pem

chmod 400 flask-key.pem

```

---

## КРОК 2. Створення Security Group

```bash
SG_ID=$(aws ec2 create-security-group --group-name monitoring-sg \
  --description "Allow monitoring ports" --vpc-id $VPC_ID \
  --query 'GroupId' --output text)

aws ec2 authorize-security-group-ingress --group-id $SG_ID \
  --protocol tcp --port 22 --cidr YOUR_PUBLIC_IP/32

aws ec2 authorize-security-group-ingress --group-id $SG_ID \
  --protocol tcp --port 80 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress --group-id $SG_ID \
  --protocol tcp --port 3000 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress --group-id $SG_ID \
  --protocol tcp --port 3100 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress --group-id $SG_ID \
  --protocol tcp --port 9090 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress --group-id $SG_ID \
  --protocol tcp --port 9100 --source-group $SG_ID

aws ec2 authorize-security-group-ingress --group-id $SG_ID \
  --protocol tcp --port 9113 --source-group $SG_ID
```

> Замість `YOUR_PUBLIC_IP/32` вставте вашу IP-адресу. 

---

## КРОК 3. Створення EC2 інстансів

### Monitoring-сервер:
```bash

MONITOR_ID=$(aws ec2 run-instances \
  --image-id ami-0fc5d935ebf8bc3bc \
  --instance-type t3.small \
  --key-name flask-key \
  --subnet-id $SUBNET_ID \
  --security-group-ids $SG_ID \
  --associate-public-ip-address \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=monitoring}]' \
  --query 'Instances[0].InstanceId' --output text)
  
```

### Web-сервер:
```bash

WEB_ID=$(aws ec2 run-instances \
  --image-id ami-0fc5d935ebf8bc3bc \
  --instance-type t3.micro \
  --key-name flask-key \
  --subnet-id $SUBNET_ID \
  --security-group-ids $SG_ID \
  --associate-public-ip-address \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=webserver}]' \
  --query 'Instances[0].InstanceId' --output text)
  
```

## КРОК 4. Отримайте публічні IP-адреси

```bash

aws ec2 describe-instances \
  --instance-ids $MONITOR_ID $WEB_ID \
  --query 'Reservations[*].Instances[*].PublicIpAddress' \
  --output text
  
```

## КРОК 6. Підключення до серверів

```bash

ssh -i flask-key.pem ubuntu@<monitoring-ip>

ssh -i flask-key.pem ubuntu@<webserver-ip>

```

> Після входу — запустіть відповідні скрипти `install_monitoring.sh` та `install_web.sh`.


## Наступні кроки перевірки:

### Перевірка Grafana

Перейдіть на http://<monitoring-server-ip>:3000

Зайдіть під admin / admin

Переконайтесь, що:

Prometheus і Loki додані як Data Sources

Імпортовано дашборди:

Node Exporter Full (ID: 1860)

NGINX (наприклад, ID: 12708)

Loki Logs Explorer (можна з шаблону або створити вручну)


### Підтвердження метрик

На Prometheus-дашборді:

nginx_up == 1

nginx_http_requests_total

node_exporter метрики


### Перевірка логів у Grafana через Loki

Dashboard: "Explore"

Data Source: Loki

{job="varlogs"}

Перевірте, чи відображаються логи з /var/log/syslog вебсервера



**## Prepared on: 2025-07-15 By: Andrii Fil (IT Administrator, DevOps trainee)**
