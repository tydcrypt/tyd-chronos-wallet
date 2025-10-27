#!/usr/bin/env python3
import re
import sys

def check_main_dart_issues(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    
    issues = []
    
    # Check 1: Main function structure
    if 'void main() async' not in content:
        issues.append("❌ Main function should be async")
    
    if 'WidgetsFlutterBinding.ensureInitialized()' not in content:
        issues.append("❌ Missing WidgetsFlutterBinding.ensureInitialized()")
    
    # Check 2: _debugCheckAssets function
    if 'Future<void> _debugCheckAssets() async' not in content:
        issues.append("❌ _debugCheckAssets should return Future<void>")
    
    if 'await _debugCheckAssets()' not in content:
        issues.append("❌ Missing await for _debugCheckAssets call")
    
    # Check 3: Error handling
    if 'catch (error, stackTrace)' not in content:
        issues.append("❌ Missing error handling in main()")
    
    # Check 4: Critical services
    critical_services = [
        'TydChronosEcosystemService',
        'NetworkModeManager', 
        'CurrencyManager',
        'TydChronosWalletApp',
        'MultiProvider',
        'runApp'
    ]
    
    for service in critical_services:
        if service not in content:
            issues.append(f"❌ Missing critical service: {service}")
    
    # Check 5: Import statements
    if 'import' not in content[:500]:  # Check first 500 chars
        issues.append("❌ Import statements might be missing")
    
    return issues

issues = check_main_dart_issues('lib/main.dart')

if issues:
    print("🚨 RUNTIME ISSUES FOUND:")
    for issue in issues:
        print(f"   {issue}")
    sys.exit(1)
else:
    print("✅ No runtime issues found in main.dart")
    print("✅ All critical services present")
