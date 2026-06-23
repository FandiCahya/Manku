import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../core/constants/api_config.dart';
import '../core/network/api_client.dart';
import '../core/database/db_helper.dart';
import '../models/dashboard_summary.dart';
import '../models/transaction_api.dart';
import '../models/report_summary.dart';
import '../features/transactions/domain/chat_transaction_response.dart';
import '../widgets/debug_info_overlay.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

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
      debugLog('💾 Web: ========== SAVING TO API ==========');
      debugLog('   Description: $description');
      debugLog('   Amount: Rp ${amount.toStringAsFixed(0)}');
      debugLog('   Type: "$categoryType" (length: ${categoryType.length})');
      debugLog('   Category: $categoryName');
      debugLog('   Date: $dateStr at $timeStr');

      final response = await ApiClient.dio.post<Map<String, dynamic>>(
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

      debugLog('   ✅ Saved to API successfully');
      debugLog('   Response Status: ${response.statusCode}');
      debugLog('==========================================');
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

    debugLog('💾 ========== SAVING TRANSACTION ==========');
    debugLog('   Description: $description');
    debugLog('   Amount: Rp ${amount.toStringAsFixed(0)}');
    debugLog('   Type: "$categoryType" (length: ${categoryType.length})');
    debugLog('   Category: $categoryName');
    debugLog('   Date: $dateStr at $timeStr');
    debugLog('   Input Source: $inputSource');

    final localId = await DatabaseHelper.instance.insertTransaction(row);
    debugLog('   ✅ Saved to Database with ID: $localId');
    debugLog('   Database Location: Local SQLite');
    debugLog('=========================================');

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
      try {
        debugLog('💰 Web: Fetching transactions list for dashboard...');
        // Use the flat list endpoint which reliably returns category_type
        final resp = await ApiClient.dio.get<dynamic>(
          ApiConfig.transactionListEndpoint,
        );

        final List<dynamic> rawList = resp.data is List
            ? resp.data as List<dynamic>
            : (resp.data as Map<String, dynamic>)['results'] as List<dynamic>? ?? [];

        debugLog('💰 Web: Got ${rawList.length} transactions');

        double totalIncome = 0;
        double totalExpense = 0;
        double dailyExpense = 0;
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        Map<String, double> expensesByDay = {};

        for (final item in rawList) {
          final map = item as Map<String, dynamic>;
          final double amount = double.tryParse(map['amount']?.toString() ?? '0') ?? 0;
          // Normalise type — API may return 'income' or 'expense'
          final String typeLower =
              ((map['category_type'] ?? map['transaction_type'] ?? map['type']) as String? ?? 'expense')
              .toLowerCase()
              .trim();
          // Parse date — API returns ISO: "2026-06-19T00:00:00Z"
          final rawDate = map['transaction_date'] as String? ?? map['date'] as String? ?? today;
          final dateOnly = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;

          debugLog('💰 "${map['description']}": type=$typeLower amount=$amount date=$dateOnly');

          if (typeLower == 'income') {
            totalIncome += amount;
          } else {
            totalExpense += amount;
            if (dateOnly == today) dailyExpense += amount;
            expensesByDay[dateOnly] = (expensesByDay[dateOnly] ?? 0) + amount;
          }
        }

        final totalBalance = totalIncome - totalExpense;
        debugLog('💰 Dashboard: Income=Rp${totalIncome.toStringAsFixed(0)} Expense=Rp${totalExpense.toStringAsFixed(0)} Balance=Rp${totalBalance.toStringAsFixed(0)}');

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
        debugPrint('fetchDashboardSummary (Web) error: $e');
        debugLog('💰 Web: ERROR fetching dashboard - $e');
        return DashboardSummary(
          totalBalance: 0,
          dailyExpense: 0,
          totalIncome: 0,
          totalExpense: 0,
          spendingTrends: [],
        );
      }
    }

    // Native: dari SQLite lokal
    try {
      final rows = await DatabaseHelper.instance.queryAllTransactions();

      debugLog('💰 Dashboard: Loading transactions from database');
      debugLog('   Total rows in database: ${rows.length}');

      double totalIncome = 0;
      double totalExpense = 0;
      double dailyExpense = 0;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      Map<String, double> expensesByDay = {};

      for (var i = 0; i < rows.length; i++) {
        final row = rows[i];
        final double amount = row[DatabaseHelper.columnAmount] as double;
        final String type = row[DatabaseHelper.columnCategoryType] as String;
        final String date = row[DatabaseHelper.columnDate] as String;
        final String desc = row[DatabaseHelper.columnDescription] as String;
        final String category =
            row[DatabaseHelper.columnCategoryName] as String;

        debugLog('💰 Row ${i + 1}: "$desc"');
        debugLog('   Category: $category');
        debugLog('   Type from DB: "$type" (length: ${type.length})');
        debugLog('   Amount: Rp ${amount.toStringAsFixed(0)}');
        debugLog('   Date: $date');

        // Case-insensitive comparison to handle potential issues
        final typeLower = type.toLowerCase().trim();
        if (typeLower == 'income') {
          totalIncome += amount;
          debugLog(
            '   ✅ Added to INCOME (Total now: Rp ${totalIncome.toStringAsFixed(0)})',
          );
        } else if (typeLower == 'expense') {
          totalExpense += amount;
          if (date == today) dailyExpense += amount;
          expensesByDay[date] = (expensesByDay[date] ?? 0) + amount;
          debugLog(
            '   ✅ Added to EXPENSE (Total now: Rp ${totalExpense.toStringAsFixed(0)})',
          );
        } else {
          debugLog('   ⚠️ UNKNOWN TYPE: "$type" - Treating as EXPENSE');
          totalExpense += amount;
          if (date == today) dailyExpense += amount;
          expensesByDay[date] = (expensesByDay[date] ?? 0) + amount;
        }
      }

      debugLog('📊 Dashboard Summary:');
      debugLog('   💵 Total Income: Rp ${totalIncome.toStringAsFixed(0)}');
      debugLog('   💸 Total Expense: Rp ${totalExpense.toStringAsFixed(0)}');
      debugLog(
        '   💰 Balance: Rp ${(totalIncome - totalExpense).toStringAsFixed(0)}',
      );
      debugLog('   📅 Today\'s Expense: Rp ${dailyExpense.toStringAsFixed(0)}');

      double totalBalance = totalIncome - totalExpense;
      double budgetLeft = totalIncome > 0 ? (totalIncome - totalExpense) : 0;
      if (budgetLeft < 0) budgetLeft = 0;

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
      debugPrint('fetchDashboardSummary (Local) error: $e');
      rethrow;
    }
  }

  // ── 3. GET HISTORY TRANSAKSI ──────────────────────────────────────────────
  static Future<TransactionHistory> fetchHistory() async {
    if (kIsWeb) {
      try {
        final resp = await ApiClient.dio.get<dynamic>(
          ApiConfig.transactionListEndpoint,
        );

        final List<dynamic> rawList = resp.data is List
            ? resp.data as List<dynamic>
            : (resp.data as Map<String, dynamic>)['results'] as List<dynamic>? ?? [];

        Map<String, List<ApiTransaction>> grouped = {};

        for (final item in rawList) {
          final map = item as Map<String, dynamic>;
          // Parse ISO date "2026-06-19T00:00:00Z" → "2026-06-19"
          final rawDate = map['transaction_date'] as String? ?? map['date'] as String? ?? '';
          final dateOnly = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;

          final rawType = ((map['category_type'] ?? map['transaction_type'] ?? map['type']) as String? ?? 'expense')
              .toLowerCase()
              .trim();

          final t = ApiTransaction(
            id: (map['id'] ?? '').toString(),
            description: map['description'] as String? ?? '',
            categoryName: map['category_name'] as String? ?? 'Lainnya',
            categoryType: rawType,
            amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0,
            time: map['time'] as String? ?? '',
            inputSource: map['input_source'] as String? ?? 'manual',
          );

          if (!grouped.containsKey(dateOnly)) grouped[dateOnly] = [];
          grouped[dateOnly]!.add(t);
        }

        final now = DateTime.now();
        List<TransactionGroup> groups = grouped.entries.map((e) {
          final dateObj = DateTime.parse(e.key);
          final diff = DateTime(now.year, now.month, now.day)
              .difference(DateTime(dateObj.year, dateObj.month, dateObj.day))
              .inDays;
          String label;
          if (diff == 0) {
            label = 'Hari ini';
          } else if (diff == 1) {
            label = 'Kemarin';
          } else {
            label = DateFormat('dd MMM yyyy').format(dateObj);
          }
          return TransactionGroup(dateLabel: label, date: e.key, transactions: e.value);
        }).toList();

        groups.sort((a, b) => b.date.compareTo(a.date));

        return TransactionHistory(totalTransactions: rawList.length, groups: groups);
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
        final diff = DateTime(
          now.year,
          now.month,
          now.day,
        ).difference(DateTime(dateObj.year, dateObj.month, dateObj.day)).inDays;

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

      return TransactionHistory(totalTransactions: totalCount, groups: groups);
    } catch (e) {
      debugPrint('fetchHistory (Local) error: $e');
      rethrow;
    }
  }

  // ── 4. GET REPORT SUMMARY ─────────────────────────────────────────────────
  static Future<ReportSummary> fetchReportSummary() async {
    if (kIsWeb) {
      try {
        debugLog('📈 Web: Fetching transactions list for report...');
        final resp = await ApiClient.dio.get<dynamic>(
          ApiConfig.transactionListEndpoint,
        );

        final List<dynamic> rawList = resp.data is List
            ? resp.data as List<dynamic>
            : (resp.data as Map<String, dynamic>)['results'] as List<dynamic>? ?? [];

        debugLog('📈 Web: Got ${rawList.length} transactions');

        double totalSpending = 0;
        double totalIncome = 0;
        final Map<String, double> expByCat = {};
        final Map<String, int> countExpByCat = {};
        final Map<String, double> incByCat = {};
        final Map<String, int> countIncByCat = {};
        final Map<String, double> incomeByMonth = {};
        final Map<String, double> expenseByMonth = {};

        for (final item in rawList) {
          final map = item as Map<String, dynamic>;
          final double amount =
              double.tryParse(map['amount']?.toString() ?? '0') ?? 0;
          final String catName =
              map['category_name'] as String? ?? 'Lainnya';
          final String typeLower =
              ((map['category_type'] ?? map['transaction_type'] ?? map['type'])
                          as String? ??
                      'expense')
                  .toLowerCase()
                  .trim();

          // Parse ISO date "2026-06-19T00:00:00Z" → month key "2026-06"
          final rawDate = map['transaction_date'] as String? ??
              map['date'] as String? ??
              '';
          final dateOnly =
              rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;
          final monthKey =
              dateOnly.length >= 7 ? dateOnly.substring(0, 7) : dateOnly;

          debugLog(
            '📈 "${map['description']}": type=$typeLower cat=$catName amount=$amount month=$monthKey',
          );

          if (typeLower == 'income') {
            totalIncome += amount;
            incByCat[catName] = (incByCat[catName] ?? 0) + amount;
            countIncByCat[catName] = (countIncByCat[catName] ?? 0) + 1;
            incomeByMonth[monthKey] = (incomeByMonth[monthKey] ?? 0) + amount;
          } else {
            totalSpending += amount;
            expByCat[catName] = (expByCat[catName] ?? 0) + amount;
            countExpByCat[catName] = (countExpByCat[catName] ?? 0) + 1;
            expenseByMonth[monthKey] =
                (expenseByMonth[monthKey] ?? 0) + amount;
          }
        }

        debugLog(
          '📈 Report: income=$totalIncome expense=$totalSpending incCats=${incByCat.length} expCats=${expByCat.length}',
        );

        // Build category lists
        final incomeCategories = incByCat.entries.map((e) {
          return CategoryBreakdownItem(
            name: e.key,
            amount: e.value,
            count: countIncByCat[e.key] ?? 0,
            percentage: totalIncome > 0 ? e.value / totalIncome : 0,
            type: 'income',
          );
        }).toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

        final expenseCategories = expByCat.entries.map((e) {
          return CategoryBreakdownItem(
            name: e.key,
            amount: e.value,
            count: countExpByCat[e.key] ?? 0,
            percentage: totalSpending > 0 ? e.value / totalSpending : 0,
            type: 'expense',
          );
        }).toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

        // Build 6-month performance
        final now = DateTime.now();
        double maxAmount = 1.0;
        final List<PerformanceMonth> performanceSixMonths = [];
        for (int i = 5; i >= 0; i--) {
          final d = DateTime(now.year, now.month - i, 1);
          final mk = DateFormat('yyyy-MM').format(d);
          final income = incomeByMonth[mk] ?? 0;
          final expense = expenseByMonth[mk] ?? 0;
          if (income > maxAmount) maxAmount = income;
          if (expense > maxAmount) maxAmount = expense;
          performanceSixMonths.add(PerformanceMonth(
            month: DateFormat('MMM').format(d),
            year: d.year,
            amount: expense,
            income: income,
            expense: expense,
            isCurrent: i == 0,
          ));
        }

        return ReportSummary(
          totalSpending: totalSpending,
          categoryBreakdown: [...incomeCategories, ...expenseCategories],
          performanceSixMonths: performanceSixMonths,
          performanceMaxAmount: maxAmount,
        );
      } catch (e) {
        debugPrint('fetchReportSummary (Web) error: $e');
        debugLog('📈 Web: ERROR fetching report - $e');
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
      double totalIncome = 0;
      Map<String, double> expByCat = {};
      Map<String, int> countExpByCat = {};
      Map<String, double> incByCat = {};
      Map<String, int> countIncByCat = {};
      Map<String, double> incomeByMonth = {}; // New: track income per month
      Map<String, double> expenseByMonth = {}; // New: track expense per month

      debugLog('📈 Report: Reading ${rows.length} transactions from database');

      for (var i = 0; i < rows.length; i++) {
        final row = rows[i];
        final double amount = row[DatabaseHelper.columnAmount] as double;
        final String type = row[DatabaseHelper.columnCategoryType] as String;
        final String catName = row[DatabaseHelper.columnCategoryName] as String;
        final String date = row[DatabaseHelper.columnDate] as String;
        final String desc = row[DatabaseHelper.columnDescription] as String;

        debugLog('📈 Row ${i + 1}: $desc');
        debugLog(
          '   Category: $catName | Type: "$type" | Amount: Rp ${amount.toStringAsFixed(0)}',
        );

        // Get year-month key for grouping
        final dateObj = DateTime.parse(date);
        final monthKey = DateFormat('yyyy-MM').format(dateObj);

        // Case-insensitive comparison
        final typeLower = type.toLowerCase().trim();
        if (typeLower == 'expense') {
          totalSpending += amount;
          expByCat[catName] = (expByCat[catName] ?? 0) + amount;
          countExpByCat[catName] = (countExpByCat[catName] ?? 0) + 1;
          expenseByMonth[monthKey] = (expenseByMonth[monthKey] ?? 0) + amount;
          debugLog(
            '   ✅ Added to EXPENSE category (Total Expense: Rp ${totalSpending.toStringAsFixed(0)})',
          );
        } else if (typeLower == 'income') {
          totalIncome += amount;
          incByCat[catName] = (incByCat[catName] ?? 0) + amount;
          countIncByCat[catName] = (countIncByCat[catName] ?? 0) + 1;
          incomeByMonth[monthKey] = (incomeByMonth[monthKey] ?? 0) + amount;
          debugLog(
            '   ✅ Added to INCOME category (Total Income: Rp ${totalIncome.toStringAsFixed(0)})',
          );
        } else {
          debugLog('   ⚠️ UNKNOWN TYPE: "$type" - Treating as EXPENSE');
          totalSpending += amount;
          expByCat[catName] = (expByCat[catName] ?? 0) + amount;
          countExpByCat[catName] = (countExpByCat[catName] ?? 0) + 1;
          expenseByMonth[monthKey] = (expenseByMonth[monthKey] ?? 0) + amount;
        }
      }

      debugLog('📈 Report Summary:');
      debugLog('   💸 Total Expense: Rp ${totalSpending.toStringAsFixed(0)}');
      debugLog('   💵 Total Income: Rp ${totalIncome.toStringAsFixed(0)}');
      debugLog('   📦 Income Categories: ${incByCat.length}');
      debugLog('   📦 Expense Categories: ${expByCat.length}');

      // Build category breakdown for expenses
      List<CategoryBreakdownItem> expenseCategories = expByCat.entries.map((e) {
        double percentage = totalSpending > 0 ? (e.value / totalSpending) : 0;
        return CategoryBreakdownItem(
          name: e.key,
          amount: e.value,
          count: countExpByCat[e.key] ?? 0,
          percentage: percentage,
          type: 'expense',
        );
      }).toList();
      expenseCategories.sort((a, b) => b.amount.compareTo(a.amount));

      // Build category breakdown for income
      List<CategoryBreakdownItem> incomeCategories = incByCat.entries.map((e) {
        double percentage = totalIncome > 0 ? (e.value / totalIncome) : 0;
        return CategoryBreakdownItem(
          name: e.key,
          amount: e.value,
          count: countIncByCat[e.key] ?? 0,
          percentage: percentage,
          type: 'income',
        );
      }).toList();
      incomeCategories.sort((a, b) => b.amount.compareTo(a.amount));

      // Combine both income and expense categories
      List<CategoryBreakdownItem> categoryBreakdown = [
        ...incomeCategories,
        ...expenseCategories,
      ];

      // Build performance for last 6 months with income and expense
      List<PerformanceMonth> performanceSixMonths = [];
      double maxAmount = 1.0;
      final now = DateTime.now();
      for (int i = 5; i >= 0; i--) {
        final d = DateTime(now.year, now.month - i, 1);
        final monthKey = DateFormat('yyyy-MM').format(d);
        final income = incomeByMonth[monthKey] ?? 0;
        final expense = expenseByMonth[monthKey] ?? 0;

        // Update max amount untuk scaling chart
        if (income > maxAmount) maxAmount = income;
        if (expense > maxAmount) maxAmount = expense;

        performanceSixMonths.add(
          PerformanceMonth(
            month: DateFormat('MMM').format(d),
            year: d.year,
            amount:
                expense, // keep amount as expense for backward compatibility
            income: income,
            expense: expense,
            isCurrent: i == 0,
          ),
        );
      }

      return ReportSummary(
        totalSpending: totalSpending,
        categoryBreakdown: categoryBreakdown,
        performanceSixMonths: performanceSixMonths,
        performanceMaxAmount: maxAmount,
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

  // ── 7. CHAT TRANSACTION ────────────────────────────────────────────────────
  static Future<ChatTransactionResponse> saveChatTransaction(
    String text,
  ) async {
    try {
      final response = await ApiClient.dio.post<Map<String, dynamic>>(
        ApiConfig.saveChatTransactionEndpoint,
        data: {'text': text},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data == null) {
          throw Exception('Response data is null');
        }
        return ChatTransactionResponse.fromJson(data);
      } else {
        throw Exception(
          'Failed to save chat transaction: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('saveChatTransaction error: $e');
      rethrow;
    }
  }

  // ── 8. SCAN RECEIPT ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> scanReceipt(XFile image) async {
    try {
      final formData = FormData.fromMap({
        'receipt_image': await MultipartFile.fromFile(
          image.path,
          filename: image.name,
        ),
      });

      final response = await ApiClient.dio.post<Map<String, dynamic>>(
        ApiConfig.scanReceiptEndpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint('scanReceipt error: $e');
      rethrow;
    }
  }
}
