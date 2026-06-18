// Domain models for the Savings Goals feature.

enum GoalPriority { high, medium, low }

extension GoalPriorityExt on GoalPriority {
  static GoalPriority fromString(String s) {
    switch (s) {
      case 'high':   return GoalPriority.high;
      case 'medium': return GoalPriority.medium;
      case 'low':    return GoalPriority.low;
      default:       return GoalPriority.medium;
    }
  }

  String get label {
    switch (this) {
      case GoalPriority.high:   return 'Tinggi';
      case GoalPriority.medium: return 'Sedang';
      case GoalPriority.low:    return 'Rendah';
    }
  }
  
  String get value {
    switch (this) {
      case GoalPriority.high:   return 'high';
      case GoalPriority.medium: return 'medium';
      case GoalPriority.low:    return 'low';
    }
  }
}

enum GoalStatus { in_progress, completed, paused }

extension GoalStatusExt on GoalStatus {
  static GoalStatus fromString(String s) {
    switch (s) {
      case 'completed': return GoalStatus.completed;
      case 'paused':    return GoalStatus.paused;
      default:          return GoalStatus.in_progress;
    }
  }

  String get label {
    switch (this) {
      case GoalStatus.in_progress: return 'Berjalan';
      case GoalStatus.completed:   return 'Tercapai';
      case GoalStatus.paused:      return 'Dijeda';
    }
  }
}

class BudgetGoalItem {
  final String id;
  final String categoryId;
  final String categoryName;
  final String categoryType;
  final double budgetAmount;      // Now: target_amount
  final double spentAmount;       // Now: current_amount (saved)
  final double remaining;
  final double percentageUsed;    // Now: percentageAchieved
  final BudgetWarningLevel warningLevel;
  final String monthYear;         // Now: target_date
  final String? goalIcon;
  final GoalPriority? priority;
  final GoalStatus? status;
  final String? notes;
  final int? daysLeft;

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
    this.goalIcon,
    this.priority,
    this.status,
    this.notes,
    this.daysLeft,
  });

  factory BudgetGoalItem.fromJson(Map<String, dynamic> json) {
    return BudgetGoalItem(
      id: json['id'] as String,
      categoryId: json['category_id'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? json['goal_name'] as String,
      categoryType: json['category_type'] as String? ?? 'savings',
      budgetAmount: (json['budget_amount'] as num? ?? json['target_amount'] as num).toDouble(),
      spentAmount: (json['spent_amount'] as num? ?? json['current_amount'] as num).toDouble(),
      remaining: (json['remaining'] as num).toDouble(),
      percentageUsed: (json['percentage_used'] as num? ?? json['percentage_achieved'] as num? ?? 0).toDouble(),
      warningLevel: BudgetWarningLevelExt.fromString(
          json['warning_level'] as String? ?? 'safe'),
      monthYear: json['month_year'] as String? ?? json['target_date'] as String? ?? '',
      goalIcon: json['goal_icon'] as String?,
      priority: json['priority'] != null 
          ? GoalPriorityExt.fromString(json['priority'] as String)
          : null,
      status: json['status'] != null
          ? GoalStatusExt.fromString(json['status'] as String)
          : null,
      notes: json['notes'] as String?,
      daysLeft: json['days_left'] as int?,
    );
  }
}

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
      case BudgetWarningLevel.warning:  return 'Mendekati Target';
      case BudgetWarningLevel.critical: return 'Hampir Tercapai';
      case BudgetWarningLevel.exceeded: return 'Target Tercapai!';
    }
  }
}

class BudgetSummary {
  final double totalBudget;      // Now: total_target
  final double totalSpent;       // Now: total_saved
  final double totalRemaining;
  final double percentageUsed;   // Now: percentageAchieved
  final BudgetWarningLevel warningLevel;
  final int exceededCount;       // Now: completedCount
  final int warningCount;        // Now: inProgressCount

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
      totalBudget: (json['total_budget'] as num? ?? json['total_target'] as num? ?? 0).toDouble(),
      totalSpent: (json['total_spent'] as num? ?? json['total_saved'] as num? ?? 0).toDouble(),
      totalRemaining: (json['total_remaining'] as num).toDouble(),
      percentageUsed: (json['percentage_used'] as num? ?? json['percentage_achieved'] as num? ?? 0).toDouble(),
      warningLevel: BudgetWarningLevelExt.fromString(
          json['warning_level'] as String? ?? 'safe'),
      exceededCount: json['exceeded_count'] as int? ?? json['completed_count'] as int? ?? 0,
      warningCount: json['warning_count'] as int? ?? json['in_progress_count'] as int? ?? 0,
    );
  }
}

class BudgetGoalsResponse {
  final String month;  // Now: summary_label (e.g., "Tujuan Keuangan")
  final BudgetSummary summary;
  final List<BudgetGoalItem> budgets;  // Now: goals

  BudgetGoalsResponse({
    required this.month,
    required this.summary,
    required this.budgets,
  });

  factory BudgetGoalsResponse.fromJson(Map<String, dynamic> json) {
    final budgetList = json['budgets'] as List<dynamic>? ?? json['goals'] as List<dynamic>? ?? [];
    return BudgetGoalsResponse(
      month: json['month'] as String? ?? json['summary_label'] as String? ?? 'Tujuan Keuangan',
      summary: BudgetSummary.fromJson(
          json['summary'] as Map<String, dynamic>),
      budgets: budgetList
          .map((e) => BudgetGoalItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
