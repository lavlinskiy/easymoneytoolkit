#!/bin/bash

set -e

# --- Установка базовых пакетов ---
dnf install -y docker
systemctl enable --now docker

MAIL_DOMAIN="${maildomain}"

# --- Генерация самоподписанных сертификатов на время ---
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /tmp/nginx.key \
    -out /tmp/nginx.crt \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=Company/CN=localhost"

#sleep 30s 
#chmod +x /tmp/letsencrypt.sh

# --- Запуск контейнеров по очереди с зависимостями ---
#postfix 

docker network create php-net

docker run -d --name postfix \
  --network php-net \
  -e maildomain="$MAIL_DOMAIN" \
  -e smtp_user=phpuser:phppass \
  catatnight/postfix

# Elasticsearch
docker run -d --name elasticsearch \
  -p 9200:9200 \
  -e "discovery.type=single-node" \
  -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
  elasticsearch:7.17.0

#Logstash

docker run -d --name logstash \
  -p 5044:5044 \
  -v /tmp/logstash.conf:/usr/share/logstash/pipeline/logstash.conf \
  -e "LS_JAVA_OPTS=-Xms256m -Xmx256m" \
  --link elasticsearch:elasticsearch \
  logstash:7.17.0

# PHP-FPM
docker run -d --name php-fpm \
  --network php-net \
  -v /tmp/index.php:/var/www/html/index.php \
  -e MAIL_HOST=postfix \
  -e MAIL_PORT=25 \
  -e MAIL_USER=phpuser \
  -e MAIL_PASS=phppass \
  --log-driver=gelf \
  --log-opt gelf-address=udp://logstash:12201 \
  php:8.2-fpm

# Nginx
docker run -d --name nginx \
  -p 80:80 -p 443:443 \
  -v /tmp/index.php:/var/www/html/index.php \
  -v /tmp/default.conf:/etc/nginx/conf.d/default.conf \
  -v /tmp/nginx.key:/etc/ssl/private/nginx.key \
  -v /tmp/nginx.crt:/etc/ssl/certs/nginx.crt \
  --link php-fpm:php-fpm \
  --link logstash:logstash \
  --log-driver=gelf \
  --log-opt gelf-address=udp://logstash:12201 \
  nginx:alpine

# Kibana
docker run -d --name kibana \
  -p 5601:5601 \
  --link elasticsearch:elasticsearch \
  kibana:7.17.0

# Grafana
docker run -d --name grafana \
  -p 3000:3000 \
  -e "GF_SECURITY_ADMIN_USER=admin" \
  -e "GF_SECURITY_ADMIN_PASSWORD=admin12345678" \
  --link elasticsearch:elasticsearch \
  grafana/grafana:latest

# --- Запуск letsencrypt.sh в фоне ---

echo "Инициализация завершена!"
