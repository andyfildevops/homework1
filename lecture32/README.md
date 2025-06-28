# Lecture 32. Advanced Ansible

## Структура проекту

```
lecture32/
├── inventory/
│   └── aws_ec2.yml
├── playbooks/
│   ├── baseline.yml
│   ├── firewall.yml
│   ├── nginx.yml
│   └── full-setup.yml
├── roles/
│   ├── baseline/
│   │   └── tasks/
│   │       └── main.yml
│   ├── firewall/
│   │   └── tasks/
│   │       └── main.yml
│   └── nginx/
│       ├── tasks/
│       │   └── main.yml
│       └── templates/
│           └── index.html.j2
├── vault/
│   └── secrets.yml (зашифровано)
└── README.md
```

## Опис ролей

### Роль baseline

- Генерація та налаштування SSH-ключів для доступу до серверів.
- Встановлення базових пакетів: `vim`, `git`, `mc`, `ufw`.

Файл: `roles/baseline/tasks/main.yml`

```yaml
- name: Встановлення базових пакетів
  apt:
    name: ['vim', 'git', 'mc', 'ufw']
    state: present
    update_cache: yes

- name: Додавання SSH ключа
  authorized_key:
    user: "{{ ansible_user }}"
    key: "{{ lookup('file', '~/.ssh/id_ed25519.pub') }}"
```

### Роль firewall

- Налаштування базових правил firewall за допомогою `ufw`.

Файл: `roles/firewall/tasks/main.yml`

```yaml
- name: Дозволити SSH
  ufw:
    rule: allow
    port: 22

- name: Дозволити HTTP
  ufw:
    rule: allow
    port: 80

- name: Включити UFW
  ufw:
    state: enabled
```

### Роль nginx

- Встановлення `nginx`.
- Конфігурація та розгортання файлу `index.html` через шаблон.

Файл: `roles/nginx/tasks/main.yml`

```yaml
- name: Встановлення Nginx
  apt:
    name: nginx
    state: present
    update_cache: yes

- name: Шаблонізований index.html
  template:
    src: index.html.j2
    dest: /var/www/html/index.html

- name: Запуск служби Nginx
  service:
    name: nginx
    state: started
    enabled: yes
```

Шаблон: `roles/nginx/templates/index.html.j2`

```html
<!DOCTYPE html>
<html>
<head>
  <title>{{ inventory_hostname }}</title>
</head>
<body>
  <h1>Вітаємо на сервері {{ inventory_hostname }}</h1>
</body>
</html>
```

## Dynamic Inventory

Файл: `inventory/aws_ec2.yml`

```yaml
plugin: aws_ec2
regions:
  - us-east-1
filters:
  tag:AnsibleManaged: true
keyed_groups:
  - key: tags.Role
    prefix: role
```

## Ansible Vault

Для шифрування конфіденційних даних (наприклад, паролів) використовується Ansible Vault.

Зашифрований файл: `vault/secrets.yml`

```yaml
db_password: "my_secure_password"
```

Створення зашифрованого файлу:

```bash
ansible-vault create vault/secrets.yml
```

Запуск плейбуків із Ansible Vault:

```bash
ansible-playbook playbooks/full-setup.yml --ask-vault-pass
```

## Playbooks

- **baseline.yml** – застосовує роль baseline:

```yaml
- hosts: all
  become: yes
  roles:
    - baseline
```

- **firewall.yml** – застосовує роль firewall:

```yaml
- hosts: all
  become: yes
  roles:
    - firewall
```

- **nginx.yml** – застосовує роль nginx:

```yaml
- hosts: all
  become: yes
  roles:
    - nginx
```

- **full-setup.yml** – застосовує всі ролі одночасно:

```yaml
- hosts: all
  become: yes
  vars_files:
    - ../vault/secrets.yml
  roles:
    - baseline
    - firewall
    - nginx
```

## Запуск плейбуків

```bash
ansible-playbook -i inventory/aws_ec2.yml playbooks/baseline.yml
ansible-playbook -i inventory/aws_ec2.yml playbooks/firewall.yml
ansible-playbook -i inventory/aws_ec2.yml playbooks/nginx.yml
ansible-playbook -i inventory/aws_ec2.yml playbooks/full-setup.yml --ask-vault-pass
```

---

## Prepared on: 2025-06-28
By: Andrii Fil (IT Administrator, DevOps trainee)
