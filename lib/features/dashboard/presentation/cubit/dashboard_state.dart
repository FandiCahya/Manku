import 'package:equatable/equatable.dart';
import '../../../../models/dashboard_summary.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;
  const DashboardLoaded({required this.summary});

  @override
  List<Object?> get props => [summary];
}

class DashboardError extends DashboardState {
  final String error;
  const DashboardError({required this.error});

  @override
  List<Object?> get props => [error];
}
