#!/bin/bash
# Cấp SSL lần đầu cho tất cả domains
# Chạy 1 lần duy nhất trên VPS sau khi DNS đã trỏ đúng

set -e

DOMAINS=(
    "miushop.io.vn"
    "www.miushop.io.vn"
    "api.miushop.io.vn"
    "miuvis.miushop.io.vn"
    "smartie.miushop.io.vn"
)
EMAIL="your-email@gmail.com"   # ← đổi thành email thật

# Khởi động nginx với config HTTP-only tạm thời để ACME challenge hoạt động
docker compose up -d nginx

for DOMAIN in "${DOMAINS[@]}"; do
    echo "==> Cấp SSL cho $DOMAIN"
    docker compose run --rm certbot certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email "$EMAIL" \
        --agree-tos \
        --no-eff-email \
        -d "$DOMAIN"
done

echo "==> Reload nginx với SSL"
docker compose exec nginx nginx -s reload
echo "✅ Done!"
