import 'dart:async' show unawaited;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../features/savings/domain/budget_models.dart';
import '../../../savings/presentation/cubit/savings_cubit.dart';
import '../../../savings/presentation/cubit/savings_state.dart';
import 'financial_advice_card.dart';

class CategoryBudgetTab extends StatelessWidget {
  const CategoryBudgetTab({super.key});

  static String fmtCurrency(double v) {
    final neg = v < 0;
    final parts = v.abs().toStringAsFixed(0).split('');
    final buf = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) {
        buf.write('.');
      }
      buf.write(parts[i]);
    }
    return '${neg ? '-' : ''}Rp $buf';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavingsCubit, SavingsState>(
      builder: (context, state) {
        if (state is SavingsLoading || state is SavingsInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SavingsError) {
          return _FinancialErrorWidget(
            error: state.error,
            onRetry: () => context.read<SavingsCubit>().fetchSavingsData(),
          );
        }

        final savingsState = context.read<SavingsCubit>().state;
        final bd = savingsState is SavingsLoaded ? savingsState.budgetGoals : null;
        final adviceData = savingsState is SavingsLoaded ? savingsState.financialAdvice : null;

        if (bd == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final summary = bd.summary;

        return RefreshIndicator(
          onRefresh: () => context.read<SavingsCubit>().fetchSavingsData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BudgetSummaryCard(summary: summary, month: bd.month),
                const SizedBox(height: 16),
                _buildWarningChipsRow(summary),
                FinancialAdviceCard(adviceData: adviceData),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Per Kategori',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showSetBudgetDialog(context, bd),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Set Budget',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: context.colors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (bd.budgets.isEmpty)
                  const _FinancialEmptyState(
                    title: 'Belum ada budget',
                    sub: 'Tap "Set Budget" untuk menambah budget per kategori.',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ...bd.budgets.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _BudgetCardItem(bd: bd, item: item),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWarningChipsRow(BudgetSummary summary) {
    if (summary.exceededCount > 0 || summary.warningCount > 0) {
      return Row(
        children: [
          if (summary.exceededCount > 0)
            Expanded(
              child: _FinancialWarningChip(
                text: '${summary.exceededCount} melewati batas',
                icon: Icons.cancel_outlined,
                fgColor: Colors.red.shade600,
                bgColor: Colors.red.shade50,
              ),
            ),
          if (summary.exceededCount > 0 && summary.warningCount > 0)
            const SizedBox(width: 10),
          if (summary.warningCount > 0)
            Expanded(
              child: _FinancialWarningChip(
                text: '${summary.warningCount} mendekati batas',
                icon: Icons.warning_amber_outlined,
                fgColor: Colors.orange.shade700,
                bgColor: Colors.orange.shade50,
              ),
            ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 16),
          const SizedBox(width: 8),
          Text(
            'Semua budget aman! 🎉',
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  static void _showSetBudgetDialog(
    BuildContext context,
    BudgetGoalsResponse budgetData, {
    BudgetGoalItem? existing,
  }) {
    final nameCtrl = TextEditingController(text: existing?.categoryName ?? '');
    final amountCtrl = TextEditingController(
      text: existing != null ? existing.budgetAmount.toStringAsFixed(0) : '',
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SheetWrapper(
        title: existing != null ? 'Edit Budget' : 'Set Budget Baru',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogField(
              controller: nameCtrl,
              hint: 'Nama Kategori',
              icon: Icons.category_outlined,
              enabled: existing == null,
            ),
            const SizedBox(height: 12),
            _DialogField(
              controller: amountCtrl,
              hint: 'Jumlah Budget (Rp)',
              icon: Icons.account_balance_wallet_outlined,
              type: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: context.colors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Budget berlaku untuk bulan ${budgetData.month}',
                    style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _DialogButton(
              label: existing != null ? 'Update Budget' : 'Set Budget',
              color: context.colors.secondary,
              onTap: () {
                final name = nameCtrl.text.trim();
                final amount = double.tryParse(
                  amountCtrl.text.replaceAll('.', '').replaceAll(',', ''),
                );
                if ((name.isEmpty && existing == null) || amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama & jumlah wajib diisi')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                context.read<SavingsCubit>().setCategoryBudget(
                      categoryName: existing != null ? existing.categoryName : name,
                      amount: amount,
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetSummaryCard extends StatelessWidget {
  const _BudgetSummaryCard({
    required this.summary,
    required this.month,
  });

  final BudgetSummary summary;
  final String month;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = (summary.percentageUsed / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1D3448), Color(0xFF0F1A24)],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [context.colors.secondary, context.colors.secondaryDim],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : context.colors.secondary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL BUDGET — $month',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CategoryBudgetTab.fmtCurrency(summary.totalBudget),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  summary.warningLevel.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terpakai: ${CategoryBudgetTab.fmtCurrency(summary.totalSpent)}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
              ),
              Text(
                '${summary.percentageUsed.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(
                pct > 1.0
                    ? Colors.red.shade300
                    : pct >= 0.9
                        ? Colors.orange.shade300
                        : Colors.greenAccent.shade200,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sisa: ${CategoryBudgetTab.fmtCurrency(summary.totalRemaining)}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _BudgetCardItem extends StatelessWidget {
  const _BudgetCardItem({
    required this.bd,
    required this.item,
  });

  final BudgetGoalsResponse bd;
  final BudgetGoalItem item;

  Color _warningColor(BudgetWarningLevel lvl) {
    switch (lvl) {
      case BudgetWarningLevel.safe:
        return Colors.green.shade600;
      case BudgetWarningLevel.warning:
        return Colors.orange.shade600;
      case BudgetWarningLevel.critical:
        return Colors.deepOrange.shade600;
      case BudgetWarningLevel.exceeded:
        return Colors.red.shade700;
    }
  }

  IconData _iconForCategory(String name) {
    final lower = name.toLowerCase();
    const map = <String, IconData>{
      'makanan': Icons.restaurant,
      'food': Icons.restaurant,
      'minuman': Icons.local_cafe,
      'transportasi': Icons.directions_car,
      'transport': Icons.directions_car,
      'belanja': Icons.shopping_bag,
      'shopping': Icons.shopping_bag,
      'hiburan': Icons.celebration,
      'entertainment': Icons.celebration,
      'tagihan': Icons.receipt_long,
      'bills': Icons.receipt_long,
      'kesehatan': Icons.health_and_safety,
      'health': Icons.health_and_safety,
      'gaji': Icons.payments,
      'salary': Icons.payments,
      'pendidikan': Icons.school,
    };
    for (final key in map.keys) {
      if (lower.contains(key)) return map[key]!;
    }
    return Icons.account_balance_wallet_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = (item.percentageUsed / 100).clamp(0.0, 1.5);
    final color = _warningColor(item.warningLevel);
    final icon = _iconForCategory(item.categoryName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D3448) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.categoryName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      '${item.percentageUsed.toStringAsFixed(0)}% • ${item.warningLevel.label}',
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CategoryBudgetTab.fmtCurrency(item.spentAmount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    '/ ${CategoryBudgetTab.fmtCurrency(item.budgetAmount)}',
                    style: TextStyle(
                      fontSize: 11, 
                      color: isDark ? Colors.white70 : context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'edit') {
                    _showEditBudgetDialog(context);
                  }
                  if (val == 'delete') {
                    _confirmDeleteBudget(context);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit Budget')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Hapus', style: TextStyle(color: Colors.red.shade600)),
                  ),
                ],
                icon: Icon(Icons.more_vert, color: context.colors.outlineVariant, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sisa: ${CategoryBudgetTab.fmtCurrency(item.remaining)}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white70 : context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                item.monthYear,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white60 : context.colors.outlineVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context) {
    CategoryBudgetTab._showSetBudgetDialog(context, bd, existing: item);
  }

  Future<void> _confirmDeleteBudget(BuildContext context) async {
    final confirmed = await AppDialogs.confirmDelete(
      context,
      title: 'Hapus Budget?',
      message: 'Budget "${item.categoryName}" akan dihapus secara permanen.',
    );
    if ((confirmed ?? false) && context.mounted) {
      unawaited(context.read<SavingsCubit>().deleteCategoryBudget(item.id));
    }
  }
}

class _FinancialWarningChip extends StatelessWidget {
  const _FinancialWarningChip({
    required this.text,
    required this.icon,
    required this.fgColor,
    required this.bgColor,
  });

  final String text;
  final IconData icon;
  final Color fgColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fgColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: fgColor, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: fgColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialEmptyState extends StatelessWidget {
  const _FinancialEmptyState({
    required this.title,
    required this.sub,
    required this.icon,
  });

  final String title;
  final String sub;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(icon, size: 48, color: context.colors.outlineVariant),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialErrorWidget extends StatelessWidget {
  const _FinancialErrorWidget({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat data',
              style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.onSurface),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.onSurfaceVariant, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetWrapper extends StatelessWidget {
  const _SheetWrapper({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 20,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D3448) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : context.colors.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.type = TextInputType.text,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType type;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: type,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: context.colors.primary, size: 20),
        filled: true,
        fillColor: enabled
            ? context.colors.surfaceContainerLow
            : context.colors.surfaceContainerHighest.withValues(alpha: 0.4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: context.colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.primary, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
