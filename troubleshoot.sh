#!/bin/bash

echo "🛠️  TYCHRONOS WALLET TROUBLESHOOTING"
echo "===================================="

echo ""
echo "1. Testing basic Flutter functionality..."
flutter run -d chrome lib/test_basic.dart --web-port 8080 &

echo ""
echo "2. Waiting 10 seconds for basic test..."
sleep 10

echo ""
echo "3. If basic test works, the issue is in main.dart initialization"
echo "4. Check Chrome DevTools (F12) Console for error messages"
echo "5. Look for '🔧 [DEBUG]' messages in the terminal"

echo ""
echo "🎯 NEXT STEPS:"
echo "   - If basic test shows green checkmark: Issue is in TydChronos initialization"
echo "   - If basic test is also blank: Flutter setup issue"
echo "   - Check terminal for debug messages starting with '🔧 [DEBUG]'"

wait
