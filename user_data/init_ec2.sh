#!/bin/bash

set -e

# --- Установка базовых пакетов ---
dnf install -y docker
systemctl enable --now docker

# --- Генерация самоподписанных сертификатов на время ---
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /tmp/nginx.key \
    -out /tmp/nginx.crt \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=Company/CN=localhost"

#sleep 30s 
#chmod +x /tmp/letsencrypt.sh

# --- Запуск контейнеров по очереди с зависимостями ---

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
  -v /tmp/index.php:/var/www/html/index.php \
  --log-driver=gelf \
  --log-opt gelf-address=udp://127.0.0.1:12201 \
  php:8.2-fpm

docker exec -u root php-fpm sh -c "apt-get update && apt-get install -y postfix procps && /etc/init.d/postfix start"

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
  --log-opt gelf-address=udp://127.0.0.1:12201 \
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
#nohup /tmp/letsencrypt.sh > /tmp/letsencrypt.log 2>&1 &

echo "Инициализация завершена! Все контейнеры запущены, Let's Encrypt работает в фоне."
