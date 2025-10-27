with open('lib/main.dart', 'r') as f:
    content = f.read()

# Add TradingController to the providers list
if "ChangeNotifierProvider(create: (context) => TradingController())" not in content:
    # Find the providers section and add TradingController
    # Look for the MultiProvider in TydChronosHomePage
    import re
    
    # Pattern to find the providers list in TydChronosHomePage
    pattern = r'(return MultiProvider\(\s+providers: \[)([^\]]+)(\],)'
    
    def replace_providers(match):
        existing_providers = match.group(2)
        # Check if BalanceVisibilityManager is already there
        if 'ChangeNotifierProvider.value(value: _balanceManager)' in existing_providers:
            # Add TradingController after BalanceVisibilityManager
            return match.group(1) + existing_providers + '\\n        ChangeNotifierProvider(create: (context) => TradingController()),' + match.group(3)
        else:
            return match.group(1) + '\\n        ChangeNotifierProvider(create: (context) => TradingController()),' + existing_providers + match.group(3)
    
    content = re.sub(pattern, replace_providers, content, flags=re.DOTALL)
    print("TradingController added to MultiProvider")
else:
    print("TradingController already in MultiProvider")

with open('lib/main.dart', 'w') as f:
    f.write(content)
