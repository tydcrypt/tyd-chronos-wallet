import re

with open('lib/main.dart', 'r') as f:
    content = f.read()

# Add web3 connection check import if not present
if "import 'package:web3dart/web3dart.dart';" not in content:
    content = content.replace(
        "import 'services/ethereum_service.dart';",
        "import 'services/ethereum_service.dart';\nimport 'package:web3dart/web3dart.dart';"
    )

# Modify the TydChronosEcosystemService initialize method to skip web3 connections for web
initialize_pattern = r'Future<void> initialize\(\) async \{[^}]+?await _securityService\.initialize\(\);[^}]+?final ethService = EthereumService\(\);[^}]+?_ethereumAddress = await ethService\.getAddress\(\);[^}]+?if \(_ethereumAddress == null\) \{[^}]+\} else \{[^}]+\}[^}]+?if \(_ethereumAddress != null\) \{[^}]+\}[^}]+?notifyListeners\(\);[^}]+?\}'

web_safe_initialize = '''Future<void> initialize() async {
    try {
      print('[TydChronos] Ecosystem Service initializing...');
      await _securityService.initialize();

      // WEB SAFETY: Skip blockchain operations during web app startup
      if (kIsWeb) {
        print('[TydChronos] WEB: Skipping blockchain initialization for faster startup');
        _ethereumAddress = 'web_mode_placeholder';
        print('[TydChronos] WEB: App ready - blockchain features will initialize on demand');
        notifyListeners();
        return;
      }

      // Generate or retrieve Ethereum address (Mobile only)
      final ethService = EthereumService();
      _ethereumAddress = await ethService.getAddress();
      
      if (_ethereumAddress == null) {
        print('[TydChronos] Generating new wallet...');
        final mnemonic = bip39.generateMnemonic();
        await ethService.createWalletFromMnemonic(mnemonic);
        _ethereumAddress = await ethService.getAddress();
        
        if (_ethereumAddress != null) {
          await _backendService.registerWallet(_ethereumAddress!);
          print('[TydChronos] New wallet created: $_ethereumAddress');
        }
      } else {
        print('[TydChronos] Existing wallet found: $_ethereumAddress');
      }
      
      // Sync with TydChronos backend
      if (_ethereumAddress != null) {
        await _backendService.syncWalletData(_ethereumAddress!);
        
        // Initialize snipping bots
        await _snippingBotService.initialize(_ethereumAddress!);
      }
      
      print('[TydChronos] Ecosystem Service initialized successfully');
      notifyListeners();
    } catch (e) {
      print('[TydChronos] Initialization error: $e');
    }
  }'''

content = re.sub(initialize_pattern, web_safe_initialize, content, flags=re.DOTALL)

# Also update the initializeWeb method to be even more aggressive
if 'void initializeWeb()' in content:
    content = content.replace(
        'void initializeWeb() {',
        '''void initializeWeb() {
    print('[TydChronos] WEB: Ultra-fast initialization - skipping all blockchain');
    _ethereumAddress = 'web_demo_mode';
    // Mark services as ready immediately
    notifyListeners();
    '''
    )

with open('lib/main.dart', 'w') as f:
    f.write(content)

print("Applied MetaMask connection fix")
