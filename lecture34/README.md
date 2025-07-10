## Етап 0: Форк проєкту на GitHub

Ми будемо працювати з типовим Spring Boot Java-проєктом, зібраним через Maven.

1. Перейдіть до офіційного репозиторію Spring Boot Example:
https://github.com/spring-guides/gs-spring-boot

2. Натисніть кнопку `Fork` (вгорі праворуч) і форкніть репозиторій у свій GitHub-акаунт.

3. Отримаєте URL до вашого форку, наприклад:
https://github.com/andyfildevops/gs-spring-boot

4. Цей URL використаємо далі у Jenkins (при створенні Freestyle Job або Jenkinsfile).

Тепер проєкт готовий до CI/CD.


## Етап 1: Деплой Jenkins

### Установка Jenkins на локальний сервер (Ubuntu)

```bash

# Додати репозиторій Jenkins
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Встановити Java та Jenkins
sudo apt update
sudo apt install -y openjdk-17-jdk jenkins

# Запустити Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins


# Перевірити статус Jenkins:
sudo systemctl status jenkins
● jenkins.service - Jenkins Continuous Integration Server
     Loaded: loaded (/usr/lib/systemd/system/jenkins.service; enabled; preset: enabled)
     Active: active (running) since Tue 2025-07-08 07:00:52 CEST; 29s ago
   Main PID: 1399 (java)
      Tasks: 69 (limit: 9309)
     Memory: 1.2G ()
     CGroup: /system.slice/jenkins.service
             └─1399 /usr/bin/java -Djava.awt.headless=true -jar /usr/share/java/jenkins.war --webroot>

```

### Початкова конфігурація Jenkins. Вхід.

1. Відкрийте браузер і перейдіть за адресою:
http://localhost:8080

2. В консолі виконайте:
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

Зкопіюйте пароль і вставле його у віддповідне поле в браузері.

3. Встановіть плагіни:
* Git Plugin
* Pipeline Plugin

4. Закінчіть Installation wizard

5. Встановіть плагін:
* Telegram Bot Plugin
* Send build artifacts over SSH


## Етап 2: Автоматичне створення інфраструктури AWS для Jenkins-деплою (через AWS CLI)

> Цей скрипт створює повну інфраструктуру для CI/CD-проєкту: VPC, публічну підмережу, Internet Gateway, маршрутну таблицю, Security Group, EC2-інстанс з Java і виводить публічну IP-адресу для доступу.

---

### Скрипт створення EC2 з повною інфраструктурою:

```bash

#!/bin/bash

# Назви змінних
VPC_NAME="jenkins-vpc"
SUBNET_NAME="jenkins-subnet"
IGW_NAME="jenkins-igw"
ROUTE_TABLE_NAME="jenkins-rt"
SEC_GROUP_NAME="jenkins-sg"
KEY_NAME="jenkins-key"
INSTANCE_NAME="jenkins-ec2"

# 1. Створіть ключову пару
aws ec2 create-key-pair \
  --key-name $KEY_NAME \
  --query 'KeyMaterial' \
  --output text > ${KEY_NAME}.pem
chmod 400 ${KEY_NAME}.pem

# 2. Створіть VPC
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --query 'Vpc.VpcId' --output text)
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=$VPC_NAME

# 3. Увімкніть DNS
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support '{"Value":true}'
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames '{"Value":true}'

# 4. Створіть публічну підмережу
SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.1.0/24 \
  --query 'Subnet.SubnetId' --output text)
aws ec2 create-tags --resources $SUBNET_ID --tags Key=Name,Value=$SUBNET_NAME

# 5. Створіть Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID
aws ec2 create-tags --resources $IGW_ID --tags Key=Name,Value=$IGW_NAME

# 6. Створіть маршрутну таблицю
RT_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-tags --resources $RT_ID --tags Key=Name,Value=$ROUTE_TABLE_NAME

# 7. Створіть маршрут до інтернету
aws ec2 create-route \
  --route-table-id $RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID

# 8. Прив’яжіть підмережу до маршрутної таблиці
aws ec2 associate-route-table \
  --subnet-id $SUBNET_ID \
  --route-table-id $RT_ID

# 9. Зробіть підмережу публічною
aws ec2 modify-subnet-attribute \
  --subnet-id $SUBNET_ID \
  --map-public-ip-on-launch

# 10. Створіть Security Group
SG_ID=$(aws ec2 create-security-group \
  --group-name $SEC_GROUP_NAME \
  --description "Allow SSH and HTTP for Jenkins deploy" \
  --vpc-id $VPC_ID \
  --query 'GroupId' --output text)

# Відкрийте доступ по SSH лише з вашого IP
MY_IP=$(curl -s ifconfig.me)
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID --protocol tcp --port 22 --cidr ${MY_IP}/32

# Відкрийте порт 8080 для доступу до застосунку
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID --protocol tcp --port 8080 --cidr 0.0.0.0/0

# 11. Отримайте останній AMI Ubuntu 22.04
UBUNTU_AMI=$(aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
            "Name=state,Values=available" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
  --output text)

# 12. Запустіть EC2 з Java
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $UBUNTU_AMI \
  --count 1 \
  --instance-type t2.micro \
  --key-name $KEY_NAME \
  --security-group-ids $SG_ID \
  --subnet-id $SUBNET_ID \
  --associate-public-ip-address \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
  --user-data '#!/bin/bash
apt update -y
apt install -y openjdk-17-jdk' \
  --query 'Instances[0].InstanceId' --output text)

# 13. Отримайте публічну IP-адресу
sleep 10
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "EC2 створено. IP-адреса: $PUBLIC_IP"
echo "SSH: ssh -i ${KEY_NAME}.pem ubuntu@$PUBLIC_IP"

EC2 створено. IP-адреса: 3.90.0.130
SSH: ssh -i jenkins-key.pem ubuntu@3.90.0.130

```

## Що буде створено:

- VPC + підмережа + Internet Gateway
- Маршрутизація до Інтернету
- Security Group з доступом по SSH і 8080
- EC2 інстанс із встановленою Java 17
- Ключова пара для підключення
- Готовність до деплою з Jenkins


## Етап 3: Конфігурація Jenkins для CI/CD Java-проєкту (Freestyle Job + Send build artifacts over SSH)

### Частина 1: Глобальні налаштування Jenkins

#### 1. Установка Maven:
- Перейдіть у **Manage Jenkins → System Configuration → Tools**
- У секції **Maven** натисніть `Add Maven`:
  - Name: `Maven 3`
  - Install automatically
  - Version: оберіть останню (наприклад, `3.9.10`)
- Натисніть `Save`

#### 2. Налаштування SSH доступу до EC2:
- Перейдіть у **Manage Jenkins → System Configuration → System**
- Прокрутіть до секції **Publish over SSH**
- Натисніть `Add`:
  - **Key**: вставте вміст `jenkins-key.pem` (приватний ключ)
  - **Name**: `deploy-ec2`
  - **Hostname**: `<EC2_PUBLIC_IP>`
  - **Username**: `ubuntu`
  - **Remote Directory**: `/home/ubuntu/app`
  
- Збережіть конфігурацію

---

### Частина 2: Створення Jenkins Freestyle Job

#### 1. Створіть задачу:
- Перейдіть у головне меню Jenkins → `New Item`
- Назва: `Simple Freestyle Job`
- Тип: `Freestyle project` → натисніть `OK`

#### 2. Налаштування Source Code Management:
- Source Code Management: `Git`
- Repository URL:
  ```
  https://github.com/<your-username>/gs-spring-boot.git
  
  ```
- Branch: `*/main`
- Додайте поведінку: `Check out to a sub-directory`
  - Subdirectory: `gs-spring-boot`

#### 3. Build:
- Add build step → `Invoke top-level Maven targets`
  - Maven Version: `Maven 3`
  - Goals:
    ```
    -f gs-spring-boot/complete/pom.xml clean install
	
    ```

#### 4. Post-build Actions:
- Add post-build action → `Send build artifacts over SSH`
- Оберіть конфігурацію: `deploy-ec2`

##### У полі Transfer:
- **Source files**:
  ```
  gs-spring-boot/complete/target/*.jar
  
  ```
- **Remove prefix**:
  ```
  gs-spring-boot/complete/target
  
  ```

##### У полі Exec command:
```bash
nohup java -jar /home/ubuntu/app/spring-boot-complete-0.0.1-SNAPSHOT.jar --server.port=8080 > /home/ubuntu/app/app.log 2>&1 &

```

Результат:
- Jenkins клонуватиме Spring Boot-проєкт
- збере `.jar` через Maven
- передасть файл на EC2 через SCP
- запустить застосунок на порту 8080


## Етап 4: Jenkins Declarative Pipeline для CI/CD Java-проєкту

---

### Jenkinsfile (у репозиторії `gs-spring-boot` → `main → Jenkinsfile`)

```groovy

pipeline {
    agent any

    tools {
        maven 'Maven 3'
    }

    environment {
        DEPLOY_HOST = 'ubuntu@<EC2_PUBLIC_IP>'
        DEPLOY_DIR = '/home/ubuntu/app'
        JAR_NAME = 'spring-boot-complete-0.0.1-SNAPSHOT.jar'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/<your-username>/gs-spring-boot.git', branch: 'main'
            }
        }

        stage('Build with Maven') {
            steps {
                dir('complete') {
                    sh 'mvn clean install'
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sh '''
                scp -i ~/.ssh/id_rsa complete/target/${JAR_NAME} $DEPLOY_HOST:$DEPLOY_DIR/$JAR_NAME
                ssh -i ~/.ssh/id_rsa $DEPLOY_HOST "nohup java -jar /home/ubuntu/app/spring-boot-complete-0.0.1-SNAPSHOT.jar \
				--server.address=0.0.0.0 --server.port=8080 > /home/ubuntu/app/app.log 2>&1 &"
                '''
            }
		}
    }
}

```

Не забудьте:
- Замінити `<EC2_PUBLIC_IP>` і `<your-username>` на фактичні

---

### Підготовка Jenkins перед запуском пайплайну

#### 1. Підготуйте SSH ключ:
- Файл `id_rsa` має бути доступний у Jenkins: `/var/lib/jenkins/.ssh/id_rsa`
- Права доступу:
  ```bash
  
  sudo chmod 600 /var/lib/jenkins/.ssh/id_rsa
  sudo chown jenkins:jenkins /var/lib/jenkins/.ssh/id_rsa
  
  ```

#### 2. Додайте EC2 хост до known_hosts Jenkins:

```bash

sudo bash -c "ssh-keyscan <EC2_PUBLIC_IP> >> /var/lib/jenkins/.ssh/known_hosts"

```

---

### Як запустити Declarative Pipeline:

1. Створіть нову Jenkins задачу:
   - New Item → Declarative Pipeline
2. Вкажіть:
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL:
     ```
     https://github.com/andyfildevops/gs-spring-boot.git
	 
     ```
   - Script Path: `Jenkinsfile`
3. Натисніть `Build Now`

---

### Результат:

- Jenkins зібрав Spring Boot застосунок через Maven
- Передав `.jar` на EC2 по SSH
- Автоматично перезапустив його у фоновому режимі
- Застосунок доступний на:

```

http://<EC2_PUBLIC_IP>:8080/

```

## Prepared on: 2025-07-08 By: Andrii Fil (IT Administrator, DevOps trainee)
