class SavingsGoalModel {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final double remainingAmount;
  final double progressPercentage; // 0 – 100
  final String? deadline; // YYYY-MM-DD
  final int? daysRemaining; // null jika tidak ada deadline
  final bool isOverdue;
  final bool isCompleted;
  final String description;
  final String color; // hex e.g. '#4A90D9'
  final String icon;  // material icon name

  SavingsGoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.remainingAmount,
    required this.progressPercentage,
    this.deadline,
    this.daysRemaining,
    this.isOverdue = false,
    this.isCompleted = false,
    this.description = '',
    this.color = '#4A90D9',
    this.icon = 'savings',
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num).toDouble(),
      remainingAmount: (json['remaining_amount'] as num? ?? 0).toDouble(),
      progressPercentage: (json['progress_percentage'] as num? ?? 0).toDouble(),
      deadline: json['deadline'] as String?,
      daysRemaining: json['days_remaining'] as int?,
      isOverdue: json['is_overdue'] as bool? ?? false,
      isCompleted: json['is_completed'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      color: json['color'] as String? ?? '#4A90D9',
      icon: json['icon'] as String? ?? 'savings',
    );
  }

  Map<String, dynamic> toCreateJson() => {
    'name': name,
    'target_amount': targetAmount,
    'current_amount': currentAmount,
    if (deadline != null) 'deadline': deadline,
    if (description.isNotEmpty) 'description': description,
    'color': color,
    'icon': icon,
  };
}

class SavingsOverview {
  final double netBalance;
  final double totalAllocatedToGoals;
  final double disposableBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double monthlySavings;
  final int totalGoals;
  final int completedGoals;
  final List<SavingsGoalModel> goals;

  SavingsOverview({
    required this.netBalance,
    required this.totalAllocatedToGoals,
    required this.disposableBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.monthlySavings,
    required this.totalGoals,
    required this.completedGoals,
    required this.goals,
  });

  factory SavingsOverview.fromJson(Map<String, dynamic> json) {
    final goalsList = json['goals'] as List<dynamic>? ?? [];
    return SavingsOverview(
      netBalance: (json['net_balance'] as num).toDouble(),
      totalAllocatedToGoals:
          (json['total_allocated_to_goals'] as num).toDouble(),
      disposableBalance: (json['disposable_balance'] as num).toDouble(),
      monthlyIncome: (json['monthly_income'] as num).toDouble(),
      monthlyExpense: (json['monthly_expense'] as num).toDouble(),
      monthlySavings: (json['monthly_savings'] as num).toDouble(),
      totalGoals: json['total_goals'] as int? ?? 0,
      completedGoals: json['completed_goals'] as int? ?? 0,
      goals: goalsList
          .map((e) => SavingsGoalModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
