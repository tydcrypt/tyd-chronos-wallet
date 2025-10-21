#!/bin/bash
echo "📦 Adding missing dependencies..."

# Check if bip39 is already in dependencies
if ! grep -q "bip39:" pubspec.yaml; then
    echo "Adding bip39 package..."
    # Add bip39 to dependencies section
    sed -i '/dependencies:/a\  bip39: ^1.0.6' pubspec.yaml
fi

# Also ensure web3dart is available
if ! grep -q "web3dart:" pubspec.yaml; then
    echo "Adding web3dart package..."
    sed -i '/dependencies:/a\  web3dart: ^2.7.3' pubspec.yaml
fi

# Ensure shared_preferences is available
if ! grep -q "shared_preferences:" pubspec.yaml; then
    echo "Adding shared_preferences package..."
    sed -i '/dependencies:/a\  shared_preferences: ^2.2.2' pubspec.yaml
fi

echo "✅ Dependencies updated"
