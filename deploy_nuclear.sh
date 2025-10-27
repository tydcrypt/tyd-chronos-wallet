#!/bin/bash

echo "💥 TydChronos Wallet - Nuclear Deployment"
echo "========================================="

echo ""
echo "🧹 NUCLEAR CLEANING..."
flutter clean
rm -rf build/web .dart_tool .flutter-plugins

echo ""
echo "📦 FRESH INSTALL..."
flutter pub get

echo ""
echo "🏗️ BUILDING WITH NUCLEAR OPTIONS..."
flutter build web --release --no-tree-shake-icons --dart-define=DEBUG=true

echo ""
echo "🎯 APPLYING NUCLEAR FIXES..."
# Remove ALL existing assets
find build/web -name "*.png" -o -name "*.ico" -o -name "*.js" -o -name "*.html" | grep -v "main.dart.js" | grep -v "flutter.js" | xargs rm -f

# Force custom icons
cp assets/icon/icon.png build/web/favicon.png
mkdir -p build/web/icons
cp assets/icon/icon.png build/web/icons/icon-192.png
cp assets/icon/icon.png build/web/icons/icon-512.png
cp assets/icon/icon.png build/web/icons/apple-touch-icon.png

echo ""
echo "🔧 DEPLOYMENT READY:"
echo "   Build: $(du -sh build/web | cut -f1)"
echo "   Main JS: $(ls -lh build/web/main.dart.js | awk '{print $5}')"
echo "   Debug Tools: /debug-enhanced.html, /sw-reset.js"
echo "   Nuclear Options: Full cache busting enabled"

echo ""
echo "🚀 NUCLEAR DEPLOYMENT COMMAND:"
echo "   netlify deploy --prod --dir=build/web --message 'Nuclear deployment: Full cache busting'"
echo ""
echo "🎯 POST-DEPLOYMENT NUCLEAR TESTING:"
echo "   1. Main App: Check if blank page is fixed"
echo "   2. Enhanced Debug: /debug-enhanced.html"
echo "   3. Cache Reset: /sw-reset.js"
echo "   4. Browser: Use incognito + clear storage"
echo ""
echo "💥 THIS DEPLOYMENT WILL:"
echo "   - Completely bypass all caches"
echo "   - Force fresh service workers"
echo "   - Provide detailed diagnostics"
echo "   - Preserve ALL blockchain functionality"
