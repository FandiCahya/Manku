class SpendingTrendDay {
  final String day;
  final String date;
  final double amount;

  SpendingTrendDay({
    required this.day,
    required this.date,
    required this.amount,
  });

  factory SpendingTrendDay.fromJson(Map<String, dynamic> json) {
    return SpendingTrendDay(
      day: json['day'] as String,
      date: json['date'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}

class DashboardSummary {
  final double totalBalance;
  final double dailyExpense;
  final double totalIncome;
  final double totalExpense;
  final List<SpendingTrendDay> spendingTrends;
  
  // Kept for backward compatibility
  final double? budgetLeft;

  DashboardSummary({
    required this.totalBalance,
    required this.dailyExpense,
    required this.totalIncome,
    required this.totalExpense,
    required this.spendingTrends,
    this.budgetLeft,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final trendsJson = json['spending_trends'] as List<dynamic>? ?? [];
    
    // Support both new format (total_expense) and old format (budget_left)
    final totalIncome = (json['total_income'] as num? ?? 0).toDouble();
    final budgetLeft = (json['budget_left'] as num? ?? 0).toDouble();
    final totalExpense = (json['total_expense'] as num? ?? (totalIncome - budgetLeft)).toDouble();
    
    return DashboardSummary(
      totalBalance: (json['total_balance'] as num).toDouble(),
      dailyExpense: (json['daily_expense'] as num).toDouble(),
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      spendingTrends: trendsJson
          .map((e) => SpendingTrendDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      budgetLeft: json['budget_left'] != null ? (json['budget_left'] as num).toDouble() : null,
    );
  }

  /// Nilai tertinggi dalam spending trends (untuk normalisasi bar chart)
  double get maxTrendAmount {
    if (spendingTrends.isEmpty) return 1.0;
    final max = spendingTrends
        .map((e) => e.amount)
        .reduce((a, b) => a > b ? a : b);
    return max == 0 ? 1.0 : max;
  }
  
  /// Monthly balance = totalIncome - totalExpense
  double get monthlyBalance => totalIncome - totalExpense;
}
