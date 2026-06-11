import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';

class StatsGrid extends StatelessWidget {
  final double? dailyExpense;
  final double? budgetLeft;
  final double? totalIncome;
  final bool isLoading;

  const StatsGrid({
    super.key,
    this.dailyExpense,
    this.budgetLeft,
    this.totalIncome,
    this.isLoading = false,
  });

  String _formatShort(double? v) {
    if (v == null) return '0';
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_cafe_rounded,
            iconColor: context.colors.primary,
            iconBgColor: context.colors.primaryFixed,
            label: 'Daily Expense',
            value: _formatShort(dailyExpense),
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: context.colors.darkNav,
            iconBgColor: context.colors.tertiaryContainer,
            label: 'Budget Left',
            value: _formatShort(budgetLeft),
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final String value;
  final bool isLoading;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.value,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D3448) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0xFF2A4A62) : context.colors.outlineVariant, 
          width: 1.5
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.nunito(
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading) const SizedBox(
                  height: 36,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CircularProgressIndicator(),
                  ),
                ) else Text(
                  value,
                  style: GoogleFonts.nunito(
                    color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
        ],
      ),
    );
  }
}
