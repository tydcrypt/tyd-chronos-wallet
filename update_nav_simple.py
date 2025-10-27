with open('lib/main.dart', 'r') as f:
    content = f.read()

# Replace the navigation items
old_nav = """items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'OVERVIEW'),
              BottomNavigationBarItem(icon: Icon(Icons.currency_bitcoin), label: 'CRYPTO'),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'E-WALLET'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'SETTINGS'),
            ],"""

new_nav = """items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'OVERVIEW'),
              BottomNavigationBarItem(icon: Icon(Icons.currency_bitcoin), label: 'CRYPTO'),
              BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_motion), label: 'TRADING'),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'E-WALLET'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'SETTINGS'),
            ],"""

if old_nav in content:
    content = content.replace(old_nav, new_nav)
    print("Navigation updated successfully")
else:
    print("Old navigation pattern not found, trying alternative...")
    # Try alternative pattern
    alt_old_nav = """items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'OVERVIEW'),
              BottomNavigationBarItem(icon: Icon(Icons.currency_bitcoin), label: 'CRYPTO'),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'E-WALLET'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'SETTINGS'),
            ]"""
    alt_new_nav = """items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'OVERVIEW'),
              BottomNavigationBarItem(icon: Icon(Icons.currency_bitcoin), label: 'CRYPTO'),
              BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_motion), label: 'TRADING'),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'E-WALLET'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'SETTINGS'),
            ]"""
    if alt_old_nav in content:
        content = content.replace(alt_old_nav, alt_new_nav)
        print("Navigation updated successfully (alternative pattern)")
    else:
        print("Could not find navigation pattern to update")

with open('lib/main.dart', 'w') as f:
    f.write(content)
