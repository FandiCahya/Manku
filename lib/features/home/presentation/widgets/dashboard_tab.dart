import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../../../widgets/balance_card.dart';
import '../../../../widgets/monthly_balance_gauge.dart';
import '../../../../widgets/goals_progress_card.dart';
import '../../../../widgets/spending_trends_chart.dart';
import '../../../../widgets/stats_grid.dart';
import 'add_transaction_tab.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../../dashboard/presentation/cubit/dashboard_state.dart';
import '../../../transactions/presentation/cubit/transaction_cubit.dart';
import '../../../savings/presentation/cubit/savings_cubit.dart';
import 'error_banner.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Initial fetch
    _refreshData();
  }

  Future<void> _refreshData() async {
    await Future.wait([
      context.read<DashboardCubit>().refreshSummary(),
      context.read<SavingsCubit>().fetchSavingsData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
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
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    spacing: 32,
                    children: [
                      FadeInDown(
                        delay: const Duration(milliseconds: 100),
                        child: BalanceCard(
                          totalBalance: dashboard?.totalBalance,
                          isLoading: isLoading,
                          onAddTransaction: () => _showAddSheet(context),
                        ),
                      ),
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: MonthlyBalanceGauge(
                          totalIncome: dashboard?.totalIncome,
                          totalExpense: dashboard?.totalExpense,
                          isLoading: isLoading,
                        ),
                      ),
                      ScaleIn(
                        delay: const Duration(milliseconds: 300),
                        child: GoalsProgressCard(
                          isLoading: isLoading,
                          onTap: () {
                            // Navigate to goals page (profile tab 2)
                            DefaultTabController.of(context).animateTo(3); // Profile tab
                          },
                        ),
                      ),
                      SlideInLeft(
                        delay: const Duration(milliseconds: 400),
                        child: StatsGrid(
                          dailyExpense: dashboard?.dailyExpense,
                          totalExpense: dashboard?.totalExpense,
                          monthlyBalance: dashboard?.monthlyBalance,
                          isLoading: isLoading,
                        ),
                      ),
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: SpendingTrendsChart(
                          trends: dashboard?.spendingTrends,
                          maxAmount: dashboard?.maxTrendAmount ?? 1.0,
                          isLoading: isLoading,
                        ),
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
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Colors.black87 : Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<TransactionCubit>(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1D3448) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: AddTransactionTab(
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
