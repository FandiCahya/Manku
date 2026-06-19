import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';

class StatsGrid extends StatelessWidget {
  final double? dailyExpense;
  final double? monthlyBalance;
  final bool isLoading;

  // Kept for backward compat — not displayed separately
  final double? totalIncome;
  final double? totalExpense;
  final double? budgetLeft;

  const StatsGrid({
    super.key,
    this.dailyExpense,
    this.monthlyBalance,
    this.isLoading = false,
    this.totalIncome,
    this.totalExpense,
    this.budgetLeft,
  });

  String _formatShort(double? v) {
    if (v == null) return '0';
    final isNegative = v < 0;
    final absV = v.abs();

    String result;
    if (absV >= 1000000) {
      result = '${(absV / 1000000).toStringAsFixed(1)}M';
    } else if (absV >= 1000) {
      result = '${(absV / 1000).toStringAsFixed(0)}K';
    } else {
      result = absV.toStringAsFixed(0);
    }

    return isNegative ? '-$result' : result;
  }

  @override
  Widget build(BuildContext context) {
    // Monthly balance: prioritise explicit value, fallback to income - expense
    final balance = monthlyBalance
        ?? ((totalIncome ?? 0) - (totalExpense ?? 0));

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
            icon: balance >= 0
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            iconColor: balance >= 0
                ? context.colors.mint
                : context.colors.coral,
            iconBgColor: balance >= 0
                ? context.colors.mint.withValues(alpha: 0.15)
                : context.colors.coral.withValues(alpha: 0.15),
            label: 'Monthly Balance',
            value: _formatShort(balance),
            valueColor: balance >= 0
                ? context.colors.mint
                : context.colors.coral,
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
  final Color? valueColor;
  final bool isLoading;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.value,
    this.valueColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveValueColor =
        valueColor ?? (isDark ? Colors.white : const Color(0xFF1E1E1E));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D3448) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2A4A62)
              : context.colors.outlineVariant,
          width: 1.5,
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
                    color: isDark
                        ? Colors.white70
                        : const Color(0xFF6B7280),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const SizedBox(
              height: 36,
              child: Align(
                alignment: Alignment.centerLeft,
                child: CircularProgressIndicator(),
              ),
            )
          else
            Text(
              value,
              style: GoogleFonts.nunito(
                color: effectiveValueColor,
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
