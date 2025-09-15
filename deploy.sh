#!/bin/bash
set -e

echo "🚀 Разворачиваем Terraform инфраструктуру..."

# Инициализация Terraform
terraform init -upgrade

echo "🏗️ Применяем основную инфраструктуру..."
terraform apply -auto-approve

echo "✅ Готово! Инфраструктура развернута."
