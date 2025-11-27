class WalletAccount {
  final String name;
  final String address;
  final String mnemonic;
  final String privateKey;
  final DateTime createdAt;
  double balance;
  String network;

  WalletAccount({
    required this.name,
    required this.address,
    required this.mnemonic,
    required this.privateKey,
    required this.createdAt,
    this.balance = 0.0,
    this.network = 'Ethereum',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'mnemonic': mnemonic,
      'privateKey': privateKey,
      'createdAt': createdAt.toIso8601String(),
      'balance': balance,
      'network': network,
    };
  }

  factory WalletAccount.fromJson(Map<String, dynamic> json) {
    return WalletAccount(
      name: json['name'],
      address: json['address'],
      mnemonic: json['mnemonic'],
      privateKey: json['privateKey'],
      createdAt: DateTime.parse(json['createdAt']),
      balance: json['balance'] ?? 0.0,
      network: json['network'] ?? 'Ethereum',
    );
  }

  String getShortAddress() {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  String getMnemonicPreview() {
    final words = mnemonic.split(' ');
    if (words.length <= 4) return mnemonic;
    return '${words.sublist(0, 4).join(' ')} ...';
  }
}
