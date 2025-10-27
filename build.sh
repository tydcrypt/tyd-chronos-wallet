#!/bin/bash

echo "🚀 Building TydChronos Wallet for Netlify..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web
echo "🌐 Building web release..."
flutter build web --release --web-renderer html

# Verify build completed
if [ -f "build/web/index.html" ] && [ -f "build/web/main.dart.js" ]; then
    echo "✅ Build successful!"
    echo "📁 Build contents:"
    ls -la build/web/*.html build/web/*.dart.js build/web/*.js | head -10
else
    echo "❌ Build failed - missing critical files"
    echo "Files in build/web/:"
    ls -la build/web/
    exit 1
fi
