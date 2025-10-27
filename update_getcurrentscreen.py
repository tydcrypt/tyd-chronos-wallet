with open('lib/main.dart', 'r') as f:
    content = f.read()

# Replace the _getCurrentScreen method
old_method = """Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return OverviewScreen(
          cryptoWallet: _cryptoWallet,
          fiatWallet: _fiatWallet,
          tradingBot: _tradingBot,
        );
      case 1:
        return CryptoScreen(
          cryptoWallet: _cryptoWallet,
          tradingBot: _tradingBot,
        );
      case 2:
        return EWalletScreen(fiatWallet: _fiatWallet);
      case 3:
        return const SettingsSecurityScreen();
      default:
        return OverviewScreen(
          cryptoWallet: _cryptoWallet,
          fiatWallet: _fiatWallet,
          tradingBot: _tradingBot,
        );
    }
  }"""

new_method = """Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return OverviewScreen(
          cryptoWallet: _cryptoWallet,
          fiatWallet: _fiatWallet,
          tradingBot: _tradingBot,
        );
      case 1:
        return CryptoScreen(
          cryptoWallet: _cryptoWallet,
          tradingBot: _tradingBot,
        );
      case 2:
        return ChangeNotifierProvider(
          create: (context) => TradingController(),
          child: const AutomatedTradingScreen(),
        );
      case 3:
        return EWalletScreen(fiatWallet: _fiatWallet);
      case 4:
        return const SettingsSecurityScreen();
      default:
        return OverviewScreen(
          cryptoWallet: _cryptoWallet,
          fiatWallet: _fiatWallet,
          tradingBot: _tradingBot,
        );
    }
  }"""

if old_method in content:
    content = content.replace(old_method, new_method)
    print("_getCurrentScreen method updated successfully")
else:
    print("Could not find exact _getCurrentScreen method pattern")
    print("Looking for alternative patterns...")
    
    # Try to find and replace just the case 2 section
    import re
    pattern = r'(case 2:[\s\S]*?return EWalletScreen\(fiatWallet: _fiatWallet\);)'
    replacement = 'case 2:\\n        return ChangeNotifierProvider(\\n          create: (context) => TradingController(),\\n          child: const AutomatedTradingScreen(),\\n        );'
    
    if re.search(pattern, content):
        content = re.sub(pattern, replacement, content)
        print("Updated case 2 in _getCurrentScreen method")
    else:
        print("Could not find case 2 to update")

with open('lib/main.dart', 'w') as f:
    f.write(content)
