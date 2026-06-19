import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';
import '../features/savings/presentation/cubit/savings_cubit.dart';
import '../features/savings/presentation/cubit/savings_state.dart';

/// Card showing overall progress of financial goals
class GoalsProgressCard extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const GoalsProgressCard({
    super.key,
    this.isLoading = false,
    this.onTap,
  });

  @override
  State<GoalsProgressCard> createState() => _GoalsProgressCardState();
}

class _GoalsProgressCardState extends State<GoalsProgressCard> {
  @override
  void initState() {
    super.initState();
    // Fetch savings data when widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SavingsCubit>().fetchSavingsData();
      }
    });
  }

  String _formatCompact(double v) {
    if (v >= 1000000000) {
      return 'Rp ${(v / 1000000000).toStringAsFixed(1)}B';
    }
    if (v >= 1000000) {
      return 'Rp ${(v / 1000000).toStringAsFixed(1)}M';
    }
    if (v >= 1000) {
      return 'Rp ${(v / 1000).toStringAsFixed(0)}K';
    }
    return 'Rp ${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<SavingsCubit, SavingsState>(
      builder: (context, savingsState) {
        // Get data from savings state
        final savingsData = savingsState is SavingsLoaded 
            ? savingsState.budgetGoals 
            : null;
        
        final totalGoals = savingsData?.budgets.length ?? 0;
        final completedGoals = savingsData?.budgets
            .where((g) => g.percentageUsed >= 100)
            .length ?? 0;
        final totalTarget = savingsData?.summary.totalBudget ?? 0;
        final totalSaved = savingsData?.summary.totalSpent ?? 0;
        
        final isLoadingData = widget.isLoading || 
            savingsState is SavingsLoading || 
            savingsState is SavingsInitial;
        
        final progress = totalTarget > 0 
            ? (totalSaved / totalTarget * 100).clamp(0, 100)
            : 0.0;
        
        final Color progressColor = progress >= 75
            ? context.colors.mint
            : progress >= 50
                ? context.colors.lavender
                : progress >= 25
                    ? context.colors.warmYellow
                    : context.colors.coral;

        return InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(32),
          child: Container(
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
            child: isLoadingData
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ──────────────────────────────────────────
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.savings_outlined,
                                color: context.colors.primary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Financial Goals',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: isDark ? Colors.white : context.colors.onSurface,
                              ),
                            ),
                          ),
                          if (widget.onTap != null)
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: isDark ? Colors.white60 : context.colors.outlineVariant,
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Progress Stats ──────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatColumn(
                            label: 'Total Tujuan',
                            value: '$totalGoals',
                            icon: Icons.flag_outlined,
                            color: context.colors.lavender,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: isDark 
                                ? Colors.white.withValues(alpha: 0.1)
                                : context.colors.outlineVariant.withValues(alpha: 0.3),
                          ),
                          _StatColumn(
                            label: 'Tercapai',
                            value: '$completedGoals',
                            icon: Icons.check_circle_outline,
                            color: context.colors.mint,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Progress Bar ────────────────────────────────────
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress',
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white70 : context.colors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '${progress.toStringAsFixed(1)}%',
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: progressColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress / 100,
                              minHeight: 10,
                              backgroundColor: isDark 
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : context.colors.outlineVariant.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation(progressColor),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatCompact(totalSaved),
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : context.colors.onSurface,
                                ),
                              ),
                              Text(
                                'dari ${_formatCompact(totalTarget)}',
                                style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white60 : context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // ── Action hint ─────────────────────────────────────
                      if (widget.onTap != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.white.withValues(alpha: 0.05)
                                : context.colors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app_outlined,
                                size: 14,
                                color: isDark ? Colors.white70 : context.colors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Tap untuk lihat detail',
                                style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : context.colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : context.colors.onSurface,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
