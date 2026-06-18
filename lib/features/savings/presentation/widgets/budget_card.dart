import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/budget_models.dart';
import '../utils/budget_ui_helpers.dart';

/// Single budget category card with progress bar and action menu.
class BudgetCard extends StatelessWidget {
  const BudgetCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final BudgetGoalItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warnColor = BudgetUiHelpers.warningColor(item.warningLevel);
    final warnBg = BudgetUiHelpers.warningBg(item.warningLevel);
    final isCompleted = item.warningLevel == BudgetWarningLevel.exceeded;
    final pct = (item.percentageUsed / 100).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D3448) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isCompleted
            ? Border.all(color: Colors.green.shade200, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? Colors.green.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Colour accent bar at top
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: warnColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BudgetCardHeader(
                  item: item,
                  warnColor: warnColor,
                  warnBg: warnBg,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
                const SizedBox(height: 16),
                _BudgetCardProgress(
                  item: item,
                  warnColor: warnColor,
                  warnBg: warnBg,
                  pct: pct,
                  isCompleted: isCompleted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetCardHeader extends StatelessWidget {
  const _BudgetCardHeader({
    required this.item,
    required this.warnColor,
    required this.warnBg,
    required this.onEdit,
    required this.onDelete,
  });

  final BudgetGoalItem item;
  final Color warnColor;
  final Color warnBg;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warnIcon = BudgetUiHelpers.warningIcon(item.warningLevel);
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: warnBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            BudgetUiHelpers.iconForCategory(item.categoryName),
            color: warnColor,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.categoryName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF13304f),
                ),
              ),
              Row(
                children: [
                  Icon(warnIcon, size: 12, color: warnColor),
                  const SizedBox(width: 4),
                  Text(
                    item.warningLevel.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: warnColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Text(
          item.warningLevel == BudgetWarningLevel.exceeded ? '🎉' : 
          item.warningLevel == BudgetWarningLevel.critical ? '💪' : 
          item.warningLevel == BudgetWarningLevel.warning ? '📈' : '🎯',
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (val) {
            if (val == 'edit') onEdit();
            if (val == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                Icon(Icons.edit_outlined, color: Colors.blue, size: 18),
                SizedBox(width: 10),
                Text('Edit Tujuan'),
              ]),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete_outline, color: Colors.red, size: 18),
                SizedBox(width: 10),
                Text('Hapus', style: TextStyle(color: Colors.red)),
              ]),
            ),
          ],
        ),
      ],
    );
  }
}

class _BudgetCardProgress extends StatelessWidget {
  const _BudgetCardProgress({
    required this.item,
    required this.warnColor,
    required this.warnBg,
    required this.pct,
    required this.isCompleted,
  });

  final BudgetGoalItem item;
  final Color warnColor;
  final Color warnBg;
  final double pct;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: warnColor.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(warnColor),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: BudgetUiHelpers.formatCurrency(item.spentAmount),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: warnColor,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' / ${BudgetUiHelpers.formatCurrency(item.budgetAmount)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: warnBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${item.percentageUsed.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: warnColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle_outline
                  : Icons.trending_up,
              size: 13,
              color:
                  isCompleted ? Colors.green.shade600 : Colors.blue.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              isCompleted
                  ? 'Target tercapai! 🎉'
                  : 'Kurang ${BudgetUiHelpers.formatCurrency(item.remaining)}',
              style: TextStyle(
                fontSize: 12,
                color:
                    isCompleted ? Colors.green.shade600 : Colors.blue.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
