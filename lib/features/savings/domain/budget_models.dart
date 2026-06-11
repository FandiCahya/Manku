// Domain models for the Budget/Goals feature.

enum BudgetWarningLevel { safe, warning, critical, exceeded }

extension BudgetWarningLevelExt on BudgetWarningLevel {
  static BudgetWarningLevel fromString(String s) {
    switch (s) {
      case 'warning':  return BudgetWarningLevel.warning;
      case 'critical': return BudgetWarningLevel.critical;
      case 'exceeded': return BudgetWarningLevel.exceeded;
      default:         return BudgetWarningLevel.safe;
    }
  }

  String get label {
    switch (this) {
      case BudgetWarningLevel.safe:     return 'Aman';
      case BudgetWarningLevel.warning:  return 'Mendekati Batas';
      case BudgetWarningLevel.critical: return 'Hampir Habis';
      case BudgetWarningLevel.exceeded: return 'Melewati Batas!';
    }
  }
}

class BudgetGoalItem {
  final String id;
  final String categoryId;
  final String categoryName;
  final String categoryType;
  final double budgetAmount;
  final double spentAmount;
  final double remaining;
  final double percentageUsed;
  final BudgetWarningLevel warningLevel;
  final String monthYear;

  BudgetGoalItem({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.categoryType,
    required this.budgetAmount,
    required this.spentAmount,
    required this.remaining,
    required this.percentageUsed,
    required this.warningLevel,
    required this.monthYear,
  });

  factory BudgetGoalItem.fromJson(Map<String, dynamic> json) {
    return BudgetGoalItem(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] as String,
      categoryType: json['category_type'] as String? ?? 'expense',
      budgetAmount: (json['budget_amount'] as num).toDouble(),
      spentAmount: (json['spent_amount'] as num).toDouble(),
      remaining: (json['remaining'] as num).toDouble(),
      percentageUsed: (json['percentage_used'] as num).toDouble(),
      warningLevel: BudgetWarningLevelExt.fromString(
          json['warning_level'] as String? ?? 'safe'),
      monthYear: json['month_year'] as String,
    );
  }
}

class BudgetSummary {
  final double totalBudget;
  final double totalSpent;
  final double totalRemaining;
  final double percentageUsed;
  final BudgetWarningLevel warningLevel;
  final int exceededCount;
  final int warningCount;

  BudgetSummary({
    required this.totalBudget,
    required this.totalSpent,
    required this.totalRemaining,
    required this.percentageUsed,
    required this.warningLevel,
    required this.exceededCount,
    required this.warningCount,
  });

  factory BudgetSummary.fromJson(Map<String, dynamic> json) {
    return BudgetSummary(
      totalBudget: (json['total_budget'] as num).toDouble(),
      totalSpent: (json['total_spent'] as num).toDouble(),
      totalRemaining: (json['total_remaining'] as num).toDouble(),
      percentageUsed: (json['percentage_used'] as num).toDouble(),
      warningLevel: BudgetWarningLevelExt.fromString(
          json['warning_level'] as String? ?? 'safe'),
      exceededCount: json['exceeded_count'] as int? ?? 0,
      warningCount: json['warning_count'] as int? ?? 0,
    );
  }
}

class BudgetGoalsResponse {
  final String month;
  final BudgetSummary summary;
  final List<BudgetGoalItem> budgets;

  BudgetGoalsResponse({
    required this.month,
    required this.summary,
    required this.budgets,
  });

  factory BudgetGoalsResponse.fromJson(Map<String, dynamic> json) {
    final budgetList = json['budgets'] as List<dynamic>? ?? [];
    return BudgetGoalsResponse(
      month: json['month'] as String,
      summary: BudgetSummary.fromJson(
          json['summary'] as Map<String, dynamic>),
      budgets: budgetList
          .map((e) => BudgetGoalItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
