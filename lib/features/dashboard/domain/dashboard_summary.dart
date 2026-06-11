// Re-export from the original model location (kept for compatibility inside feature)
// Domain models for the Dashboard feature.

class SpendingTrendDay {
  final String day;
  final String date;
  final double amount;

  SpendingTrendDay({required this.day, required this.date, required this.amount});

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
  final double budgetLeft;
  final double totalIncome;
  final List<SpendingTrendDay> spendingTrends;

  DashboardSummary({
    required this.totalBalance,
    required this.dailyExpense,
    required this.budgetLeft,
    required this.totalIncome,
    required this.spendingTrends,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final trendsJson = json['spending_trends'] as List<dynamic>? ?? [];
    return DashboardSummary(
      totalBalance: (json['total_balance'] as num).toDouble(),
      dailyExpense: (json['daily_expense'] as num).toDouble(),
      budgetLeft: (json['budget_left'] as num).toDouble(),
      totalIncome: (json['total_income'] as num).toDouble(),
      spendingTrends: trendsJson
          .map((e) => SpendingTrendDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  double get maxTrendAmount {
    if (spendingTrends.isEmpty) return 1.0;
    final max = spendingTrends.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    return max == 0 ? 1.0 : max;
  }
}
