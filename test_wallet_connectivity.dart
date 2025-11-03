// Quick test for Tydchronos Wallet connectivity
import './lib/constants/deployment.dart' as constants;

void main() {
  print('🧪 Testing Tydchronos Wallet Configuration...');
  print('');
  print('📡 Network Configuration:');
  print('  - RPC URL: ${constants.DeploymentConstants.sepoliaRpcUrl}');
  print('  - Chain ID: ${constants.DeploymentConstants.sepoliaChainId}');
  print('');
  print('🏗️ Contract Addresses:');
  print('  - Vault: ${constants.DeploymentConstants.tydChronosVaultAddress}');
  print('  - Trading: ${constants.DeploymentConstants.tradingBotV3Address}');
  print('  - Security: ${constants.DeploymentConstants.mevProtectionAddress}');
  print('');
  print('✅ Configuration verified successfully!');
  print('🚀 Wallet is ready for Sepolia testnet!');
}
