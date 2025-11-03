import 'package:web3dart/web3dart.dart';
import '../constants/deployment.dart';

class TydchronosContractService {
  final Web3Client _client;
  final Credentials _credentials;

  TydchronosContractService({required Web3Client client, required Credentials credentials})
      : _client = client,
        _credentials = credentials;

  // Vault contract interactions
  Future<String> getVaultVersion() async {
    try {
      final contract = await _getVaultContract();
      final version = await contract.callFunction('getVersion', []);
      return version.toString();
    } catch (e) {
      print('Error getting vault version: $e');
      return 'Unknown';
    }
  }

  Future<BigInt> getTimeBalance(EthereumAddress userAddress) async {
    try {
      final contract = await _getVaultContract();
      final balance = await contract.callFunction('balanceOf', [userAddress]);
      return balance[0] as BigInt;
    } catch (e) {
      print('Error getting time balance: $e');
      return BigInt.zero;
    }
  }

  Future<String> registerUser(String username) async {
    try {
      final contract = await _getVaultContract();
      final transaction = await contract.sendTransaction(
        'registerUser',
        [username],
        _credentials,
      );
      return transaction;
    } catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }

  // Trading bot interactions
  Future<String> getTradingBotVersion() async {
    try {
      final contract = await _getTradingContract();
      final version = await contract.callFunction('getVersion', []);
      return version.toString();
    } catch (e) {
      print('Error getting trading bot version: $e');
      return 'Unknown';
    }
  }

  Future<bool> isMockMode() async {
    try {
      final contract = await _getTradingContract();
      final isMock = await contract.callFunction('isMockMode', []);
      return isMock[0] as bool;
    } catch (e) {
      print('Error checking mock mode: $e');
      return true;
    }
  }

  // Security contract interactions
  Future<String> getSecurityVersion() async {
    try {
      final contract = await _getSecurityContract();
      final version = await contract.callFunction('getVersion', []);
      return version.toString();
    } catch (e) {
      print('Error getting security version: $e');
      return 'Unknown';
    }
  }

  Future<bool> isUserProtected(EthereumAddress userAddress) async {
    try {
      final contract = await _getSecurityContract();
      final isProtected = await contract.callFunction('isProtected', [userAddress]);
      return isProtected[0] as bool;
    } catch (e) {
      print('Error checking user protection: $e');
      return false;
    }
  }

  // Private helper methods
  Future<DeployedContract> _getVaultContract() async {
    return await _getContract(
      DeploymentConstants.tydChronosVaultAddress,
      DeploymentConstants.contractABIs['vault']!,
    );
  }

  Future<DeployedContract> _getTradingContract() async {
    return await _getContract(
      DeploymentConstants.tradingBotV3Address,
      DeploymentConstants.contractABIs['trading']!,
    );
  }

  Future<DeployedContract> _getSecurityContract() async {
    return await _getContract(
      DeploymentConstants.mevProtectionAddress,
      DeploymentConstants.contractABIs['security']!,
    );
  }

  Future<DeployedContract> _getContract(String address, List<String> abi) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(abi.join(','), 'Contract'),
      EthereumAddress.fromHex(address),
    );
    return contract;
  }

  // Get user overview
  Future<Map<String, dynamic>> getUserOverview(EthereumAddress userAddress) async {
    try {
      final [vaultVersion, timeBalance, tradingVersion, securityVersion, isProtected] = await Future.wait([
        getVaultVersion(),
        getTimeBalance(userAddress),
        getTradingBotVersion(),
        getSecurityVersion(),
        isUserProtected(userAddress),
      ]);

      return {
        'vaultVersion': vaultVersion,
        'timeBalance': timeBalance,
        'tradingVersion': tradingVersion,
        'securityVersion': securityVersion,
        'isProtected': isProtected,
        'contracts': {
          'vault': DeploymentConstants.tydChronosVaultAddress,
          'trading': DeploymentConstants.tradingBotV3Address,
          'security': DeploymentConstants.mevProtectionAddress,
        },
      };
    } catch (e) {
      print('Error getting user overview: $e');
      rethrow;
    }
  }
}
