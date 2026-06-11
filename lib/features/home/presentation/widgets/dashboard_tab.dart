import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../widgets/balance_card.dart';
import '../../../../widgets/budget_gauge.dart';
import '../../../../widgets/spending_trends_chart.dart';
import '../../../../widgets/stats_grid.dart';
import '../../../../widgets/transaction_input_form.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../../dashboard/presentation/cubit/dashboard_state.dart';
import '../../../transactions/presentation/cubit/transaction_cubit.dart';
import 'error_banner.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final dashboard = state is DashboardLoaded ? state.summary : null;
        final isLoading = state is DashboardLoading || state is DashboardInitial;
        final error = state is DashboardError ? state.error : null;

        return Column(
          children: [
            const AppHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<DashboardCubit>().refreshSummary(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    spacing: 32,
                    children: [
                      BalanceCard(
                        totalBalance: dashboard?.totalBalance,
                        isLoading: isLoading,
                        onAddTransaction: () => _showAddSheet(context),
                      ),
                      BudgetGauge(
                        budgetLeft: dashboard?.budgetLeft,
                        totalIncome: dashboard?.totalIncome,
                        isLoading: isLoading,
                      ),
                      StatsGrid(
                        dailyExpense: dashboard?.dailyExpense,
                        budgetLeft: dashboard?.budgetLeft,
                        totalIncome: dashboard?.totalIncome,
                        isLoading: isLoading,
                      ),
                      SpendingTrendsChart(
                        trends: dashboard?.spendingTrends,
                        maxAmount: dashboard?.maxTrendAmount ?? 1.0,
                        isLoading: isLoading,
                      ),
                      if (error != null)
                        ErrorBanner(
                          error: error,
                          onRetry: () => context.read<DashboardCubit>().fetchSummary(),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Colors.black87 : Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<TransactionCubit>(),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1D3448) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: TransactionInputForm(
              onTransactionSaved: () {
                Navigator.pop(context);
                context.read<DashboardCubit>().fetchSummary();
              },
            ),
          ),
        );
      },
    );
  }
}
