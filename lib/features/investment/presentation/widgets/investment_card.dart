import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/investment_models.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Maps crypto/stock symbols to specific emoji icons
String _iconForSymbol(String symbol, bool isCrypto) {
  final s = symbol.toUpperCase();
  if (isCrypto) {
    const cryptoIcons = {
      'BTC': '₿',
      'ETH': 'Ξ',
      'BNB': '🔶',
      'SOL': '◎',
      'ADA': '🔷',
      'XRP': '💧',
      'DOGE': '🐶',
      'DOT': '●',
      'AVAX': '🔺',
      'MATIC': '🟣',
      'LINK': '🔗',
      'UNI': '🦄',
      'SHIB': '🐕',
      'LTC': 'Ł',
      'ATOM': '⚛',
      'USDT': '💵',
      'USDC': '💵',
    };
    return cryptoIcons[s] ?? '🪙';
  } else {
    const stockIcons = {
      // Indonesia
      'BBCA': '🏦', 'BBRI': '🏦', 'BMRI': '🏦', 'BBNI': '🏦', 'BBTN': '🏦',
      'TLKM': '📡', 'ISAT': '📡', 'EXCL': '📡',
      'ASII': '🚗', 'UNTR': '🚗',
      'GGRM': '🚬', 'HMSP': '🚬',
      'INDF': '🍜', 'ICBP': '🍜',
      'KLBF': '💊', 'SIDO': '💊',
      'ANTM': '⛏', 'PTBA': '⛏', 'ADRO': '⛏',
      'SMGR': '🏗', 'INTP': '🏗',
      'UNVR': '🧴',
      // Global
      'AAPL': '🍎',
      'GOOGL': '🔍', 'GOOG': '🔍',
      'MSFT': '🪟',
      'AMZN': '📦',
      'TSLA': '⚡',
      'META': '👥',
      'NVDA': '🎮',
      'NFLX': '🎬',
      'BABA': '🛒',
      'TSM': '💻',
      'BRKB': '💰', 'BRKA': '💰',
      'JPM': '🏦', 'BAC': '🏦', 'WFC': '🏦',
      'DIS': '🏰',
      'PYPL': '💳',
      'UBER': '🚕',
    };
    return stockIcons[s] ?? '📊';
  }
}

/// Returns gradient colors for each asset based on symbol
List<Color> _gradientForSymbol(String symbol, bool isCrypto) {
  final s = symbol.toUpperCase();
  if (isCrypto) {
    const cryptoColors = {
      'BTC': [Color(0xFFF7931A), Color(0xFFFFB74D)],
      'ETH': [Color(0xFF627EEA), Color(0xFF9C84F7)],
      'BNB': [Color(0xFFF3BA2F), Color(0xFFFFD54F)],
      'SOL': [Color(0xFF9945FF), Color(0xFF14F195)],
      'ADA': [Color(0xFF0033AD), Color(0xFF5078FF)],
      'XRP': [Color(0xFF00AAE4), Color(0xFF00D4FF)],
      'DOGE': [Color(0xFFC2A633), Color(0xFFE8D187)],
      'MATIC': [Color(0xFF8247E5), Color(0xFFAA6BF5)],
      'USDT': [Color(0xFF26A17B), Color(0xFF50C9A0)],
      'USDC': [Color(0xFF2775CA), Color(0xFF5B9BEB)],
    };
    return cryptoColors[s] ?? [const Color(0xFFFF8C00), const Color(0xFFFFB347)];
  } else {
    const stockColors = {
      'AAPL': [Color(0xFF555555), Color(0xFF888888)],
      'GOOGL': [Color(0xFF4285F4), Color(0xFF34A853)],
      'MSFT': [Color(0xFF00A4EF), Color(0xFF7FBA00)],
      'TSLA': [Color(0xFFCC0000), Color(0xFFFF4444)],
      'AMZN': [Color(0xFFFF9900), Color(0xFFFFB74D)],
      'META': [Color(0xFF0866FF), Color(0xFF42A5F5)],
      'NVDA': [Color(0xFF76B900), Color(0xFFA4D65E)],
      'BBCA': [Color(0xFF003087), Color(0xFF0055CC)],
      'BBRI': [Color(0xFF003087), Color(0xFF0055CC)],
      'TLKM': [Color(0xFFCC0000), Color(0xFFFF4444)],
    };
    return stockColors[s] ?? [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
  }
}

class InvestmentCard extends StatelessWidget {
  final Investment investment;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const InvestmentCard({
    required this.investment,
    this.onTap,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final assetIcon = _iconForSymbol(investment.symbol, investment.isCrypto);
    final gradientColors = _gradientForSymbol(investment.symbol, investment.isCrypto);
    final hasPrice = investment.currentPrice != null;
    final profitLoss = investment.profitLoss ?? 0;
    final profitLossPercentage = investment.profitLossPercentage ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2332) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2A4A62)
              : context.colors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Icon, Symbol, Type badge, Profit/Loss badge
                Row(
                  children: [
                    // Icon dengan gradient background
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors[0].withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          assetIcon,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                investment.symbol,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : context.colors.onSurface,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: investment.isCrypto
                                      ? Colors.orange.withValues(alpha: 0.15)
                                      : Colors.blue.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  investment.isCrypto ? 'CRYPTO' : 'SAHAM',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: investment.isCrypto
                                        ? Colors.orange
                                        : Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            investment.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white70
                                  : context.colors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Profit/Loss badge
                    if (hasPrice)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: investment.hasProfit
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              investment.hasProfit
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              size: 14,
                              color: investment.hasProfit
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            Text(
                              '${profitLossPercentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: investment.hasProfit
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 4),
                    // ⋮ Menu Edit & Delete
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        size: 20,
                        color: isDark ? Colors.white54 : context.colors.onSurfaceVariant,
                      ),
                      color: isDark ? const Color(0xFF243447) : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(children: [
                            const Icon(Icons.edit_rounded,
                                size: 18, color: Colors.orange),
                            const SizedBox(width: 10),
                            Text('Edit',
                                style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.w500)),
                          ]),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(children: [
                            const Icon(Icons.delete_outline_rounded,
                                size: 18, color: Colors.red),
                            const SizedBox(width: 10),
                            const Text('Hapus',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500)),
                          ]),
                        ),
                      ],
                      onSelected: (val) {
                        if (val == 'edit') {
                          onEdit?.call();
                        } else if (val == 'delete') {
                          onDelete?.call();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Quantity, Buy Price, Total Modal
                Row(
                  children: [
                    Expanded(
                      child: _infoTile(
                        context,
                        isDark,
                        label: investment.isCrypto ? 'Jumlah (koin)' : 'Jumlah (lot)',
                        value: investment.quantity.toStringAsFixed(
                          investment.isCrypto ? 6 : 2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _infoTile(
                        context,
                        isDark,
                        label: 'Harga Beli',
                        value: currencyFormat.format(investment.buyPrice),
                      ),
                    ),
                    Expanded(
                      child: _infoTile(
                        context,
                        isDark,
                        label: 'Total Modal',
                        value: currencyFormat.format(investment.totalCost),
                      ),
                    ),
                  ],
                ),

                if (hasPrice) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Current Price & Value
                  Row(
                    children: [
                      Expanded(
                        child: _infoTile(
                          context,
                          isDark,
                          label: 'Harga Sekarang',
                          value: currencyFormat.format(investment.currentPrice!),
                        ),
                      ),
                      Expanded(
                        child: _infoTile(
                          context,
                          isDark,
                          label: 'Nilai Sekarang',
                          value: currencyFormat.format(investment.currentValue!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Profit/Loss row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: investment.hasProfit
                            ? [
                                Colors.green.withValues(alpha: 0.12),
                                Colors.green.withValues(alpha: 0.05),
                              ]
                            : [
                                Colors.red.withValues(alpha: 0.12),
                                Colors.red.withValues(alpha: 0.05),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: investment.hasProfit
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              investment.hasProfit
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              size: 16,
                              color: investment.hasProfit
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              investment.hasProfit ? 'Untung' : 'Rugi',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: investment.hasProfit
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${investment.hasProfit ? '+' : ''}${currencyFormat.format(profitLoss)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: investment.hasProfit
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: isDark
                            ? Colors.white38
                            : context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Harga real-time belum tersedia',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white38
                              : context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut).slideY(begin: 0.1, end: 0);
  }

  Widget _infoTile(
    BuildContext context,
    bool isDark, {
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white38 : context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : context.colors.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
