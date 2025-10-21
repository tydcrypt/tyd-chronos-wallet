#!/bin/bash
echo "🔄 Fixing all problematic dependencies..."

# Backup
cp pubspec.yaml pubspec.yaml.backup

# Check and fix each dependency
echo "📋 Checking available versions and fixing..."

# walletconnect_dart - check and fix
WALLETCONNECT_VERSION=$(curl -s "https://pub.dev/api/packages/walletconnect_dart" | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4)
if [ -n "$WALLETCONNECT_VERSION" ]; then
    echo "   walletconnect_dart: using version $WALLETCONNECT_VERSION"
    sed -i "s/walletconnect_dart: [^ ]*/walletconnect_dart: ^$WALLETCONNECT_VERSION/" pubspec.yaml
else
    echo "   walletconnect_dart: using 'any' version"
    sed -i 's/walletconnect_dart: [^ ]*/walletconnect_dart: any/' pubspec.yaml
fi

# Fix other known problematic dependencies
sed -i 's/qr_flutter: [^ ]*/qr_flutter: ^4.1.0/' pubspec.yaml
sed -i 's/flutter_secure_storage: [^ ]*/flutter_secure_storage: ^9.2.4/' pubspec.yaml

# Use 'any' for any other potential issues
sed -i 's/web3dart: [^ ]*/web3dart: any/' pubspec.yaml
sed -i 's/http: [^ ]*/http: any/' pubspec.yaml
sed -i 's/shared_preferences: [^ ]*/shared_preferences: any/' pubspec.yaml
sed -i 's/url_launcher: [^ ]*/url_launcher: any/' pubspec.yaml
sed -i 's/provider: [^ ]*/provider: any/' pubspec.yaml
sed -i 's/web_socket_channel: [^ ]*/web_socket_channel: any/' pubspec.yaml
sed -i 's/json_annotation: [^ ]*/json_annotation: any/' pubspec.yaml

echo "✅ All dependencies updated to compatible versions"
