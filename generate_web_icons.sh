#!/bin/bash
echo "🔄 Generating web icons from assets/icon/icon.png..."

# Check if ImageMagick is available
if command -v convert &> /dev/null; then
    echo "📐 Resizing icons for web..."
    
    # Create web directory if it doesn't exist
    mkdir -p web/icons
    
    # Generate different sizes from your main icon
    convert assets/icon/icon.png -resize 72x72 web/icons/icon-72x72.png
    convert assets/icon/icon.png -resize 96x96 web/icons/icon-96x96.png
    convert assets/icon/icon.png -resize 128x128 web/icons/icon-128x128.png
    convert assets/icon/icon.png -resize 144x144 web/icons/icon-144x144.png
    convert assets/icon/icon.png -resize 152x152 web/icons/icon-152x152.png
    convert assets/icon/icon.png -resize 192x192 web/icons/icon-192x192.png
    convert assets/icon/icon.png -resize 384x384 web/icons/icon-384x384.png
    convert assets/icon/icon.png -resize 512x512 web/icons/icon-512x512.png
    
    # Copy as favicon
    cp assets/icon/icon.png web/favicon.png
    
    echo "✅ Web icons generated in web/icons/"
else
    echo "⚠️ ImageMagick not found. Using main icon for all sizes..."
    
    # Create web directory if it doesn't exist
    mkdir -p web/icons
    
    # Copy main icon to all required sizes (Flutter will handle resizing)
    cp assets/icon/icon.png web/icons/icon-72x72.png
    cp assets/icon/icon.png web/icons/icon-96x96.png
    cp assets/icon/icon.png web/icons/icon-128x128.png
    cp assets/icon/icon.png web/icons/icon-144x144.png
    cp assets/icon/icon.png web/icons/icon-152x152.png
    cp assets/icon/icon.png web/icons/icon-192x192.png
    cp assets/icon/icon.png web/icons/icon-384x384.png
    cp assets/icon/icon.png web/icons/icon-512x512.png
    
    # Copy as favicon
    cp assets/icon/icon.png web/favicon.png
    
    echo "✅ Main icon copied to web/icons/ (resizing will happen during build)"
fi
