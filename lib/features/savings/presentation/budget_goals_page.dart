import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_manage/core/constants/colors.dart';
import 'package:my_manage/features/savings/domain/budget_models.dart';
import 'package:my_manage/features/savings/presentation/cubit/savings_cubit.dart';
import 'package:my_manage/features/savings/presentation/cubit/savings_state.dart';
import 'package:my_manage/features/savings/presentation/widgets/budget_card.dart';
import 'package:my_manage/features/savings/presentation/widgets/budget_header_sliver.dart';
import 'package:my_manage/features/savings/presentation/widgets/budget_summary_card.dart';
import 'package:my_manage/features/savings/presentation/widgets/budget_warnings_row.dart';
import 'package:my_manage/features/savings/presentation/widgets/set_budget_sheet.dart';

/// Feature page for Budget Goals.
/// Uses [SavingsCubit] (provided by [MultiBlocProvider] in main.dart) for all
/// state — no direct API / http calls inside the page.
class BudgetGoalsPage extends StatelessWidget {
  const BudgetGoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SavingsCubit, SavingsState>(
      listener: (context, state) {
        if (state is SavingsSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green.shade600,
              ),
            );
        }
        if (state is SavingsError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red.shade700,
              ),
            );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.colors.background,
          body: _BudgetGoalsBody(state: state),
          floatingActionButton: state is SavingsLoaded
              ? FloatingActionButton.extended(
                  onPressed: () => _openSetBudgetSheet(
                    context,
                    monthLabel: state.budgetGoals.month,
                  ),
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Set Budget',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  elevation: 4,
                )
              : null,
        );
      },
    );
  }

  void _openSetBudgetSheet(
    BuildContext context, {
    BudgetGoalItem? existing,
    String? monthLabel,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<SavingsCubit>(),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1D3448) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SetBudgetSheet(
            existing: existing,
            monthLabel: monthLabel,
          ),
        ),
      ),
    );
  }
}

// ── Body dispatcher ──────────────────────────────────────────────────────────

class _BudgetGoalsBody extends StatelessWidget {
  const _BudgetGoalsBody({required this.state});

  final SavingsState state;

  @override
  Widget build(BuildContext context) {
    if (state is SavingsLoading || state is SavingsInitial) {
      return const _LoadingView();
    }
    if (state is SavingsSubmitting) {
      return const _LoadingView(label: 'Menyimpan…');
    }
    if (state is SavingsError) {
      return _ErrorView(error: (state as SavingsError).error);
    }
    if (state is SavingsLoaded) {
      return _LoadedView(data: (state as SavingsLoaded).budgetGoals);
    }
    // SavingsSuccess — keep showing loaded data while snackbar is visible
    return const _LoadingView();
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView({this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(context.colors.primary),
          ),
          if (label != null) ...[
            const SizedBox(height: 16),
            Text(
              label!,
              style: TextStyle(
                color: context.colors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<SavingsCubit>().fetchSavingsData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loaded ────────────────────────────────────────────────────────────────────

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.data});

  final BudgetGoalsResponse data;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<SavingsCubit>().fetchSavingsData(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          BudgetHeaderSliver(monthLabel: data.month),
          SliverToBoxAdapter(
            child: BudgetSummaryCard(summary: data.summary),
          ),
          SliverToBoxAdapter(
            child: BudgetWarningsRow(summary: data.summary),
          ),
          SliverToBoxAdapter(
            child: _BudgetListHeader(count: data.budgets.length),
          ),
          if (data.budgets.isEmpty)
            const SliverToBoxAdapter(child: _EmptyBudgetView())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 6),
                  child: _budgetCard(ctx, data.budgets[i], data.month),
                ),
                childCount: data.budgets.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _budgetCard(
    BuildContext context,
    BudgetGoalItem item,
    String monthLabel,
  ) {
    return BudgetCard(
      item: item,
      onEdit: () => _openSetBudgetSheet(
        context,
        existing: item,
        monthLabel: monthLabel,
      ),
      onDelete: () => _confirmDelete(context, item),
    );
  }

  void _openSetBudgetSheet(
    BuildContext context, {
    BudgetGoalItem? existing,
    String? monthLabel,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<SavingsCubit>(),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1D3448) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SetBudgetSheet(
            existing: existing,
            monthLabel: monthLabel,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    BudgetGoalItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Budget?'),
        content: Text(
          'Budget untuk "${item.categoryName}" akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && context.mounted) {
      context.read<SavingsCubit>().deleteCategoryBudget(item.id);
    }
  }
}

// ── Budget list header ────────────────────────────────────────────────────────

class _BudgetListHeader extends StatelessWidget {
  const _BudgetListHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        children: [
          Text(
            'Budget per Kategori',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: context.colors.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count kategori',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.colors.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyBudgetView extends StatelessWidget {
  const _EmptyBudgetView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: context.colors.outlineVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Budget',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan budget per kategori untuk\nmemantau pengeluaranmu!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
