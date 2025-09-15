#!/bin/bash

sleep 30

PUBLIC_DNS=$(curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/public-hostname)

if [ -z "$PUBLIC_DNS" ]; then
    echo "Публичный DNS не получен, используем самоподписанные сертификаты"
    exit 0
fi

yum install -y certbot

docker stop nginx

if certbot certonly --standalone --non-interactive --agree-tos \
    --email admin@example.com -d $PUBLIC_DNS --preferred-challenges http --http-01-port 80; then

    cp -rf /etc/letsencrypt/live/$PUBLIC_DNS/fullchain.pem /tmp/nginx.crt
    cp -rf /etc/letsencrypt/live/$PUBLIC_DNS/privkey.pem /tmp/nginx.key

    docker start nginx

    cat > /etc/cron.d/letsencrypt-renew << CRON
0 3 * * * root certbot renew --quiet --post-hook "docker stop nginx && docker start nginx"
CRON

    echo "Let's Encrypt настроен для $PUBLIC_DNS"
else
    echo "Не удалось получить сертификат, используем самоподписанные"
    docker start nginx
fi
