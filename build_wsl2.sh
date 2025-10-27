#!/bin/bash

echo "🚀 Building TydChronos Wallet - WSL2 Optimized"

# WSL2-specific optimizations
export CHROME_EXECUTABLE="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"

echo "📊 System Resources:"
free -h

echo "🧹 Step 1: Cleaning build environment..."
flutter clean

echo "📦 Step 2: Getting dependencies..."
flutter pub get

echo "🔧 Step 3: Updating outdated packages..."
flutter pub outdated --mode=null-safety

echo "🌐 Step 4: Building web release (compatible with Flutter 3.35.7)..."
# For Flutter 3.35.7, use simpler build command without --web-renderer
flutter build web --release

echo "🔍 Step 5: Verifying build..."
./verify_build.sh
