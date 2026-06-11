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

    final totalAmount = displayDays.fold(0.0, (sum, item) => sum + item.amount);
    
    // Colors for the segments (cycle through if more than 3)
    final colors = [
      context.colors.primary,       // #6A89A7
      context.colors.secondary,     // #88BDF2
      context.colors.outlineVariant, // Light blue gray
    ];

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
          const SizedBox(height: 24),

          if (isLoading)
            const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (displayDays.isEmpty || totalAmount == 0)
            SizedBox(
              height: 60,
              child: Center(
                child: Text(
                  'No spending data available.',
                  style: GoogleFonts.nunito(
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                // Horizontal Segmented Bar
                Container(
                  height: 24,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: displayDays.asMap().entries.map((entry) {
                      final index = entry.key;
                      final day = entry.value;
                      final flex = totalAmount > 0 
                          ? (day.amount / totalAmount * 100).toInt()
                          : 1;
                      return Expanded(
                        flex: flex == 0 ? 1 : flex,
                        child: Container(
                          color: colors[index % colors.length],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Dotted line with labels below
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // A subtle line spanning the width
                    Positioned(
                      top: 4,
                      left: 10,
                      right: 10,
                      child: Container(
                        height: 1,
                        color: const Color(0xFFEDE9E0),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: displayDays.asMap().entries.map((entry) {
                        final index = entry.key;
                        final day = entry.value;
                        final color = colors[index % colors.length];
                        
                        return Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                day.day,
                                style: GoogleFonts.nunito(
                                  color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Rp ${(day.amount / 1000).toStringAsFixed(0)}K',
                                style: GoogleFonts.nunito(
                                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
