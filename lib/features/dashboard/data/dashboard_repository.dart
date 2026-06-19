import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../models/dashboard_summary.dart';

/// Repository for Dashboard HTTP calls using Dio client.
class DashboardRepository {
  DashboardRepository._();

  static Future<DashboardSummary> fetchDashboardSummary() async {
    try {
      // Use flat /api/transactions/ list which reliably returns category_type.
      // The dedicated dashboard-summary endpoint may return 0 values when the
      // backend aggregation is misconfigured.
      final response = await ApiClient.dio.get<dynamic>(
        ApiConfig.transactionListEndpoint,
      );

      // Handle both flat list [ {...} ] and paginated { results: [...] }
      final List<dynamic> rawList = response.data is List
          ? response.data as List<dynamic>
          : (response.data as Map<String, dynamic>)['results']
                  as List<dynamic>? ??
              [];

      double totalIncome = 0;
      double totalExpense = 0;
      double dailyExpense = 0;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final Map<String, double> expensesByDay = {};

      for (final item in rawList) {
        final map = item as Map<String, dynamic>;

        final double amount =
            double.tryParse(map['amount']?.toString() ?? '0') ?? 0;

        // Normalise type — try every possible field name
        final String typeLower =
            ((map['category_type'] ?? map['transaction_type'] ?? map['type'])
                        as String? ??
                    'expense')
                .toLowerCase()
                .trim();

        // API returns ISO date "2026-06-19T00:00:00Z" — take first 10 chars
        final rawDate =
            map['transaction_date'] as String? ?? map['date'] as String? ?? today;
        final dateOnly =
            rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;

        debugPrint(
          '💰 Dashboard row: "${map['description']}" type=$typeLower amount=$amount date=$dateOnly',
        );

        if (typeLower == 'income') {
          totalIncome += amount;
        } else {
          totalExpense += amount;
          if (dateOnly == today) dailyExpense += amount;
          expensesByDay[dateOnly] = (expensesByDay[dateOnly] ?? 0) + amount;
        }
      }

      final totalBalance = totalIncome - totalExpense;
      debugPrint(
        '💰 Dashboard computed: income=$totalIncome expense=$totalExpense balance=$totalBalance',
      );

      // Build spending trend for the last 7 days (including empty ones)
      final List<SpendingTrendDay> trends = [];
      final now = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        trends.add(SpendingTrendDay(
          day: DateFormat('EEE').format(date),
          date: dateStr,
          amount: expensesByDay[dateStr] ?? 0,
        ));
      }

      return DashboardSummary(
        totalBalance: totalBalance,
        dailyExpense: dailyExpense,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        spendingTrends: trends,
      );
    } catch (e) {
      debugPrint('fetchDashboardSummary exception: $e');
      rethrow;
    }
  }
}
