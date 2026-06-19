class ApiTransaction {
  final String id;
  final String description;
  final String categoryName;
  final String categoryType; // 'income' | 'expense'
  final double amount;
  final String time; // Format HH:mm
  final String inputSource;

  ApiTransaction({
    required this.id,
    required this.description,
    required this.categoryName,
    required this.categoryType,
    required this.amount,
    required this.time,
    required this.inputSource,
  });

  bool get isIncome => categoryType.toLowerCase().trim() == 'income';

  factory ApiTransaction.fromJson(Map<String, dynamic> json) {
    // API may return type under different key names — try all variants
    final rawType = (json['category_type'] as String?)
        ?? (json['transaction_type'] as String?)
        ?? (json['type'] as String?)
        ?? 'expense';
    return ApiTransaction(
      id: (json['id'] ?? '').toString(),
      description: json['description'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? 'Lainnya',
      categoryType: rawType.toLowerCase().trim(), // normalise to lowercase
      amount: (json['amount'] as num).toDouble(),
      time: json['time'] as String? ?? '',
      inputSource: json['input_source'] as String? ?? 'manual',
    );
  }
}

class TransactionGroup {
  final String dateLabel;
  final String date;
  final List<ApiTransaction> transactions;

  TransactionGroup({
    required this.dateLabel,
    required this.date,
    required this.transactions,
  });

  factory TransactionGroup.fromJson(Map<String, dynamic> json) {
    final txList = json['transactions'] as List<dynamic>? ?? [];
    return TransactionGroup(
      dateLabel: json['date_label'] as String,
      date: json['date'] as String,
      transactions: txList
          .map((e) => ApiTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TransactionHistory {
  final int totalTransactions;
  final List<TransactionGroup> groups;

  TransactionHistory({
    required this.totalTransactions,
    required this.groups,
  });

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    final groupList = json['groups'] as List<dynamic>? ?? [];
    return TransactionHistory(
      totalTransactions: json['total_transactions'] as int? ?? 0,
      groups: groupList
          .map((e) => TransactionGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
