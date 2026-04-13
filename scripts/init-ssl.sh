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
    "router.miushop.io.vn"
    "openclaw.miushop.io.vn"
)
EMAIL="your-email@gmail.com"   # ← đổi thành email thật

CONF_DIR="./nginx/conf.d"
BACKUP_DIR="./nginx/conf.d.bak"

# Backup config thật, dùng config tạm để nginx start được (không cần upstream)
echo "==> Backup nginx conf.d và dùng config tạm..."
mv "$CONF_DIR" "$BACKUP_DIR"
mkdir -p "$CONF_DIR"

cat > "$CONF_DIR/acme.conf" <<'EOF'
server {
    listen 80 default_server;
    server_name _;
    location /.well-known/acme-challenge/ { root /var/www/certbot; }
    location / { return 200 'ok'; }
}
EOF

# Khởi động nginx với config HTTP-only tạm thời
echo "==> Khởi động nginx tạm..."
docker compose up -d nginx

sleep 2

for DOMAIN in "${DOMAINS[@]}"; do
    echo "==> Cấp SSL cho $DOMAIN"
    docker compose run --rm --entrypoint certbot certbot certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email "$EMAIL" \
        --agree-tos \
        --no-eff-email \
        -d "$DOMAIN"
done

# Restore config thật
echo "==> Restore nginx conf.d..."
rm -rf "$CONF_DIR"
mv "$BACKUP_DIR" "$CONF_DIR"

echo "==> Reload nginx với SSL"
docker compose exec nginx nginx -s reload

echo "✅ Done! SSL đã được cấp cho tất cả domains."
