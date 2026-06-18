import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/budget_models.dart';
import '../utils/budget_ui_helpers.dart';

class BudgetSummaryCard extends StatelessWidget {
  const BudgetSummaryCard({required this.summary, super.key});

  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final pct = (summary.percentageUsed / 100).clamp(0.0, 1.0);
    final warnColor = BudgetUiHelpers.warningColor(summary.warningLevel);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colors.secondary.withValues(alpha: 0.9),
              context.colors.secondaryDim,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: context.colors.secondary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TotalBudgetRow(summary: summary, warnColor: warnColor),
            const SizedBox(height: 20),
            _BudgetProgressSection(
              summary: summary,
              pct: pct,
              warnColor: warnColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalBudgetRow extends StatelessWidget {
  const _TotalBudgetRow({
    required this.summary,
    required this.warnColor,
  });

  final BudgetSummary summary;
  final Color warnColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TOTAL TARGET',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              BudgetUiHelpers.formatCurrency(summary.totalBudget),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
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
    );
  }
}

class _BudgetProgressSection extends StatelessWidget {
  const _BudgetProgressSection({
    required this.summary,
    required this.pct,
    required this.warnColor,
  });

  final BudgetSummary summary;
  final double pct;
  final Color warnColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Terkumpul: ${BudgetUiHelpers.formatCurrency(summary.totalSpent)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
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
            minHeight: 10,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(
              pct >= 1.0
                  ? Colors.green.shade300  // Target tercapai!
                  : pct >= 0.7
                      ? Colors.lightGreen.shade300  // Mendekati target
                      : Colors.blue.shade200,  // Masih jauh
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kurang: ${BudgetUiHelpers.formatCurrency(summary.totalRemaining)}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
