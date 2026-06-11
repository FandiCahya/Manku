import 'package:flutter/material.dart';
import '../../domain/budget_models.dart';

/// Pure utility helpers for Budget UI — no widget state.
abstract class BudgetUiHelpers {
  BudgetUiHelpers._();

  /// Format a double as Indonesian Rupiah (e.g. "Rp 1.500.000").
  static String formatCurrency(double v) {
    final neg = v < 0;
    final parts = v.abs().toStringAsFixed(0).split('');
    final buf = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buf.write('.');
      buf.write(parts[i]);
    }
    return '${neg ? '-' : ''}Rp $buf';

  }

  static Color warningColor(BudgetWarningLevel level) {
    switch (level) {
      case BudgetWarningLevel.safe:
        return Colors.green.shade600;
      case BudgetWarningLevel.warning:
        return Colors.orange.shade600;
      case BudgetWarningLevel.critical:
        return Colors.deepOrange.shade600;
      case BudgetWarningLevel.exceeded:
        return Colors.red.shade700;
    }
  }

  static Color warningBg(BudgetWarningLevel level) {
    switch (level) {
      case BudgetWarningLevel.safe:
        return Colors.green.shade50;
      case BudgetWarningLevel.warning:
        return Colors.orange.shade50;
      case BudgetWarningLevel.critical:
        return Colors.deepOrange.shade50;
      case BudgetWarningLevel.exceeded:
        return Colors.red.shade50;
    }
  }

  static IconData warningIcon(BudgetWarningLevel level) {
    switch (level) {
      case BudgetWarningLevel.safe:
        return Icons.check_circle_outline;
      case BudgetWarningLevel.warning:
        return Icons.warning_amber_outlined;
      case BudgetWarningLevel.critical:
        return Icons.error_outline;
      case BudgetWarningLevel.exceeded:
        return Icons.cancel_outlined;
    }
  }

  static IconData iconForCategory(String name) {
    final lower = name.toLowerCase();
    const map = <String, IconData>{
      'makanan': Icons.restaurant,
      'food': Icons.restaurant,
      'makan': Icons.restaurant,
      'minuman': Icons.local_cafe,
      'transportasi': Icons.directions_car,
      'transport': Icons.directions_car,
      'bensin': Icons.local_gas_station,
      'belanja': Icons.shopping_bag,
      'shopping': Icons.shopping_bag,
      'hiburan': Icons.celebration,
      'entertainment': Icons.celebration,
      'tagihan': Icons.receipt_long,
      'bills': Icons.receipt_long,
      'listrik': Icons.bolt,
      'internet': Icons.wifi,
      'kesehatan': Icons.health_and_safety,
      'health': Icons.health_and_safety,
      'gaji': Icons.payments,
      'salary': Icons.payments,
      'pendidikan': Icons.school,
      'education': Icons.school,
    };
    for (final key in map.keys) {
      if (lower.contains(key)) return map[key]!;
    }
    return Icons.account_balance_wallet_outlined;
  }
}
