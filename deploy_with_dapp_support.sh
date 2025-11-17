#!/bin/bash
echo "🚀 Deploying Tydchronos Wallet with DApp Support..."

echo "📦 Building Flutter web version..."
flutter build web --release

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "🎯 DApp Connectivity Features Added:"
    echo "   - Message handling for connection requests"
    echo "   - Connection confirmation dialogs"
    echo "   - Wallet address sharing"
    echo "   - Transaction signing interface"
    echo "   - Security origin validation"
    echo ""
    echo "📋 Deployment Instructions:"
    echo "1. Go to: https://app.netlify.com/"
    echo "2. Drag folder: $(pwd)/build/web"
    echo "3. Drop on Netlify deployment area"
    echo "4. Your wallet will be at: https://[your-site].netlify.app"
    echo ""
    echo "🔗 Test the integration:"
    echo "1. Open your Tydchronos DApp"
    echo "2. Click 'Connect Tydchronos Dual-wallet'"
    echo "3. Wallet should open and show connection dialog"
else
    echo "❌ Build failed! Check Flutter errors."
fi
