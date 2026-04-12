# nginx-proxy

Central reverse proxy cho tất cả services trên VPS.

## Kiến trúc

```
port 80/443 → nginx-proxy
                ├── miushop.io.vn        → e-com frontend (port 3000)
                ├── api.miushop.io.vn    → e-com api      (port 3001)
                ├── miuvis.miushop.io.vn → miuvis         (port 4000)
                └── smartie.miushop.io.vn→ sa-smartie     (port 5000)
```

Tất cả services giao tiếp qua Docker network **`proxy-net`**.

## Deploy lần đầu

```bash
# 1. Clone repo
git clone https://github.com/hai123321/nginx-proxy.git
cd nginx-proxy

# 2. Sửa email trong scripts/init-ssl.sh
# 3. Đảm bảo DNS đã trỏ về IP VPS cho tất cả domains

# 4. Cấp SSL
bash scripts/init-ssl.sh

# 5. Khởi động (nếu chưa chạy từ bước 4)
docker compose up -d
```

## Thêm service mới

1. Tạo file `nginx/conf.d/ten-service.conf`
2. Cấp SSL: `docker compose run --rm certbot certonly --webroot -w /var/www/certbot -d ten-domain.miushop.io.vn`
3. `docker compose exec nginx nginx -s reload`
