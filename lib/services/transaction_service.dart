import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../core/constants/api_config.dart';
import '../core/network/api_client.dart';
import '../core/database/db_helper.dart';
import '../models/dashboard_summary.dart';
import '../models/transaction_api.dart';
import '../models/report_summary.dart';

class TransactionService {

  // ── 1. TAMBAH TRANSAKSI ────────────────────────────────────────────────────
  static Future<void> addTransaction({
    required String description,
    required double amount,
    required String categoryType,
    required String categoryName,
    required String inputSource,
  }) async {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final timeStr = DateFormat('HH:mm').format(now);

    if (kIsWeb) {
      // Web: langsung ke API
      await ApiClient.dio.post<Map<String, dynamic>>(
        ApiConfig.saveTransactionEndpoint,
        data: {
          'amount': amount.toString(),
          'category_hint': categoryName,
          'description': description,
          'date': dateStr,
          'time': timeStr,
          'type': categoryType,
          'category_type': categoryType,
          'transaction_type': categoryType,
          'input_source': inputSource,
        },
      );
      return;
    }

    // Native: simpan lokal dulu, lalu sync
    final row = {
      DatabaseHelper.columnDescription: description,
      DatabaseHelper.columnAmount: amount,
      DatabaseHelper.columnCategoryType: categoryType,
      DatabaseHelper.columnCategoryName: categoryName,
      DatabaseHelper.columnDate: dateStr,
      DatabaseHelper.columnTime: timeStr,
      DatabaseHelper.columnInputSource: inputSource,
      DatabaseHelper.columnIsSynced: 0,
      DatabaseHelper.columnCreatedAt: now.toIso8601String(),
    };

    final localId = await DatabaseHelper.instance.insertTransaction(row);

    try {
      final response = await ApiClient.dio.post<Map<String, dynamic>>(
        ApiConfig.saveTransactionEndpoint,
        data: {
          'id': localId,
          'amount': amount.toString(),
          'category_hint': categoryName,
          'description': description,
          'date': dateStr,
          'time': timeStr,
          'type': categoryType,
          'category_type': categoryType,
          'transaction_type': categoryType,
          'input_source': inputSource,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final db = await DatabaseHelper.instance.database;
        await db.update(
          DatabaseHelper.tableTransactions,
          {DatabaseHelper.columnIsSynced: 1},
          where: '${DatabaseHelper.columnId} = ?',
          whereArgs: [localId],
        );
      }
    } catch (e) {
      debugPrint('Sync failed (will remain offline in SQLite): $e');
    }
  }

  // ── 2. GET DASHBOARD SUMMARY ──────────────────────────────────────────────
  static Future<DashboardSummary> fetchDashboardSummary() async {
    if (kIsWeb) {
      // Web: ambil dari API
      try {
        final resp = await ApiClient.dio
            .get<Map<String, dynamic>>(ApiConfig.dashboardSummaryEndpoint);
        final data = resp.data ?? {};
        return DashboardSummary.fromJson(data);
      } catch (e) {
        debugPrint('fetchDashboardSummary (Web) error: $e');
        return DashboardSummary(
          totalBalance: 0,
          dailyExpense: 0,
          budgetLeft: 0,
          totalIncome: 0,
          spendingTrends: [],
        );
      }
    }

    // Native: dari SQLite lokal
    try {
      final rows = await DatabaseHelper.instance.queryAllTransactions();

      double totalIncome = 0;
      double totalExpense = 0;
      double dailyExpense = 0;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      Map<String, double> expensesByDay = {};

      for (var row in rows) {
        final double amount = row[DatabaseHelper.columnAmount] as double;
        final String type = row[DatabaseHelper.columnCategoryType] as String;
        final String date = row[DatabaseHelper.columnDate] as String;

        if (type == 'income') {
          totalIncome += amount;
        } else {
          totalExpense += amount;
          if (date == today) dailyExpense += amount;
          expensesByDay[date] = (expensesByDay[date] ?? 0) + amount;
        }
      }

      double totalBalance = totalIncome - totalExpense;
      double budgetLeft = totalIncome > 0 ? (totalIncome - totalExpense) : 0;
      if (budgetLeft < 0) budgetLeft = 0;

      final sortedDates = expensesByDay.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      final recentDates = sortedDates.take(7).toList();

      List<SpendingTrendDay> trends = recentDates.map((dateStr) {
        final dateObj = DateTime.parse(dateStr);
        return SpendingTrendDay(
          day: DateFormat('EEE').format(dateObj),
          date: dateStr,
          amount: expensesByDay[dateStr]!,
        );
      }).toList();

      return DashboardSummary(
        totalBalance: totalBalance,
        dailyExpense: dailyExpense,
        budgetLeft: budgetLeft,
        totalIncome: totalIncome,
        spendingTrends: trends,
      );
    } catch (e) {
      debugPrint('fetchDashboardSummary (Local) error: $e');
      rethrow;
    }
  }

  // ── 3. GET HISTORY TRANSAKSI ──────────────────────────────────────────────
  static Future<TransactionHistory> fetchHistory() async {
    if (kIsWeb) {
      // Web: ambil dari API
      try {
        final resp = await ApiClient.dio
            .get<Map<String, dynamic>>(ApiConfig.transactionHistoryEndpoint);
        final data = resp.data ?? {};
        return TransactionHistory.fromJson(data);
      } catch (e) {
        debugPrint('fetchHistory (Web) error: $e');
        return TransactionHistory(totalTransactions: 0, groups: []);
      }
    }

    // Native: dari SQLite lokal
    try {
      final rows = await DatabaseHelper.instance.queryAllTransactions();

      Map<String, List<ApiTransaction>> grouped = {};
      int totalCount = rows.length;

      for (var row in rows) {
        final date = row[DatabaseHelper.columnDate] as String;
        final t = ApiTransaction(
          id: row[DatabaseHelper.columnId] as String,
          description: row[DatabaseHelper.columnDescription] as String,
          categoryName: row[DatabaseHelper.columnCategoryName] as String,
          categoryType: row[DatabaseHelper.columnCategoryType] as String,
          amount: row[DatabaseHelper.columnAmount] as double,
          time: row[DatabaseHelper.columnTime] as String,
          inputSource: row[DatabaseHelper.columnInputSource] as String,
        );

        if (!grouped.containsKey(date)) grouped[date] = [];
        grouped[date]!.add(t);
      }

      List<TransactionGroup> groups = grouped.entries.map((e) {
        final dateObj = DateTime.parse(e.key);
        final now = DateTime.now();
        final diff = DateTime(now.year, now.month, now.day)
            .difference(
                DateTime(dateObj.year, dateObj.month, dateObj.day))
            .inDays;

        String label = e.key;
        if (diff == 0) {
          label = 'Hari ini';
        } else if (diff == 1) {
          label = 'Kemarin';
        } else {
          label = DateFormat('dd MMM yyyy').format(dateObj);
        }

        return TransactionGroup(
          dateLabel: label,
          date: e.key,
          transactions: e.value,
        );
      }).toList();

      groups.sort((a, b) => b.date.compareTo(a.date));

      return TransactionHistory(
        totalTransactions: totalCount,
        groups: groups,
      );
    } catch (e) {
      debugPrint('fetchHistory (Local) error: $e');
      rethrow;
    }
  }

  // ── 4. GET REPORT SUMMARY ─────────────────────────────────────────────────
  static Future<ReportSummary> fetchReportSummary() async {
    if (kIsWeb) {
      try {
        final resp = await ApiClient.dio
            .get<Map<String, dynamic>>(ApiConfig.reportSummaryEndpoint);
        final data = resp.data ?? {};
        return ReportSummary.fromJson(data);
      } catch (e) {
        debugPrint('fetchReportSummary (Web) error: $e');
        return ReportSummary(
          totalSpending: 0,
          categoryBreakdown: [],
          performanceSixMonths: [],
          performanceMaxAmount: 1,
        );
      }
    }

    // Native: dari SQLite lokal
    try {
      final rows = await DatabaseHelper.instance.queryAllTransactions();

      double totalSpending = 0;
      Map<String, double> expByCat = {};
      Map<String, int> countByCat = {};

      for (var row in rows) {
        final double amount = row[DatabaseHelper.columnAmount] as double;
        final String type = row[DatabaseHelper.columnCategoryType] as String;
        final String catName =
            row[DatabaseHelper.columnCategoryName] as String;

        if (type == 'expense') {
          totalSpending += amount;
          expByCat[catName] = (expByCat[catName] ?? 0) + amount;
          countByCat[catName] = (countByCat[catName] ?? 0) + 1;
        }
      }

      List<CategoryBreakdownItem> categoryBreakdown =
          expByCat.entries.map((e) {
        double percentage =
            totalSpending > 0 ? (e.value / totalSpending) : 0;
        return CategoryBreakdownItem(
          name: e.key,
          amount: e.value,
          count: countByCat[e.key] ?? 0,
          percentage: percentage,
        );
      }).toList();

      categoryBreakdown.sort((a, b) => b.amount.compareTo(a.amount));

      List<PerformanceMonth> performanceSixMonths = [];
      final now = DateTime.now();
      for (int i = 5; i >= 0; i--) {
        final d = DateTime(now.year, now.month - i, 1);
        performanceSixMonths.add(
          PerformanceMonth(
            month: DateFormat('MMM').format(d),
            year: d.year,
            amount: 0,
            isCurrent: i == 0,
          ),
        );
      }

      return ReportSummary(
        totalSpending: totalSpending,
        categoryBreakdown: categoryBreakdown,
        performanceSixMonths: performanceSixMonths,
        performanceMaxAmount: 1.0,
      );
    } catch (e) {
      debugPrint('fetchReportSummary (Local) error: $e');
      rethrow;
    }
  }

  // ── 5. UBAH TRANSAKSI ─────────────────────────────────────────────────────
  static Future<void> updateTransaction({
    required String id,
    required String description,
    required double amount,
    required String categoryType,
    required String categoryName,
    required String date,
    required String time,
    required String inputSource,
  }) async {
    if (kIsWeb) {
      await ApiClient.dio.put<Map<String, dynamic>>(
        ApiConfig.updateTransactionEndpoint(id),
        data: {
          'amount': amount.toString(),
          'category_hint': categoryName,
          'description': description,
          'date': date,
          'time': time,
          'type': categoryType,
          'category_type': categoryType,
          'transaction_type': categoryType,
        },
      );
      return;
    }

    final db = await DatabaseHelper.instance.database;
    await db.update(
      DatabaseHelper.tableTransactions,
      {
        DatabaseHelper.columnDescription: description,
        DatabaseHelper.columnAmount: amount,
        DatabaseHelper.columnCategoryType: categoryType,
        DatabaseHelper.columnCategoryName: categoryName,
        DatabaseHelper.columnDate: date,
        DatabaseHelper.columnTime: time,
        DatabaseHelper.columnInputSource: inputSource,
        DatabaseHelper.columnIsSynced: 0,
      },
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [id],
    );

    try {
      final response = await ApiClient.dio.put<Map<String, dynamic>>(
        ApiConfig.updateTransactionEndpoint(id),
        data: {
          'amount': amount.toString(),
          'category_hint': categoryName,
          'description': description,
          'date': date,
          'time': time,
          'type': categoryType,
          'category_type': categoryType,
          'transaction_type': categoryType,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await db.update(
          DatabaseHelper.tableTransactions,
          {DatabaseHelper.columnIsSynced: 1},
          where: '${DatabaseHelper.columnId} = ?',
          whereArgs: [id],
        );
      }
    } catch (e) {
      debugPrint('Sync update failed (will remain offline in SQLite): $e');
    }
  }

  // ── 6. HAPUS TRANSAKSI ────────────────────────────────────────────────────
  static Future<void> deleteTransaction(String id) async {
    if (!kIsWeb) {
      await DatabaseHelper.instance.deleteTransaction(id);
    }

    try {
      await ApiClient.dio.delete<dynamic>(
        ApiConfig.deleteTransactionEndpoint(id),
      );
    } catch (e) {
      debugPrint('Sync delete failed: $e');
    }
  }
}
