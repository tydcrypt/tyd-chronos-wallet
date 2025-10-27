import re

with open('lib/components/walletconnect_button.dart', 'r') as f:
    content = f.read()

# Fix all nullable conditions in walletconnect_button.dart
patterns = [
    (r'if \(wcService\.isConnected\)', 'if (wcService.isConnected == true)'),
    (r'if \(!wcService\.isConnected\)', 'if (wcService.isConnected != true)'),
]

for pattern, replacement in patterns:
    content = re.sub(pattern, replacement, content)

with open('lib/components/walletconnect_button.dart', 'w') as f:
    f.write(content)

print("Fixed walletconnect_button.dart")
