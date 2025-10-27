import re

# Read the main.dart file
with open('lib/main.dart', 'r') as file:
    content = file.read()

# Update the main bottom navigation items to include TRADING
old_main_nav = '''items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'OVERVIEW'),
              BottomNavigationBarItem(icon: Icon(Icons.currency_bitcoin), label: 'CRYPTO'),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'E-WALLET'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'SETTINGS'),
            ],'''

new_main_nav = '''items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'OVERVIEW'),
              BottomNavigationBarItem(icon: Icon(Icons.currency_bitcoin), label: 'CRYPTO'),
              BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_motion), label: 'TRADING'),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'E-WALLET'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'SETTINGS'),
            ],'''

content = content.replace(old_main_nav, new_main_nav)

# Update the _getCurrentScreen method to handle 5 items instead of 4
old_getCurrentScreen = '''Widget _getCurrentScreen() {
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
  }'''

new_getCurrentScreen = '''Widget _getCurrentScreen() {
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
  }'''

content = content.replace(old_getCurrentScreen, new_getCurrentScreen)

# Add the import for automated trading at the top
if 'import' in content and 'automated_trading.dart' not in content:
    # Find a good place to insert the import (after other imports)
    import_section_end = content.find('// ==================== NETWORK MODE MANAGER ====================')
    if import_section_end != -1:
        import_statement = 'import '\''features/automated_trading/automated_trading.dart'\'';\n\n'
        content = content[:import_section_end] + import_statement + content[import_section_end:]

# Add TradingController to MultiProvider in TydChronosHomePage
if 'MultiProvider' in content and 'TradingController' not in content:
    # Find the MultiProvider in TydChronosHomePage
    provider_pattern = r'return MultiProvider\(\s+providers: \[([^]]+)\],'
    
    def add_trading_provider(match):
        existing_providers = match.group(1)
        # Check if ChangeNotifierProvider.value is already there
        if 'BalanceVisibilityManager' in existing_providers:
            # Add TradingController after BalanceVisibilityManager
            return 'return MultiProvider(\n      providers: [\n        ChangeNotifierProvider.value(value: _balanceManager),\n        ChangeNotifierProvider(create: (context) => TradingController()),'
        else:
            return 'return MultiProvider(\n      providers: [\n        ChangeNotifierProvider(create: (context) => TradingController()),'
    
    content = re.sub(provider_pattern, add_trading_provider, content, flags=re.DOTALL)

# Write the updated content back
with open('lib/main.dart', 'w') as file:
    file.write(content)

print("✅ Successfully updated main navigation with Automated Trading!")
