#!/bin/bash
echo "🔧 Fixing flutter_launcher_icons configuration..."

# Create backup
cp pubspec.yaml pubspec.yaml.backup.icons

# Replace the boolean 'web: true' with proper map configuration
sed -i '/flutter_launcher_icons:/,/^[a-z]/ {
    /web: true/ {
        c\
  web:\
    generate: true\
    image_path: "assets/icon/icon.png"\
    background_color: "#000000"\
    theme_color: "#D4AF37"
    }
}' pubspec.yaml

echo "✅ Fixed web configuration in flutter_launcher_icons"
