import 'package:equatable/equatable.dart';
import '../../../../models/transaction_api.dart';
import '../../../../models/report_summary.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final TransactionHistory history;
  final ReportSummary report;
  final List<TransactionGroup> filteredGroups;
  final String searchQuery;

  const TransactionLoaded({
    required this.history,
    required this.report,
    required this.filteredGroups,
    this.searchQuery = '',
  });

  TransactionLoaded copyWith({
    TransactionHistory? history,
    ReportSummary? report,
    List<TransactionGroup>? filteredGroups,
    String? searchQuery,
  }) {
    return TransactionLoaded(
      history: history ?? this.history,
      report: report ?? this.report,
      filteredGroups: filteredGroups ?? this.filteredGroups,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [history, report, filteredGroups, searchQuery];
}

class TransactionSubmitting extends TransactionState {}

class TransactionSubmitSuccess extends TransactionState {
  final String message;
  const TransactionSubmitSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class TransactionError extends TransactionState {
  final String error;
  const TransactionError({required this.error});

  @override
  List<Object?> get props => [error];
}
