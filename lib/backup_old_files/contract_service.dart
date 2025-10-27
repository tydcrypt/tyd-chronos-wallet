import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class ContractService {
  late Web3Client client;
  late EthereumAddress contractAddress;
  late DeployableContract contract;
  
  // Initialize with Ethereum node URL
  ContractService(String rpcUrl) {
    client = Web3Client(rpcUrl, Client());
  }

  // Load contract ABI and address
  Future<void> loadContract(
    String contractAddressHex,
    String contractAbi,
  ) async {
    contractAddress = EthereumAddress.fromHex(contractAddressHex);
    contract = DeployableContract(
      ContractAbi.fromJson(contractAbi, 'YourContract'),
      contractAddress,
    );
  }

  // Call view function (read from contract)
  Future<List<dynamic>> callFunction(
    String functionName,
    List<dynamic> params, {
    EthereumAddress? from,
  }) async {
    final function = contract.function(functionName);
    final result = await client.call(
      contract: contract,
      function: function,
      params: params,
      sender: from,
    );
    return result;
  }

  // Send transaction (write to contract)
  Future<String> sendTransaction({
    required EthPrivateKey credentials,
    required String functionName,
    required List<dynamic> params,
    required BigInt gasPrice,
    required BigInt gasLimit,
  }) async {
    final function = contract.function(functionName);
    
    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: params,
      gasPrice: gasPrice,
      gasLimit: gasLimit,
    );

    final txHash = await client.sendTransaction(
      credentials,
      transaction,
      chainId: 1, // Mainnet - change for testnets
    );

    return txHash;
  }

  // Get transaction receipt
  Future<TransactionReceipt?> getTransactionReceipt(String txHash) async {
    return await client.getTransactionReceipt(txHash);
  }

  // Get current gas price
  Future<BigInt> getGasPrice() async {
    return await client.getGasPrice();
  }

  // Get account balance
  Future<BigInt> getBalance(EthereumAddress address) async {
    return await client.getBalance(address);
  }

  // Get transaction count (nonce)
  Future<int> getTransactionCount(EthereumAddress address) async {
    return await client.getTransactionCount(address);
  }

  // Estimate gas for transaction
  Future<BigInt> estimateGas({
    required String functionName,
    required List<dynamic> params,
    EthereumAddress? from,
  }) async {
    final function = contract.function(functionName);
    
    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: params,
      sender: from,
    );

    return await client.estimateGas(transaction: transaction);
  }
}
