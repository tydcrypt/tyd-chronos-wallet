class DeploymentConstants {
  static const String deployerAddress = '0x4350e7336D92ac23f23C83F3d594318EA935Bd79D';
  static const String sepoliaRpcUrl = 'https://sepolia.infura.io/v3/9f2f1fa9318c4ebe811857ef931d5a9d';
  static const int sepoliaChainId = 11155111;

  // ACTUAL CONTRACT ADDRESSES FROM SEPOLIA DEPLOYMENT
  static const String tydChronosVaultAddress = '0xC0d3d54b124fD805dadACd6a32AD3109168976D2';
  static const String mevProtectionAddress = '0xD4E948f023911d9916749eB543867Fe93AE31492';
  static const String multiDexRouterAddress = '0x121102C24A339424ca204f87390EB4f8EfFe5582';
  static const String tradingBotV3Address = '0x121102C24A339424ca204f87390EB4f8EfFe5582';

  // Contract ABI snippets for common functions
  static const Map<String, dynamic> contractABIs = {
    'vault': [
      'function getVersion() view returns (string)',
      'function balanceOf(address) view returns (uint256)',
      'function registerUser(string memory username)',
      'function deposit() payable',
    ],
    'trading': [
      'function getVersion() view returns (string)',
      'function isMockMode() view returns (bool)',
      'function getBalance() view returns (uint256)',
    ],
    'security': [
      'function getVersion() view returns (string)',
      'function isProtected(address user) view returns (bool)',
      'function enableProtection()',
    ],
  };

  // Network configuration
  static const Map<String, dynamic> networkConfig = {
    'sepolia': {
      'chainId': sepoliaChainId,
      'rpcUrl': sepoliaRpcUrl,
      'name': 'Sepolia Testnet',
      'currency': 'ETH',
      'explorer': 'https://sepolia.etherscan.io',
    },
  };
}
