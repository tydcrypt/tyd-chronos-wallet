#!/bin/bash

echo "📦 Checking and updating dependencies..."

# Check for outdated packages
echo "🔍 Checking outdated packages:"
flutter pub outdated

# Update dependencies to latest compatible versions
echo "🔄 Updating dependencies..."
flutter pub upgrade

# Check for any dependency issues
echo "✅ Verifying dependencies..."
flutter pub get

echo "🎉 Dependency update complete!"
