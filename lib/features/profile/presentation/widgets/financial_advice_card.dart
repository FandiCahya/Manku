import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../savings/domain/financial_advice.dart';

class FinancialAdviceCard extends StatelessWidget {
  const FinancialAdviceCard({
    required this.adviceData,
    super.key,
  });

  final FinancialAdvice? adviceData;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final advice = adviceData;
    if (advice == null) return const SizedBox.shrink();

    final status = advice.statusKeuangan;
    final ringkasan = advice.ringkasanAnalisis;
    final saranList = advice.saranList;

    Color badgeBg;
    Color badgeText;
    switch (status.toLowerCase()) {
      case 'sangat baik':
      case 'sehat':
        badgeBg = Colors.green.shade50;
        badgeText = Colors.green.shade700;
      case 'butuh penyesuaian':
        badgeBg = Colors.orange.shade50;
        badgeText = Colors.orange.shade700;
      case 'kritis':
        badgeBg = Colors.red.shade50;
        badgeText = Colors.red.shade700;
      default:
        badgeBg = context.colors.surfaceContainer;
        badgeText = context.colors.onSurfaceVariant;
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D3448) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: context.colors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Saran AI',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : context.colors.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: badgeText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (ringkasan.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                ringkasan,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : context.colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
          if (saranList.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: saranList
                    .take(3)
                    .map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(top: 6, right: 10),
                              decoration: BoxDecoration(
                                color: context.colors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                s,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white : context.colors.onSurface,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
