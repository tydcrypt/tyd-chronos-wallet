#!/bin/bash
set -e

echo "=== Installing Flutter ==="
# Install Flutter
git clone https://github.com/flutter/flutter.git --depth 1 -b stable
export PATH="$PATH:$(pwd)/flutter/bin"

echo "=== Setting up Flutter ==="
flutter precache
flutter config --enable-web
flutter doctor

echo "=== Building Flutter web ==="
flutter build web --release

echo "=== Build completed successfully ==="
