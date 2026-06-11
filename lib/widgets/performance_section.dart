import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../models/report_summary.dart';

class PerformanceSection extends StatelessWidget {
  final List<PerformanceMonth>? months;
  final double maxAmount;
  final bool isLoading;

  const PerformanceSection({
    super.key,
    this.months,
    this.maxAmount = 1.0,
    this.isLoading = false,
  });

  /// Hitung persentase perubahan antara bulan sekarang vs bulan sebelumnya
  String _changeLabel() {
    if (months == null || months!.length < 2) return '-';
    final current = months!.last.amount;
    final previous = months![months!.length - 2].amount;
    if (previous == 0) return current > 0 ? '+100%' : '0%';
    final pct = ((current - previous) / previous) * 100;
    return '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(1)}%';
  }

  bool _isIncreased() {
    if (months == null || months!.length < 2) return false;
    return months!.last.amount > months![months!.length - 2].amount;
  }

  @override
  Widget build(BuildContext context) {
    final changeLabel = _changeLabel();
    final increased = _isIncreased();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pengeluaran 6 bulan terakhir',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (!isLoading)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.tertiaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        increased ? Icons.trending_up : Icons.trending_down,
                        size: 12,
                        color: increased
                            ? Colors.redAccent
                            : context.colors.onTertiaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        changeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: increased
                              ? Colors.redAccent
                              : context.colors.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                )
              : (months == null || months!.isEmpty)
                  ? Center(
                      child: Text(
                        'Belum ada data performa',
                        style: TextStyle(color: context.colors.onSurfaceVariant),
                      ),
                    )
                  : SizedBox(
                      height: 140,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: months!.map((m) {
                          final pct = maxAmount > 0
                              ? m.amount / maxAmount
                              : 0.0;
                          // Cari bulan dengan amount tertinggi
                          final isHighest = m.amount > 0 &&
                              m.amount ==
                                  months!
                                      .map((x) => x.amount)
                                      .reduce((a, b) => a > b ? a : b);
                          return _buildBarChart(
                            context,
                            m.month,
                            pct.clamp(0.0, 1.0),
                            isHighest: isHighest,
                            isCurrentMonth: m.isCurrent,
                          );
                        }).toList(),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildBarChart(
    BuildContext context,
    String label,
    double percentage, {
    bool isHighest = false,
    bool isCurrentMonth = false,
  }) {
    late Color barColor;
    late Color shadowColor;

    if (isCurrentMonth) {
      barColor = const Color(0xFFffc8dd);
      shadowColor = const Color(0xFFffc8dd).withValues(alpha: 0.3);
    } else if (isHighest) {
      barColor = context.colors.primary;
      shadowColor = const Color(0xFFa1c1fc).withValues(alpha: 0.3);
    } else {
      barColor = context.colors.outlineVariant.withValues(alpha: 0.3);
      shadowColor = Colors.transparent;
    }

    return SizedBox(
      width: 32,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              // FractionallySizedBox untuk tinggi proporsional
              child: FractionallySizedBox(
                alignment: Alignment.bottomCenter,
                heightFactor: percentage == 0 ? 0.03 : percentage,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: context.colors.outline,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
