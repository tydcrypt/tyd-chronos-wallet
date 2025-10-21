#!/bin/bash

echo "🚀 Building TydChronos Wallet..."

# Fix any pubspec.yaml issues first
echo "🔧 Checking and fixing configuration..."
if grep -q "web:" pubspec.yaml && grep -q "flutter:" pubspec.yaml; then
    # Check if web is under flutter (incorrect)
    if awk '/flutter:/{found=1} found && /web:/{print "ERROR"}' pubspec.yaml | grep -q "ERROR"; then
        echo "⚠️  Fixing pubspec.yaml structure..."
        # Create a clean pubspec.yaml
        cat > pubspec.yaml << 'FIXED_PUBSPEC'
name: tydchronos_wallet
description: Advanced Banking & Cryptocurrency Platform

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  web3dart: ^2.3.5
  bip39: ^1.0.6
  shared_preferences: ^2.2.2
  http: ^0.13.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icon/
FIXED_PUBSPEC
        echo "✅ pubspec.yaml fixed"
    fi
fi

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    echo "Trying with --verbose to see the issue..."
    flutter pub get --verbose
    exit 1
fi

# Test on Chrome
echo "🌐 Testing on Chrome..."
flutter run -d chrome --verbose

echo "✅ Build process completed!"
