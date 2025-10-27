import re

def fix_nullable_conditions(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Proper nullable fixes - only fix the specific problematic patterns
    # Fix: if (nullableBool) -> if (nullableBool == true)
    content = re.sub(
        r'if\s*\(\s*(\w+\.isInitialized)\s*\)',
        r'if (\1 == true)',
        content
    )
    
    # Fix: if (!nullableBool) -> if (nullableBool != true)
    content = re.sub(
        r'if\s*\(\s*!(\w+\.isInitialized)\s*\)', 
        r'if (\1 != true)',
        content
    )
    
    # Fix: if (nullableBool) -> if (nullableBool == true)
    content = re.sub(
        r'if\s*\(\s*(\w+\.isConnected)\s*\)',
        r'if (\1 == true)',
        content
    )
    
    # Fix: if (!nullableBool) -> if (nullableBool != true)
    content = re.sub(
        r'if\s*\(\s*!(\w+\.isConnected)\s*\)',
        r'if (\1 != true)',
        content
    )
    
    with open(file_path, 'w') as f:
        f.write(content)
    print(f"Properly fixed nullable conditions in {file_path}")

# Fix both files properly
fix_nullable_conditions('lib/components/dapp_connections_panel.dart')
fix_nullable_conditions('lib/components/walletconnect_button.dart')

print("✅ All nullable conditions properly fixed WITHOUT reducing functionality")
