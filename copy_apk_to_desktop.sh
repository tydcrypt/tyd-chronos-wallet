#!/bin/bash
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
DESKTOP_PATH="/mnt/c/Users/TYD/Desktop/TydChronos_Wallet_Android_v1.0.0_Optimized.apk"

if [ -f "$APK_PATH" ]; then
    cp "$APK_PATH" "$DESKTOP_PATH"
    echo "✅ Optimized APK copied to: $DESKTOP_PATH"
    echo "📦 Final Size: $(du -h "$DESKTOP_PATH" | cut -f1)"
else
    echo "❌ APK not found at: $APK_PATH"
    exit 1
fi
