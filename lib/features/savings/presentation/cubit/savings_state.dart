import 'package:equatable/equatable.dart';
import '../../domain/budget_models.dart';
import '../../domain/financial_advice.dart';

abstract class SavingsState extends Equatable {
  const SavingsState();

  @override
  List<Object?> get props => [];
}

class SavingsInitial extends SavingsState {}

class SavingsLoading extends SavingsState {}

class SavingsLoaded extends SavingsState {
  final BudgetGoalsResponse budgetGoals;
  final FinancialAdvice financialAdvice;

  const SavingsLoaded({
    required this.budgetGoals,
    required this.financialAdvice,
  });

  @override
  List<Object?> get props => [budgetGoals, financialAdvice];
}

class SavingsSubmitting extends SavingsState {}

class SavingsSuccess extends SavingsState {
  final String message;
  const SavingsSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class SavingsError extends SavingsState {
  final String error;
  const SavingsError({required this.error});

  @override
  List<Object?> get props => [error];
}
