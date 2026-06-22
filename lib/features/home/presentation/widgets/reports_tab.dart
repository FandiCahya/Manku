import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../widgets/category_breakdown.dart';
import '../../../../widgets/spending_performance_chart.dart';
import '../../../investment/presentation/pages/investment_tab.dart';
import '../../../transactions/presentation/cubit/transaction_cubit.dart';
import '../../../transactions/presentation/cubit/transaction_state.dart';
import 'error_banner.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          children: [
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: context.colors.onPrimary,
                unselectedLabelColor: context.colors.onSurfaceVariant,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Transactions'),
                  Tab(text: 'Investments'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  // Transactions Tab
                  BlocBuilder<TransactionCubit, TransactionState>(
                    builder: (context, state) {
                      final isLoading =
                          state is TransactionLoading || state is TransactionInitial;
                      final error =
                          state is TransactionError ? state.error : null;
                      final report =
                          state is TransactionLoaded ? state.report : null;

                      return RefreshIndicator(
                        onRefresh: () => context
                            .read<TransactionCubit>()
                            .fetchTransactionsAndReport(),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
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
                                  onRetry: () => context
                                      .read<TransactionCubit>()
                                      .fetchTransactionsAndReport(),
                                ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Investments Tab
                  const InvestmentTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
