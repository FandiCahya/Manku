import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';

/// Circular arc gauge showing "Monthly Balance" from actual transactions
/// Balance = Total Income - Total Expenses (this month)
class MonthlyBalanceGauge extends StatefulWidget {
  final double? totalIncome;
  final double? totalExpense;
  final bool isLoading;

  const MonthlyBalanceGauge({
    super.key,
    this.totalIncome,
    this.totalExpense,
    this.isLoading = false,
  });

  @override
  State<MonthlyBalanceGauge> createState() => _MonthlyBalanceGaugeState();
}

class _MonthlyBalanceGaugeState extends State<MonthlyBalanceGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(MonthlyBalanceGauge old) {
    super.didUpdateWidget(old);
    if (old.totalIncome != widget.totalIncome ||
        old.totalExpense != widget.totalExpense) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double get _balance {
    final income = widget.totalIncome ?? 0;
    final expense = widget.totalExpense ?? 0;
    return income - expense;
  }

  double get _ratio {
    final income = widget.totalIncome;
    if (income == null || income <= 0) return 0;
    final balance = _balance.clamp(0.0, income);
    return balance / income;
  }

  String _formatCompact(double v) {
    final isNegative = v < 0;
    final absV = v.abs();
    
    String result;
    if (absV >= 1000000) {
      result = 'Rp ${(absV / 1000000).toStringAsFixed(1)}M';
    } else if (absV >= 1000) {
      result = 'Rp ${(absV / 1000).toStringAsFixed(0)}K';
    } else {
      result = 'Rp ${absV.toStringAsFixed(0)}';
    }
    
    return isNegative ? '-$result' : result;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = _ratio;
    final balance = _balance;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final Color trackColor = balance >= 0
        ? (ratio > 0.5
            ? context.colors.mint
            : ratio > 0.25
                ? context.colors.warmYellow
                : context.colors.coral)
        : Colors.red;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D3448) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.account_balance_wallet_rounded,
                    color: context.colors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Monthly Balance',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: isDark ? Colors.white : context.colors.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: trackColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  balance >= 0 ? 'Surplus' : 'Deficit',
                  style: GoogleFonts.nunito(
                    color: trackColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Gauge + labels ───────────────────────────────────────────
          Row(
            children: [
              // Arc gauge
              SizedBox(
                width: 120,
                height: 120,
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => CustomPaint(
                    painter: _ArcPainter(
                      ratio: ratio * _anim.value,
                      trackColor: trackColor,
                      bgColor: context.colors.outlineVariant,
                    ),
                    child: Center(
                      child: widget.isLoading
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _formatCompact(balance),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: isDark ? Colors.white : context.colors.onSurface,
                                  ),
                                ),
                                Text(
                                  'balance',
                                  style: GoogleFonts.nunito(
                                    fontSize: 10,
                                    color: isDark ? Colors.white70 : context.colors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Stat columns
              Expanded(
                child: Column(
                  children: [
                    _StatRow(
                      label: 'Income',
                      value: _formatCompact(widget.totalIncome ?? 0),
                      color: context.colors.mint,
                      icon: Icons.arrow_upward_rounded,
                    ),
                    const SizedBox(height: 12),
                    _StatRow(
                      label: 'Expense',
                      value: _formatCompact(widget.totalExpense ?? 0),
                      color: context.colors.coral,
                      icon: Icons.arrow_downward_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatRow(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: isDark ? Colors.white70 : context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600)),
            Text(value,
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : context.colors.onSurface)),
          ],
        ),
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double ratio; // 0.0 – 1.0
  final Color trackColor;
  final Color bgColor;

  _ArcPainter(
      {required this.ratio,
      required this.trackColor,
      required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const startAngle = pi * 0.75;
    const sweepFull = pi * 1.5;

    // Background arc
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepFull, false, bgPaint);

    // Active arc
    if (ratio > 0) {
      final fgPaint = Paint()
        ..shader = LinearGradient(
          colors: [trackColor.withValues(alpha: 0.7), trackColor],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          startAngle, sweepFull * ratio, false, fgPaint);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.ratio != ratio || old.trackColor != trackColor;
}
