import 'dart:async' show unawaited;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../cubit/investment_cubit.dart';
import '../cubit/investment_state.dart';
import '../widgets/add_investment_sheet.dart';
import '../widgets/edit_investment_sheet.dart';
import '../widgets/portfolio_summary_card.dart';
import '../widgets/investment_card.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../domain/investment_models.dart';

class InvestmentTab extends StatelessWidget {
  const InvestmentTab({super.key});

  Future<void> _openEditSheet(BuildContext context, Investment investment) async {
    final cubit = context.read<InvestmentCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: EditInvestmentSheet(investment: investment),
      ),
    );
    unawaited(cubit.loadInvestments());
    unawaited(context.read<DashboardCubit>().fetchSummary());
  }

  Future<void> _confirmDelete(BuildContext context, Investment investment) async {
    final confirmed = await AppDialogs.confirmDelete(
      context,
      title: 'Hapus Investment?',
      message: 'Yakin hapus ${investment.symbol} (${investment.name}) dari portofolio?\nData tidak bisa dipulihkan.',
    );

    if ((confirmed ?? false) && context.mounted) {
      await context.read<InvestmentCubit>().deleteInvestment(investment.id);
      if (context.mounted) {
        AppDialogs.showToast(
          context,
          message: '${investment.symbol} berhasil dihapus dari portofolio',
        );
        unawaited(context.read<DashboardCubit>().fetchSummary());
      }
    }
  }

  Future<void> _openAddSheet(BuildContext context) async {
    final cubit = context.read<InvestmentCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const AddInvestmentSheet(),
      ),
    );
    // Refresh paksa setelah sheet ditutup
    unawaited(cubit.loadInvestments());
    unawaited(context.read<DashboardCubit>().fetchSummary());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvestmentCubit, InvestmentState>(
      builder: (context, state) {
        if (state is InvestmentLoading ||
            state is InvestmentInitial ||
            state is InvestmentSubmitting ||
            state is InvestmentSubmitSuccess) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is InvestmentError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: context.colors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load investments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<InvestmentCubit>().loadInvestments();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is InvestmentLoaded) {
          if (state.investments.isEmpty) {
            return _buildEmptyState(context);
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () => context.read<InvestmentCubit>().loadInvestments(),
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    // Portfolio Summary
                    PortfolioSummaryCard(summary: state.summary),

                    // Investments List
                    ...state.investments.map((investment) {
                      return InvestmentCard(
                        investment: investment,
                        onTap: () {},
                        onEdit: () => _openEditSheet(context, investment),
                        onDelete: () => _confirmDelete(context, investment),
                      );
                    }),

                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // FAB — Tambah Investment
              Positioned(
                right: 20,
                bottom: 20,
                child: FloatingActionButton.extended(
                  onPressed: () => _openAddSheet(context),
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Tambah',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.trending_up,
                size: 64,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Investment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : context.colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai bangun portofolio investasi kamu\ndengan menambahkan crypto atau saham pertama',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _openAddSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Investment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
