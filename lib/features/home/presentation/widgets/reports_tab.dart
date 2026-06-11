import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../widgets/category_breakdown.dart';
import '../../../../widgets/spending_performance_chart.dart';
import '../../../transactions/presentation/cubit/transaction_cubit.dart';
import '../../../transactions/presentation/cubit/transaction_state.dart';
import 'error_banner.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        final isLoading = state is TransactionLoading || state is TransactionInitial;
        final error = state is TransactionError ? state.error : null;
        final report = state is TransactionLoaded ? state.report : null;

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () => context.read<TransactionCubit>().fetchTransactionsAndReport(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                spacing: 24,
                children: [
                  SpendingPerformanceChart(
                    report: report,
                    isLoading: isLoading,
                  ),
                  CategoryBreakdown(
                    categories: report?.categoryBreakdown,
                    isLoading: isLoading,
                  ),
                  if (error != null)
                    ErrorBanner(
                      error: error,
                      onRetry: () => context.read<TransactionCubit>().fetchTransactionsAndReport(),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
