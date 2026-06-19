import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../models/report_summary.dart';

class SpendingPerformanceChart extends StatefulWidget {
  final ReportSummary? report;
  final bool isLoading;

  const SpendingPerformanceChart({
    super.key,
    this.report,
    this.isLoading = false,
  });

  @override
  State<SpendingPerformanceChart> createState() =>
      _SpendingPerformanceChartState();
}

class _SpendingPerformanceChartState extends State<SpendingPerformanceChart> {
  int _selectedIndex = 5; // Default ke bulan terakhir (indeks 5)

  @override
  void didUpdateWidget(covariant SpendingPerformanceChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika data laporan berubah, reset selectedIndex ke bulan terakhir
    if (widget.report != null &&
        widget.report!.performanceSixMonths.isNotEmpty &&
        oldWidget.report != widget.report) {
      _selectedIndex = widget.report!.performanceSixMonths.length - 1;
    }
  }

  String _formatCurrency(double amount) {
    final parts = amount.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buffer.write('.');
      buffer.write(parts[i]);
    }
    return 'Rp $buffer';
  }

  void _handleTouch(Offset localPosition, double width) {
    final report = widget.report;
    if (report == null || report.performanceSixMonths.isEmpty) return;
    final months = report.performanceSixMonths;

    const leftPadding = 24.0;
    const rightPadding = 24.0;
    final chartWidth = width - leftPadding - rightPadding;

    if (chartWidth <= 0) return;

    // Hitung indeks terdekat berdasarkan posisi X sentuhan
    int closestIndex = 0;
    double minDistance = double.infinity;
    for (int i = 0; i < months.length; i++) {
      final x = leftPadding + (i * chartWidth / (months.length - 1));
      final distance = (localPosition.dx - x).abs();
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    if (closestIndex != _selectedIndex &&
        closestIndex >= 0 &&
        closestIndex < months.length) {
      setState(() {
        _selectedIndex = closestIndex;
      });
    }
  }

  Widget _buildLegendItem(String label, Color color, double amount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? Colors.white70
                    : context.colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _formatCurrency(amount),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white : context.colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendPill(PerformanceMonth current, PerformanceMonth? previous) {
    if (previous == null || previous.amount == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Awal Tren',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: context.colors.onSurfaceVariant,
          ),
        ),
      );
    }

    final currentAmt = current.amount;
    final prevAmt = previous.amount;
    final pct = ((currentAmt - prevAmt) / prevAmt) * 100;

    // Untuk pengeluaran: menurun (negatif) adalah bagus, meningkat (positif) adalah peringatan
    final increased = currentAmt > prevAmt;
    final isZero = currentAmt == prevAmt;

    final label = isZero
        ? 'Stabil'
        : '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(1)}%';

    late Color pillColor;
    late Color textColor;
    late IconData icon;

    if (isZero) {
      pillColor = context.colors.surfaceContainerHigh;
      textColor = context.colors.onSurfaceVariant;
      icon = Icons.horizontal_rule;
    } else if (increased) {
      pillColor = const Color(0xFFFCE8E6); // Merah muda lembut
      textColor = const Color(0xFFC5221F); // Merah tua
      icon = Icons.trending_up;
    } else {
      pillColor = const Color(0xFFE6F4EA); // Hijau muda lembut
      textColor = const Color(0xFF137333); // Hijau tua
      icon = Icons.trending_down;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pillColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final report = widget.report;
    final months = report?.performanceSixMonths ?? [];
    final maxAmount = report?.performanceMaxAmount ?? 1.0;

    // Cegah crash jika indeks di luar jangkauan setelah data loading
    if (_selectedIndex >= months.length && months.isNotEmpty) {
      _selectedIndex = months.length - 1;
    }

    final hasData = !widget.isLoading && report != null && months.isNotEmpty;

    final PerformanceMonth? activeMonth = hasData
        ? months[_selectedIndex]
        : null;
    final PerformanceMonth? prevMonth = (hasData && _selectedIndex > 0)
        ? months[_selectedIndex - 1]
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1D3448)
            : context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Laporan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : context.colors.secondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.isLoading
                          ? 'Loading data...'
                          : !hasData
                          ? 'No transaction data'
                          : '6 months trend - ${activeMonth?.month} ${activeMonth?.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white70
                            : context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Legend for Income and Expense
          if (hasData && activeMonth != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  'Income',
                  context.colors.mint,
                  activeMonth.income,
                ),
                const SizedBox(width: 24),
                _buildLegendItem(
                  'Expense',
                  context.colors.coral,
                  activeMonth.expense,
                ),
              ],
            ),
          const SizedBox(height: 16),

          // Area Grafik
          if (widget.isLoading)
            const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (!hasData)
            SizedBox(
              height: 220,
              child: Center(
                child: Text(
                  'No transaction history for the last 6 months.',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white70
                        : context.colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return GestureDetector(
                  onTapDown: (details) =>
                      _handleTouch(details.localPosition, width),
                  onPanUpdate: (details) =>
                      _handleTouch(details.localPosition, width),
                  child: Container(
                    height: 220,
                    color: Colors.transparent,
                    child: CustomPaint(
                      size: Size(width, 220),
                      painter: DualLineChartPainter(
                        colors: context.colors,
                        months: months,
                        maxAmount: maxAmount,
                        selectedIndex: _selectedIndex,
                        isDark: isDark,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// Painter untuk grafik dengan 2 garis (Income dan Expense)
class DualLineChartPainter extends CustomPainter {
  final dynamic colors;
  final List<PerformanceMonth> months;
  final double maxAmount;
  final int selectedIndex;
  final bool isDark;

  DualLineChartPainter({
    required this.colors,
    required this.months,
    required this.maxAmount,
    required this.selectedIndex,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (months.isEmpty) return;

    const leftPadding = 24.0;
    const rightPadding = 24.0;
    const topPadding = 20.0;
    const bottomPadding = 30.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    // 1. Tentukan titik-titik koordinat untuk Income dan Expense
    final incomePoints = <Offset>[];
    final expensePoints = <Offset>[];

    for (int i = 0; i < months.length; i++) {
      final x = leftPadding + (i * chartWidth / (months.length - 1));

      // Income points (biru)
      final incomeRatio = maxAmount > 0 ? months[i].income / maxAmount : 0.0;
      final incomeY = size.height - bottomPadding - (incomeRatio * chartHeight);
      incomePoints.add(Offset(x, incomeY));

      // Expense points (merah)
      final expenseRatio = maxAmount > 0 ? months[i].expense / maxAmount : 0.0;
      final expenseY =
          size.height - bottomPadding - (expenseRatio * chartHeight);
      expensePoints.add(Offset(x, expenseY));
    }

    // 2. Gambar garis Grid Horizontal (3 buah)
    final gridPaint = Paint()
      ..color = (colors.outlineVariant as Color).withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 2; i++) {
      final yGrid = topPadding + (i * chartHeight / 2);
      canvas.drawLine(
        Offset(leftPadding, yGrid),
        Offset(size.width - rightPadding, yGrid),
        gridPaint,
      );
    }

    // 3. Gambar garis vertikal indikator jika ada yang dipilih
    if (selectedIndex >= 0 && selectedIndex < incomePoints.length) {
      final activePoint = incomePoints[selectedIndex];
      final linePaint = Paint()
        ..color = (colors.primary as Color).withValues(alpha: 0.10)
        ..strokeWidth = 1.5;

      // Gambar garis putus-putus vertikal
      double startY = topPadding - 10;
      const dashHeight = 4.0;
      const dashGap = 4.0;
      while (startY < size.height - bottomPadding) {
        canvas.drawLine(
          Offset(activePoint.dx, startY),
          Offset(activePoint.dx, startY + dashHeight),
          linePaint,
        );
        startY += dashHeight + dashGap;
      }
    }

    // 4. Bangun Path untuk Income (Biru - Smooth curve)
    final incomePath = Path();
    incomePath.moveTo(incomePoints[0].dx, incomePoints[0].dy);
    for (int i = 0; i < incomePoints.length - 1; i++) {
      final p1 = incomePoints[i];
      final p2 = incomePoints[i + 1];
      final controlX = p1.dx + (p2.dx - p1.dx) / 2;
      final cp1 = Offset(controlX, p1.dy);
      final cp2 = Offset(controlX, p2.dy);
      incomePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    // 5. Bangun Path untuk Expense (Merah - Smooth curve)
    final expensePath = Path();
    expensePath.moveTo(expensePoints[0].dx, expensePoints[0].dy);
    for (int i = 0; i < expensePoints.length - 1; i++) {
      final p1 = expensePoints[i];
      final p2 = expensePoints[i + 1];
      final controlX = p1.dx + (p2.dx - p1.dx) / 2;
      final cp1 = Offset(controlX, p1.dy);
      final cp2 = Offset(controlX, p2.dy);
      expensePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    // 6. Gambar Garis Income (Biru)
    final incomeStrokePaint = Paint()
      ..color = colors.mint as Color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(incomePath, incomeStrokePaint);

    // 7. Gambar Garis Expense (Merah)
    final expenseStrokePaint = Paint()
      ..color = colors.coral as Color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(expensePath, expenseStrokePaint);

    // 8. Gambar Titik-titik Data & Label Bulan
    for (int i = 0; i < incomePoints.length; i++) {
      final incomePoint = incomePoints[i];
      final expensePoint = expensePoints[i];
      final isSelected = i == selectedIndex;

      // Gambar dot untuk Income
      if (isSelected) {
        final glowPaint = Paint()
          ..color = (colors.mint as Color).withValues(alpha: 0.20)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(incomePoint, 12.0, glowPaint);
      }

      final incomeDotPaint = Paint()
        ..color = colors.mint as Color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(incomePoint, isSelected ? 5.0 : 3.5, incomeDotPaint);

      // Gambar dot untuk Expense
      if (isSelected) {
        final glowPaint = Paint()
          ..color = (colors.coral as Color).withValues(alpha: 0.20)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(expensePoint, 12.0, glowPaint);
      }

      final expenseDotPaint = Paint()
        ..color = colors.coral as Color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(expensePoint, isSelected ? 5.0 : 3.5, expenseDotPaint);

      // Label Bulan di bawah titik
      final textPainter = TextPainter(
        text: TextSpan(
          text: months[i].month,
          style: TextStyle(
            color: isSelected
                ? colors.primary as Color
                : colors.outline as Color,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          incomePoint.dx - (textPainter.width / 2),
          size.height - bottomPadding + 8,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant DualLineChartPainter oldDelegate) {
    return oldDelegate.months != months ||
        oldDelegate.maxAmount != maxAmount ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
