// Transaction Service
// Manages transaction history and operations

import 'dart:convert';

class Transaction {
  final String hash;
  final String from;
  final String to;
  final double amount;
  final DateTime timestamp;
  final String status;
  
  Transaction({
    required this.hash,
    required this.from,
    required this.to,
    required this.amount,
    required this.timestamp,
    required this.status,
  });
}

class TransactionService {
  final List<Transaction> _transactions = [];
  
  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
  }
  
  List<Transaction> getTransactionHistory() {
    return List.from(_transactions);
  }
  
  List<Transaction> getTransactionsByAddress(String address) {
    return _transactions.where((tx) => tx.from == address || tx.to == address).toList();
  }
}
