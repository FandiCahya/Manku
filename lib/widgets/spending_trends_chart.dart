import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';
import '../models/dashboard_summary.dart';

class SpendingTrendsChart extends StatelessWidget {
  final List<SpendingTrendDay>? trends;
  final double maxAmount;
  final bool isLoading;

  const SpendingTrendsChart({
    super.key,
    this.trends,
    this.maxAmount = 1.0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Get last 7 days of spending data (chronologically)
    List<SpendingTrendDay> displayDays = [];
    if (trends != null && trends!.isNotEmpty) {
      // Sort by date (most recent first) and take up to 7 days
      displayDays = List<SpendingTrendDay>.from(trends!)
        ..sort((a, b) => b.date.compareTo(a.date));
      displayDays = displayDays.take(7).toList();
      // Reverse to show oldest to newest (left to right)
      displayDays = displayDays.reversed.toList();
    }

    // Find max amount for scaling
    final maxDisplayAmount = displayDays.isEmpty 
        ? 1.0 
        : displayDays.map((d) => d.amount).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D3448) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending Performance',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                ),
              ),
              Icon(
                Icons.more_horiz, 
                color: isDark ? Colors.white70 : const Color(0xFF6B7280)
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '7 Hari Terakhir',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: isDark ? Colors.white60 : const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          if (isLoading)
            const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (displayDays.isEmpty)
            SizedBox(
              height: 160,
              child: Center(
                child: Text(
                  'Belum ada data pengeluaran.',
                  style: GoogleFonts.nunito(
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: displayDays.asMap().entries.map((entry) {
                  final day = entry.value;
                  final barHeight = maxDisplayAmount > 0
                      ? (day.amount / maxDisplayAmount * 120).clamp(8.0, 120.0)
                      : 8.0;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Amount label at top of bar
                          if (day.amount > 0) ...[
                            Text(
                              'Rp${(day.amount / 1000).toStringAsFixed(0)}K',
                              style: GoogleFonts.nunito(
                                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          
                          // Rounded bar
                          Container(
                            height: barHeight,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  context.colors.primary.withOpacity(0.8),
                                  context.colors.primary,
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: context.colors.primary.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Day label
                          Text(
                            day.day,
                            style: GoogleFonts.nunito(
                              color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
