#!/bin/bash

echo "🔧 Fixing common Flutter issues..."

# Clean the project
echo "🧹 Cleaning project..."
flutter clean

# Clear pub cache
echo "🗑️  Clearing pub cache..."
flutter pub cache clean

# Get dependencies again
echo "📦 Reinstalling dependencies..."
flutter pub get

# Check for any issues
echo "🔍 Checking for issues..."
flutter analyze

echo "✅ Issue fixing completed!"
