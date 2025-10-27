#!/bin/bash

echo "🔍 Environment Analysis:"

# Check if we're in WSL
if grep -q Microsoft /proc/version 2>/dev/null; then
    echo "✅ Environment: Windows Subsystem for Linux (WSL)"
    ENV_TYPE="wsl"
elif [ -d "/mnt/c" ]; then
    echo "✅ Environment: Linux with Windows access (possibly WSL1)"
    ENV_TYPE="wsl1"
elif [ -f "/etc/os-release" ]; then
    echo "✅ Environment: Native Linux"
    source /etc/os-release
    echo "   Distribution: $PRETTY_NAME"
    ENV_TYPE="linux"
else
    echo "❓ Environment: Unknown Linux-like environment"
    ENV_TYPE="unknown"
fi

# Check Flutter accessibility
echo ""
echo "📱 Flutter Status:"
if command -v flutter &> /dev/null; then
    flutter --version | head -1
    echo "✅ Flutter is accessible"
else
    echo "❌ Flutter not found in PATH"
fi

# Check build capability
echo ""
echo "🏗️  Build Capability:"
if [ -f "pubspec.yaml" ]; then
    echo "✅ Flutter project detected"
else
    echo "❌ Not in a Flutter project directory"
fi

echo ""
echo "💡 Recommended build method:"
case $ENV_TYPE in
    "wsl"|"wsl1")
        echo "   Use: ./build_wsl2.sh"
        ;;
    "linux")
        echo "   Use: ./build.sh"
        ;;
    *)
        echo "   Use manual steps from MANUAL_BUILD_GUIDE.md"
        ;;
esac
