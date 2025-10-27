import re

def fix_file(filename):
    with open(filename, 'r') as f:
        content = f.read()
    
    # Fix all nullable boolean conditions
    patterns = [
        # Fix if (nullableBool) -> if (nullableBool == true)
        (r'if\s*\(\s*(\w+\.\w+)\s*\)', r'if (\1 == true)'),
        # Fix if (!nullableBool) -> if (nullableBool != true)  
        (r'if\s*\(\s*!(\w+\.\w+)\s*\)', r'if (\1 != true)'),
    ]
    
    changes_made = False
    for pattern, replacement in patterns:
        new_content = re.sub(pattern, replacement, content)
        if new_content != content:
            changes_made = True
            content = new_content
    
    if changes_made:
        with open(filename, 'w') as f:
            f.write(content)
        print(f"Fixed nullable conditions in {filename}")
    else:
        print(f"No nullable conditions found in {filename}")

# Fix both files
fix_file('lib/components/dapp_connections_panel.dart')
fix_file('lib/components/walletconnect_button.dart')
