#!/usr/bin/env python3
import re

# Read the main.dart file
with open('lib/main.dart', 'r') as f:
    content = f.read()

# First, add the dart:js import if it doesn't exist
if 'import' in content and 'dart:js' not in content:
    # Find the last import statement and add after it
    last_import_match = list(re.finditer(r'^import.*;$', content, re.MULTILINE))[-1]
    last_import_end = last_import_match.end()
    content = content[:last_import_end] + '\nimport \'dart:js\' as js;\n' + content[last_import_end:]

# Now update the TydChronosHomePage initState
old_initstate = '''  @override
  void initState() {
    super.initState();
    print('🏠 TydChronosHomePage initialized successfully!');
  }'''

new_initstate = '''  @override
  void initState() {
    super.initState();
    print('🏠 TydChronosHomePage initialized successfully!');
    
    // Hide the web loading screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        js.context.callMethod('hideLoadingScreen', []);
        print('✅ Web loading screen hidden');
      } catch (e) {
        print('⚠️ Could not hide web loading screen: $e');
      }
    });
  }'''

content = content.replace(old_initstate, new_initstate)

# Write the updated content back
with open('lib/main.dart', 'w') as f:
    f.write(content)

print("✅ Added JavaScript loading screen hide call to TydChronosHomePage")
