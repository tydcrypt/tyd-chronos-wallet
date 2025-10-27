#!/bin/bash

echo "🔍 Build Verification:"

if [ -d "build/web" ]; then
    echo "✅ Build directory exists"
    echo "📁 Build contents:"
    ls -la build/web/ | head -10
    
    if [ -f "build/web/index.html" ]; then
        echo "✅ Main index.html found"
        echo "📊 Build size:"
        du -sh build/web/
        echo "🎉 Build successful!"
    else
        echo "❌ Missing index.html"
    fi
else
    echo "❌ Build directory missing"
    echo "💡 Try running: flutter clean && flutter pub get && flutter build web --release"
fi
