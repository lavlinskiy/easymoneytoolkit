
# Проект деплоя EasyMoney ToolKit в AWS
# ПО называется 

## Описание
Проект автоматизирует развертывание веб-приложения на базе PHP с Nginx и интеграцией с ELK-стеком (Elasticsearch, Logstash, Kibana) и Grafana. 
Используется Terraform для управления инфраструктурой в AWS, а также Docker для контейнеризации сервисов.

Основные возможности проекта:
- Развёртывание EC2-инстанса с Elastic IP
- Развёртывание Docker-контейнеров:
  - PHP-FPM
  - Nginx
  - Postfix (SMTP)
  - Logstash
  - Elasticsearch
  - Kibana
- Логи PHP и Nginx передаются через GELF в Logstash → Elasticsearch
- Визуализация логов в Kibana и метрик в Grafana
- Provisioner Terraform копирует файлы приложения на EC2
- Используется динамический public DNS AWS + Elastic IP.

---

## Структура проекта

├─ modules/
│ ├─ vpc/ # Настройка VPC, подсетей и маршрутов
│ ├─ security_groups/ # Правила безопасности AWS
│ └─ ec2_instance/ # EC2, Elastic IP, provisioners
├─ app/ # Исходный код приложения (PHP, конфиги Nginx, Logstash)
├─ user_data/ # Скрипт инициализации EC2
├─ .github/workflows/ # GitHub Actions для CI/CD
├─ main.tf # Основной Terraform файл
├─ variables.tf # Переменные Terraform
├─ outputs.tf # Outputs Terraform (Elastic IP, public DNS)
└─ backend.config # Конфигурация backend для Terraform


---

## Требования

- Аккаунт AWS с правами на EC2 и S3
- Terraform ≥ 1.9.8
- Docker на EC2
- GitHub Secrets:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `EC2_SSH_PUBLIC_KEY`
  - `EC2_SSH_PRIVATE_KEY`

---

## CI/CD с GitHub Actions

Workflow `.github/workflows/redeploy.yml` выполняет автоматический деплой:

1. Push в ветку `main` запускает workflow.
2. Старые ресурсы уничтожаются (`terraform destroy`).
3. Создаётся backend для Terraform (`terraform apply -target=local_file.backend_config`).
4. Инициализируется Terraform с backend (`terraform init -backend-config=backend.config`).
5. Применяется инфраструктура (`terraform apply`).

**Outputs Terraform** показывают:
- `instance_public_ip` – публичный IP EC2
- `instance_public_dns` – динамический DNS AWS
- URL приложений и сервисов ELK/Grafana

---

## Локальный запуск Docker-контейнеров на EC2

```bash
# Создание сети для контейнеров
docker network create php-net

# Запуск Logstash
docker run -d --name logstash --network php-net \
  -p 5044:5044 -p 12201:12201/udp \
  logstash:7.17.0

# Запуск PHP-FPM
docker run -d --name php-fpm --network php-net \
  -v /tmp/index.php:/var/www/html/index.php \
  -e MAIL_HOST=postfix \
  -e MAIL_PORT=25 \
  -e MAIL_USER=phpuser \
  -e MAIL_PASS=phppass \
  --log-driver=gelf --log-opt gelf-address=udp://logstash:12201 \
  php:8.2-fpm

# Запуск Postfix
docker run -d --name postfix --network php-net \
  -e maildomain="example.com" \
  -e smtp_user=phpuser:phppass \
  catatnight/postfix

# Запуск Nginx
docker run -d --name nginx --network php-net -p 80:80 -p 443:443 \
  -v /tmp/index.php:/var/www/html/index.php \
  -v /tmp/default.conf:/etc/nginx/conf.d/default.conf \
  -v /tmp/nginx.key:/etc/ssl/private/nginx.key \
  -v /tmp/nginx.crt:/etc/ssl/certs/nginx.crt \
  --link php-fpm:php-fpm \
  --link logstash:logstash \
  --log-driver=gelf --log-opt gelf-address=udp://logstash:12201 \
  nginx:alpine

Просмотр логов

    Откройте Kibana → Discover.

    Выберите индекс logstash-*.

    Примените фильтры по контейнеру или уровню логов.

    В Grafana можно визуализировать метрики с Elasticsearch.

Примечания

    Использование Elastic IP гарантирует стабильный публичный IP EC2.
    
    Пока не работает отправка почты, т.к. нет домена. 
    
    Настроить линковку dynamic AWS DNS на Elastic IP не получилось, в terraform user_data переменную с названием хоста передать невозможно.
    
    По этой же причине не удалось полуить FQDN для lets encrypt.

    Provisioner Terraform копирует файлы приложения на инстанс после его создания.

    Динамический public DNS AWS используется для доступа к приложению.

    GELF логирование требует корректной работы контейнеров в одной Docker-сети (php-net) для связи с Logstash.

Контакты

Автор: Alexander Lavlinskiy
Проект: демонстрация деплоя PHP-приложений с ELK/Grafana в AWS.
