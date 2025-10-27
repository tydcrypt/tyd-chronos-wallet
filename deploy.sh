#!/bin/bash
echo "🚀 TydChronos Wallet Deployment"
echo "1. Building..."
flutter clean && flutter pub get && flutter build web --release
echo "✅ Build complete!"
echo "💡 Run: netlify deploy --prod --dir=build/web"
echo "💡 Run: ./sync_onedrive.sh"
echo "🎉 Deployment ready!"
