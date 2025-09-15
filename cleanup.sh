#!/bin/bash
set -e

echo "🧹 Быстрая очистка локальных файлов..."
rm -f backend.tf backend.config terraform.tfstate* .terraform.lock.hcl 2>/dev/null || true
rm -rf .terraform/ 2>/dev/null || true
echo "✅ Локальные файлы очищены!"
