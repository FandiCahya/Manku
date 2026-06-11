import 'package:flutter/material.dart';
import '../../domain/budget_models.dart';

/// Shows either an "all safe" banner or exceeded/warning chips.
class BudgetWarningsRow extends StatelessWidget {
  const BudgetWarningsRow({required this.summary, super.key});

  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    if (summary.exceededCount == 0 && summary.warningCount == 0) {
      return const _AllSafeBanner();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          if (summary.exceededCount > 0)
            Expanded(
              child: _WarnChip(
                label: '${summary.exceededCount} melebihi batas',
                icon: Icons.cancel_outlined,
                color: Colors.red.shade600,
                bg: Colors.red.shade50,
              ),
            ),
          if (summary.exceededCount > 0 && summary.warningCount > 0)
            const SizedBox(width: 12),
          if (summary.warningCount > 0)
            Expanded(
              child: _WarnChip(
                label: '${summary.warningCount} mendekati batas',
                icon: Icons.warning_amber_outlined,
                color: Colors.orange.shade700,
                bg: Colors.orange.shade50,
              ),
            ),
        ],
      ),
    );
  }
}

class _AllSafeBanner extends StatelessWidget {
  const _AllSafeBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline,
                color: Colors.green.shade600, size: 18),
            const SizedBox(width: 10),
            Text(
              'Semua budget dalam kondisi aman! 🎉',
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WarnChip extends StatelessWidget {
  const _WarnChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


