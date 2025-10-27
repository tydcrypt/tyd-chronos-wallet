#!/bin/bash

echo "🔧 Fixing uninitialized late variables..."

# Create backup
cp lib/main.dart lib/main.dart.backup.$(date +%Y%m%d_%H%M%S)

# Fix the late variables by adding proper initialization
sed -i 's/late \(.*\);/late \1 = "";/g' lib/main.dart

echo "✅ Fixed late variables - initialized with empty strings"
echo "📋 Changes made:"
grep -n "late " lib/main.dart
