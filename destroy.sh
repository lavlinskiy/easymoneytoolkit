#!/bin/bash
set -e

echo "🗑️ Удаляем основную инфраструктуру..."
terraform destroy -auto-approve

echo "✅ Инфраструктура удалена."
