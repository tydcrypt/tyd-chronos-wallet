import re

with open('lib/components/dapp_connections_panel.dart', 'r') as f:
    content = f.read()

# Find the build method and check if it needs async
if 'Widget build(' in content and 'getWalletInfo()' in content:
    # Check if build method already has async
    if 'Widget build(BuildContext context) async' not in content:
        # Add async to the build method
        content = content.replace(
            'Widget build(BuildContext context) {',
            'Widget build(BuildContext context) async {'
        )
        print("Added async to build method")

with open('lib/components/dapp_connections_panel.dart', 'w') as f:
    f.write(content)

print("Fixed async/await issues")
