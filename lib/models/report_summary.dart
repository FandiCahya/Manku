class CategoryBreakdownItem {
  final String name;
  final double amount;
  final int count;
  final double percentage; // 0.0 – 1.0

  CategoryBreakdownItem({
    required this.name,
    required this.amount,
    required this.count,
    required this.percentage,
  });

  factory CategoryBreakdownItem.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownItem(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      count: json['count'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class PerformanceMonth {
  final String month;
  final int year;
  final double amount;
  final bool isCurrent;

  PerformanceMonth({
    required this.month,
    required this.year,
    required this.amount,
    required this.isCurrent,
  });

  factory PerformanceMonth.fromJson(Map<String, dynamic> json) {
    return PerformanceMonth(
      month: json['month'] as String,
      year: json['year'] as int,
      amount: (json['amount'] as num).toDouble(),
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }
}

class ReportSummary {
  final double totalSpending;
  final List<CategoryBreakdownItem> categoryBreakdown;
  final List<PerformanceMonth> performanceSixMonths;
  final double performanceMaxAmount;

  ReportSummary({
    required this.totalSpending,
    required this.categoryBreakdown,
    required this.performanceSixMonths,
    required this.performanceMaxAmount,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    final catList = json['category_breakdown'] as List<dynamic>? ?? [];
    final perfList = json['performance_six_months'] as List<dynamic>? ?? [];
    return ReportSummary(
      totalSpending: (json['total_spending'] as num).toDouble(),
      categoryBreakdown: catList
          .map((e) => CategoryBreakdownItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      performanceSixMonths: perfList
          .map((e) => PerformanceMonth.fromJson(e as Map<String, dynamic>))
          .toList(),
      performanceMaxAmount:
          (json['performance_max_amount'] as num? ?? 1.0).toDouble(),
    );
  }
}
