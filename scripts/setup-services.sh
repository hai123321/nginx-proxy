#!/bin/bash
# Clone các service repos về thư mục ./services/
# Chạy 1 lần sau khi clone nginx-proxy về server

set -e

mkdir -p services

clone_or_pull() {
    local repo=$1
    local dir=$2
    if [ -d "$dir/.git" ]; then
        echo "==> Pull $dir..."
        git -C "$dir" pull
    else
        echo "==> Clone $repo -> $dir..."
        git clone "$repo" "$dir"
    fi
}

clone_or_pull https://github.com/decolua/9router      services/9router
clone_or_pull https://github.com/openclaw/openclaw    services/openclaw
clone_or_pull https://github.com/NousResearch/hermes-agent services/hermes-agent

echo ""
echo "==> Copy file .env mẫu (nếu chưa có)..."

for svc in 9router openclaw hermes-agent; do
    env_file="services/$svc/.env"
    example_file="services/$svc/.env.example"
    if [ ! -f "$env_file" ] && [ -f "$example_file" ]; then
        cp "$example_file" "$env_file"
        echo "  Created $env_file từ .env.example — hãy điền các giá trị cần thiết!"
    elif [ ! -f "$env_file" ]; then
        touch "$env_file"
        echo "  Created $env_file trống — hãy điền biến môi trường!"
    fi
done

echo ""
echo "✅ Done! Bước tiếp theo:"
echo "  1. Điền .env cho từng service trong services/"
echo "  2. docker compose -f docker-compose.services.yml build"
echo "  3. docker compose -f docker-compose.services.yml up -d"
