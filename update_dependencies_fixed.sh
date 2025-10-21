#!/bin/bash
echo "🔄 Updating all dependencies to compatible versions..."

# Create backup
cp pubspec.yaml pubspec.yaml.backup

# Update each dependency to known working versions
sed -i 's/qr_flutter: \^4\.2\.0/qr_flutter: ^4.1.0/' pubspec.yaml
sed -i 's/flutter_secure_storage: \^8\.2\.0/flutter_secure_storage: ^9.2.4/' pubspec.yaml
sed -i 's/http: \^1\.1\.0/http: ^1.2.1/' pubspec.yaml
sed -i 's/web3dart: \^2\.7\.3/web3dart: ^2.7.3/' pubspec.yaml
sed -i 's/shared_preferences: \^2\.2\.2/shared_preferences: ^2.3.0/' pubspec.yaml
sed -i 's/walletconnect_dart: \^2\.3\.0/walletconnect_dart: ^2.3.0/' pubspec.yaml
sed -i 's/url_launcher: \^6\.1\.11/url_launcher: ^6.3.0/' pubspec.yaml
sed -i 's/provider: \^6\.1\.1/provider: ^6.1.2/' pubspec.yaml
sed -i 's/web_socket_channel: \^2\.4\.0/web_socket_channel: ^2.4.2/' pubspec.yaml
sed -i 's/json_annotation: \^4\.8\.1/json_annotation: ^4.9.0/' pubspec.yaml

# Update dev dependencies
sed -i 's/flutter_lints: \^3\.0\.0/flutter_lints: ^3.0.0/' pubspec.yaml
sed -i 's/build_runner: \^2\.4\.6/build_runner: ^2.4.9/' pubspec.yaml
sed -i 's/json_serializable: \^6\.7\.1/json_serializable: ^6.9.1/' pubspec.yaml
sed -i 's/flutter_launcher_icons: "\^0\.13\.1"/flutter_launcher_icons: ^0.13.1/' pubspec.yaml

echo "✅ Updated all dependencies"

# Show the changes
echo "📋 Changes made:"
grep -E "(qr_flutter|flutter_secure_storage)" pubspec.yaml
