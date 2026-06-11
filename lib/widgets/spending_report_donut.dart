import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../models/report_summary.dart';

// Palet warna untuk kategori di donut chart
const List<Color> _kCategoryColors = [
  Color(0xFFffc8dd),
  Color(0xFFa1d1fe),
  Color(0xFFfefaab),
  Color(0xFFb8f0c8),
  Color(0xFFd4b8f0),
  Color(0xFFf0b8b8),
  Color(0xFFb8d4f0),
  Color(0xFFf0d4b8),
];

class SpendingReportDonut extends StatelessWidget {
  final ReportSummary? report;
  final bool isLoading;

  const SpendingReportDonut({
    super.key,
    this.report,
    this.isLoading = false,
  });

  String _formatCurrency(double amount) {
    final parts = amount.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buffer.write('.');
      buffer.write(parts[i]);
    }
    return 'Rp $buffer';
  }

  @override
  Widget build(BuildContext context) {
    final categories = report?.categoryBreakdown ?? [];

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Spending Reports',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: context.colors.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bulan ini',
            style: TextStyle(
              fontSize: 11,
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          if (isLoading) const SizedBox(
                  width: 200,
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ) else SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(
                    painter: DonutChartPainter(
                      colors: context.colors,
                      categories: categories,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: context.colors.secondary,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(report?.totalSpending ?? 0),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: context.colors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 24),
          // Legend - tampilkan max 6 kategori
          if (!isLoading)
            categories.isEmpty
                ? Text(
                    'Belum ada pengeluaran bulan ini',
                    style: TextStyle(
                      color: context.colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  )
                : Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: List.generate(
                      math.min(categories.length, _kCategoryColors.length),
                      (i) => _buildLegendItem(
                        context,
                        categories[i].name,
                        _kCategoryColors[i % _kCategoryColors.length],
                        categories[i].percentage,
                      ),
                    ),
                  ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color, double percentage) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label (${(percentage * 100).toStringAsFixed(0)}%)',
          style: TextStyle(fontSize: 12, color: context.colors.onSurface),
        ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final AppColors colors;
  final List<CategoryBreakdownItem> categories;

  DonutChartPainter({
    required this.colors,
    required this.categories,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 22.0;
    const startAngle = -math.pi / 2; // Start from top

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (categories.isEmpty) {
      // Draw a full gray circle when no data
      paint.color = colors.surfaceContainer;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        0,
        math.pi * 2,
        false,
        paint,
      );
      return;
    }

    double currentAngle = startAngle;
    for (int i = 0; i < categories.length && i < _kCategoryColors.length; i++) {
      final cat = categories[i];
      final sweepAngle = cat.percentage * math.pi * 2;
      paint.color = _kCategoryColors[i % _kCategoryColors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweepAngle - 0.05, // Small gap between segments
        false,
        paint,
      );
      currentAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) =>
      oldDelegate.categories != categories;
}
