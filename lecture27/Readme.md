# RDS: База Даних для Трекінгу Книг (MySQL на AWS)

## Створення інфраструктури з терміналу

1. Ініціалізація змінних у скрипті:
   - Регіон: us-east-1
   - VPC, 2 сабнети в різних AZ (us-east-1a, us-east-1b)
   - Internet Gateway + Route Table
   - Security Group із доступом по порту 3306 з мого IP
   - DB Subnet Group
   - MySQL RDS інстанс з назвою library-db

2. Запуск скрипта:

```bash
chmod +x create_rds_library.sh
./create_rds_library.sh
```

## Ініціалізація бази даних

1. Після створення інстансу:
   - Отримано endpoint через AWS CLI
   - Підключення до бази:
```bash
mysql -h <endpoint> -u admin -p
```

2. Створення структури:
   - Базу library та таблиці:
     - authors
     - books
     - reading_status
   - Збереження init_library.sql

3. Вставка даних: 
```bash
mysql -h <endpoint> -u admin -p < init_library.sql
```

## SQL-запити

1. Книги, які ще не прочитані:
```sql
   SELECT books.title, authors.name
   FROM books
   JOIN authors ON books.author_id = authors.id
   LEFT JOIN reading_status ON books.id = reading_status.book_id
   WHERE reading_status.status IS NULL OR reading_status.status != 'completed';
   
+------------------------------------------+-----------------+
| title                                    | name            |
+------------------------------------------+-----------------+
| 1984                                     | George Orwell   |
| Harry Potter and the Philosopher's Stone | J.K. Rowling    |
| Kafka on the Shore                       | Haruki Murakami |
+------------------------------------------+-----------------+
3 rows in set (0.13 sec)
```

2. Кількість книг у процесі читання:
```sql
   SELECT COUNT(*) AS reading_books
   FROM reading_status
   WHERE status = 'reading';
   
+---------------+
| reading_books |
+---------------+
|             1 |
+---------------+
1 row in set (0.15 sec)
```

## Обмеження прав доступу

1. Створено користувача:
```sql
mysql> CREATE USER 'library_user'@'%' IDENTIFIED BY 'StrongUserPass123!';
```

2. Надано лише потрібні привілеї:
```sql
mysql> GRANT SELECT, INSERT, UPDATE ON library.* TO 'library_user'@'%';
mysql> FLUSH PRIVILEGES;
```

3. Підтверджено, що library_user:
   - може виконувати SELECT, INSERT, UPDATE
   - не може CREATE, DROP, ALTER
```bash
mysql -h <endpoint> -u library_user -p
``` 

```sql
mysql> SHOW GRANTS FOR 'library_user'@'%';
+-------------------------------------------------------------------+
| Grants for library_user@%                                         |
+-------------------------------------------------------------------+
| GRANT USAGE ON *.* TO `library_user`@`%`                          |
| GRANT SELECT, INSERT, UPDATE ON `library`.* TO `library_user`@`%` |
+-------------------------------------------------------------------+
2 rows in set (0.12 sec)

mysql> CREATE TABLE test_table (id INT);
ERROR 1142 (42000): CREATE command denied to user 'library_user'@'212.180.248.33' for table 'test_table'

mysql> DROP TABLE authors;
ERROR 1142 (42000): DROP command denied to user 'library_user'@'212.180.248.33' for table 'authors'
```

## Резервне копіювання

- Backup Retention Period: 7 днів
- Встановлено через:
  aws rds modify-db-instance --backup-retention-period 7 ...

```bash
aws rds describe-db-instances \
  --db-instance-identifier library-db \
  --query "DBInstances[0].BackupRetentionPeriod"
1


aws rds modify-db-instance \
  --db-instance-identifier library-db \
  --backup-retention-period 7 \
  --apply-immediately
{
    "DBInstance": {
        "DBInstanceIdentifier": "library-db",
        "DBInstanceClass": "db.t3.micro",
        "Engine": "mysql",
        "DBInstanceStatus": "available",
        "MasterUsername": "admin",
        "Endpoint.............................................


aws rds describe-db-instances \
  --db-instance-identifier library-db \
  --query "DBInstances[0].BackupRetentionPeriod"
7
```

## Моніторинг CloudWatch

1. Метрики:
   - CPUUtilization
   - DatabaseConnections
   - FreeStorageSpace

2. Перевірено через:
   aws cloudwatch get-metric-statistics ...

```bash  
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=library-db \
  --start-time $(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 60 \
  --statistics Average
{
    "Label": "CPUUtilization",
    "Datapoints": [
        {
            "Timestamp": "2025-06-11T16:40:00+00:00",
            "Average": 3.4447094933858238,
            "Unit": "Percent"
        },
        {
            "Timestamp": "2025-06-11T16:36:00+00:00",
            "Average": 3.513621528009059,
            "Unit": "Percent"
        },
        {
            "Timestamp": "2025-06-11T16:32:00+00:00",
            "Average": 3.5802304669286618,
            "Unit": "Percent"
        },
        {
            "Timestamp": "2025-06-11T16:37:00+00:00",
            "Average": 3.3499441675972066,
            "Unit": "Percent"
        },
        {
            "Timestamp": "2025-06-11T16:33:00+00:00",
            "Average": 3.3278286543562023,
            "Unit": "Percent"
        },
        {
            "Timestamp": "2025-06-11T16:38:00+00:00",
            "Average": 3.2832786120231328,
            "Unit": "Percent"
        },
        {
            "Timestamp": "2025-06-11T16:34:00+00:00",
            "Average": 3.541725695428257,
            "Unit": "Percent"
        },
        {
            "Timestamp": "2025-06-11T16:39:00+00:00",
            "Average": 4.116735278921315,
            "Unit": "Percent"
        },
        {
            "Timestamp": "2025-06-11T16:35:00+00:00",
            "Average": 3.766666666666666,
            "Unit": "Percent"
        },
        {
            "Timestamp": "2025-06-11T16:31:00+00:00",
            "Average": 4.604450969270294,
            "Unit": "Percent"
        }
    ]
}
```   

## Prepared on: 6/11/2025 By: Andrii Fil (IT Administrator, DevOps trainee)