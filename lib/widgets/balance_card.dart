import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';

class BalanceCard extends StatelessWidget {
  final double? totalBalance;
  final bool isLoading;
  final VoidCallback? onAddTransaction;

  const BalanceCard({
    super.key,
    this.totalBalance,
    this.isLoading = false,
    this.onAddTransaction,
  });

  String _formatCurrency(double amount) {
    final isNegative = amount < 0;
    final abs = amount.abs();
    final parts = abs.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buffer.write('.');
      buffer.write(parts[i]);
    }
    return '${isNegative ? '-' : ''}Rp $buffer';
  }

  @override
  Widget build(BuildContext context) {
    // Blue-gray gradient card
    final Color cardStart = context.colors.primary;     // #6A89A7
    final Color cardEnd   = context.colors.darkNav;     // #384959
    final Color shadowCol = context.colors.primary;

    return Container(
      height: 220,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardStart, cardEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: shadowCol.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Decorative Elements ──
          Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: 0.1,
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            left: 50,
            bottom: -50,
            child: Opacity(
              opacity: 0.1,
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Placeholder for the illustration (e.g., Trophy)
          const Positioned(
            right: 16,
            bottom: 40,
            child: Opacity(
              opacity: 0.2,
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 100,
                color: Colors.white,
              ),
            ),
          ),
          // Sparkle stars
          Positioned(
            right: 40,
            top: 30,
            child: Icon(Icons.star_rounded, color: Colors.yellow.shade300, size: 24),
          ),
          Positioned(
            left: 20,
            bottom: 80,
            child: Icon(Icons.star_rounded, color: Colors.white.withValues(alpha: 0.15), size: 16),
          ),

          // ── Content ──
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Balance',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your daily expenses\nand track your budget efficiently',
                  style: GoogleFonts.nunito(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                
                // Bottom Row: Add button & Balance Value
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Circular Add Button
                    GestureDetector(
                      onTap: onAddTransaction,
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    
                    // Balance Amount
                    if (isLoading) const SizedBox(
                            height: 30,
                            width: 100,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ) else Text(
                            _formatCurrency(totalBalance ?? 0),
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
