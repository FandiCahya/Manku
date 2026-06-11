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
  State<SpendingPerformanceChart> createState() => _SpendingPerformanceChartState();
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

    if (closestIndex != _selectedIndex && closestIndex >= 0 && closestIndex < months.length) {
      setState(() {
        _selectedIndex = closestIndex;
      });
    }
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
    
    final label = isZero ? 'Stabil' : '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(1)}%';

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
          Icon(
            icon,
            size: 12,
            color: textColor,
          ),
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

    final PerformanceMonth? activeMonth = hasData ? months[_selectedIndex] : null;
    final PerformanceMonth? prevMonth = (hasData && _selectedIndex > 0) ? months[_selectedIndex - 1] : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D3448) : context.colors.surfaceContainerLowest,
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
                          ? 'Memuat data performa...'
                          : !hasData
                              ? 'Tidak ada data pengeluaran'
                              : 'Total pengeluaran ${activeMonth?.month} ${activeMonth?.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasData && activeMonth != null) _buildTrendPill(activeMonth, prevMonth),
            ],
          ),
          const SizedBox(height: 16),
          // Jumlah Pengeluaran yang Aktif
          if (widget.isLoading)
            const SizedBox(
              height: 38,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (activeMonth != null)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, -0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                _formatCurrency(activeMonth.amount),
                key: ValueKey('${activeMonth.month}_${activeMonth.amount}'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : context.colors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            )
          else
            Text(
              'Rp 0',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : context.colors.primary,
              ),
            ),
          const SizedBox(height: 24),

          // Area Grafik
          if (widget.isLoading) const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                ) else !hasData
                  ? SizedBox(
                      height: 180,
                      child: Center(
                        child: Text(
                          'Belum ada riwayat transaksi 6 bulan terakhir.',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : context.colors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        return GestureDetector(
                          onTapDown: (details) => _handleTouch(details.localPosition, width),
                          onPanUpdate: (details) => _handleTouch(details.localPosition, width),
                          child: Container(
                            height: 180,
                            color: Colors.transparent, // Untuk mendeteksi sentuhan di luar garis
                            child: CustomPaint(
                              size: Size(width, 180),
                              painter: CurveChartPainter(
                                colors: context.colors,
                                months: months,
                                maxAmount: maxAmount,
                                selectedIndex: _selectedIndex,
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

class CurveChartPainter extends CustomPainter {
  final AppColors colors;
  final List<PerformanceMonth> months;
  final double maxAmount;
  final int selectedIndex;

  CurveChartPainter({
    required this.colors,
    required this.months,
    required this.maxAmount,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (months.isEmpty) return;

    const leftPadding = 24.0;
    const rightPadding = 24.0;
    const topPadding = 20.0;
    const bottomPadding = 30.0; // Memberi ruang untuk teks bulan di bawah

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    // 1. Tentukan titik-titik koordinat data (X, Y)
    final points = <Offset>[];
    for (int i = 0; i < months.length; i++) {
      final x = leftPadding + (i * chartWidth / (months.length - 1));
      final ratio = maxAmount > 0 ? months[i].amount / maxAmount : 0.0;
      final y = size.height - bottomPadding - (ratio * chartHeight);
      points.add(Offset(x, y));
    }

    // 2. Gambar garis Grid Horizontal (3 buah)
    final gridPaint = Paint()
      ..color = colors.outlineVariant.withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 2; i++) {
      final yGrid = topPadding + (i * chartHeight / 2);
      canvas.drawLine(Offset(leftPadding, yGrid), Offset(size.width - rightPadding, yGrid), gridPaint);
    }

    // 3. Gambar garis vertikal indikator jika ada yang dipilih
    if (selectedIndex >= 0 && selectedIndex < points.length) {
      final activePoint = points[selectedIndex];
      final linePaint = Paint()
        ..color = colors.primary.withValues(alpha: 0.15)
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

    // 4. Bangun Path Bezier Halus (Kurva Kurva Bezier)
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlX = p1.dx + (p2.dx - p1.dx) / 2;
      final cp1 = Offset(controlX, p1.dy);
      final cp2 = Offset(controlX, p2.dy);
      
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    // 5. Gambar Gradient Fill di bawah Kurva
    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, size.height - bottomPadding);
    fillPath.lineTo(points.first.dx, size.height - bottomPadding);
    fillPath.close();

    final gradientPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors.primary.withValues(alpha: 0.24),
          colors.primary.withValues(alpha: 0.00),
        ],
      ).createShader(Rect.fromLTRB(leftPadding, topPadding, size.width - rightPadding, size.height - bottomPadding));

    canvas.drawPath(fillPath, gradientPaint);

    // 6. Gambar Garis Kurva Utama
    final strokePaint = Paint()
      ..color = colors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);

    // 7. Gambar Titik-titik Data (Dots) & Teks Label Bulan
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final isSelected = i == selectedIndex;

      // a. Gambar Titik data
      if (isSelected) {
        // Halo luar yang transparan (Efek Glow)
        final glowPaint = Paint()
          ..color = colors.primary.withValues(alpha: 0.18)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 14.0, glowPaint);

        // Border luar putih yang tebal
        final outerPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 7.0, outerPaint);

        // Lingkaran dalam warna primer
        final innerPaint = Paint()
          ..color = colors.primary
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 4.5, innerPaint);
      } else {
        // Dot biasa non-aktif
        final bgDotPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 4.5, bgDotPaint);

        final dotPaint = Paint()
          ..color = colors.outlineVariant.withValues(alpha: 0.7)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 3.0, dotPaint);
      }

      // b. Menggambar Label Bulan di bawah titik
      final textPainter = TextPainter(
        text: TextSpan(
          text: months[i].month,
          style: TextStyle(
            color: isSelected ? colors.primary : colors.outline,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(point.dx - (textPainter.width / 2), size.height - bottomPadding + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CurveChartPainter oldDelegate) {
    return oldDelegate.months != months ||
        oldDelegate.maxAmount != maxAmount ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
