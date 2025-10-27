import re

with open('lib/components/dapp_connections_panel.dart', 'r') as f:
    content = f.read()

# Fix all nullable conditions in dapp_connections_panel.dart
patterns = [
    (r'if \(wcService\.isInitialized\)', 'if (wcService.isInitialized == true)'),
    (r'if \(!wcService\.isInitialized\)', 'if (wcService.isInitialized != true)'),
]

for pattern, replacement in patterns:
    content = re.sub(pattern, replacement, content)

# Fix the Future[] operator issue properly
# We need to find the method and add proper await handling
content = re.sub(
    r"final String address = wcService\.getWalletInfo\(\)\[\"address\"\];",
    "final Map<String, dynamic> walletInfo = await wcService.getWalletInfo();\n      final String address = walletInfo[\"address\"];",
    content
)

with open('lib/components/dapp_connections_panel.dart', 'w') as f:
    f.write(content)

print("Fixed dapp_connections_panel.dart")
