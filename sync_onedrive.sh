#!/bin/bash
echo "🔄 Syncing to OneDrive..."
SOURCE="./build/web"
TARGET="$HOME/OneDrive/TydChronosWallet/build_$(date +%Y%m%d)"
mkdir -p "$TARGET"
cp -r "$SOURCE"/* "$TARGET"/ 2>/dev/null || echo "⚠️  No build files"
echo "✅ Synced to: $TARGET"
