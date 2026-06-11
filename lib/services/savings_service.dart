import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_config.dart';
import '../models/savings_goal.dart';
import '../models/budget_goal.dart';

class SavingsService {
  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── SAVINGS OVERVIEW ─────────────────────────────────────────────────────
  static Future<SavingsOverview> fetchSavingsOverview() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse(ApiConfig.savingsOverviewEndpoint),
      headers: headers,
    );
    if (res.statusCode == 200) {
      return SavingsOverview.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Gagal memuat savings overview (${res.statusCode})');
  }

  // ── SAVINGS GOALS CRUD ────────────────────────────────────────────────────
  static Future<List<SavingsGoalModel>> fetchSavingsGoals() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse(ApiConfig.savingsGoalsEndpoint),
      headers: headers,
    );
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list
          .map((e) => SavingsGoalModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Gagal memuat savings goals (${res.statusCode})');
  }

  /// Buat savings goal baru
  static Future<SavingsGoalModel> createSavingsGoal({
    required String name,
    required double targetAmount,
    double currentAmount = 0,
    String? deadline,
    String? description,
    String color = '#4A90D9',
    String icon = 'savings',
  }) async {
    final headers = await _authHeaders();
    final body = jsonEncode({
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      if (deadline != null) 'deadline': deadline,
      if (description != null && description.isNotEmpty)
        'description': description,
      'color': color,
      'icon': icon,
    });

    final res = await http.post(
      Uri.parse(ApiConfig.savingsGoalsEndpoint),
      headers: headers,
      body: body,
    );

    if (res.statusCode == 201) {
      return SavingsGoalModel.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
    }
    debugPrint('createSavingsGoal error: ${res.statusCode} - ${res.body}');
    throw Exception('Gagal membuat savings goal (${res.statusCode})');
  }

  /// Update savings goal
  static Future<SavingsGoalModel> updateSavingsGoal(
    String id, {
    String? name,
    double? targetAmount,
    String? deadline,
    String? description,
    String? color,
    String? icon,
  }) async {
    final headers = await _authHeaders();
    final body = jsonEncode({
      if (name != null) 'name': name,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (deadline != null) 'deadline': deadline,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
    });

    final res = await http.patch(
      Uri.parse(ApiConfig.savingsGoalDetailEndpoint(id)),
      headers: headers,
      body: body,
    );

    if (res.statusCode == 200) {
      return SavingsGoalModel.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Gagal mengupdate savings goal (${res.statusCode})');
  }

  /// Tambah dana ke savings goal
  static Future<SavingsGoalModel> addFunds(
      String goalId, double amount) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse(ApiConfig.savingsGoalAddFundsEndpoint(goalId)),
      headers: headers,
      body: jsonEncode({'amount': amount}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return SavingsGoalModel.fromJson(
          data['goal'] as Map<String, dynamic>);
    }
    final err = jsonDecode(res.body)['error'] ?? 'Error ${res.statusCode}';
    throw Exception(err);
  }

  /// Tarik dana dari savings goal
  static Future<SavingsGoalModel> withdrawFunds(
      String goalId, double amount) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse(ApiConfig.savingsGoalWithdrawEndpoint(goalId)),
      headers: headers,
      body: jsonEncode({'amount': amount}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return SavingsGoalModel.fromJson(
          data['goal'] as Map<String, dynamic>);
    }
    final err = jsonDecode(res.body)['error'] ?? 'Error ${res.statusCode}';
    throw Exception(err);
  }

  /// Hapus savings goal
  static Future<void> deleteSavingsGoal(String id) async {
    final headers = await _authHeaders();
    final res = await http.delete(
      Uri.parse(ApiConfig.savingsGoalDetailEndpoint(id)),
      headers: headers,
    );
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('Gagal menghapus savings goal (${res.statusCode})');
    }
  }

  // ── BUDGET GOALS ──────────────────────────────────────────────────────────
  static Future<BudgetGoalsResponse> fetchBudgetGoals() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse(ApiConfig.budgetGoalsEndpoint),
      headers: headers,
    );
    if (res.statusCode == 200) {
      return BudgetGoalsResponse.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Gagal memuat budget goals (${res.statusCode})');
  }

  /// Set/update budget untuk kategori tertentu
  static Future<Map<String, dynamic>> setBudget({
    required String categoryName,
    required double amount,
    String? monthYear, // YYYY-MM-01 (optional, default = bulan ini)
  }) async {
    final headers = await _authHeaders();
    final body = jsonEncode({
      'category_name': categoryName,
      'amount': amount,
      if (monthYear != null) 'month_year': monthYear,
    });

    final res = await http.post(
      Uri.parse(ApiConfig.setBudgetEndpoint),
      headers: headers,
      body: body,
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    final err = jsonDecode(res.body)['error'] ?? 'Error ${res.statusCode}';
    throw Exception(err);
  }

  /// Hapus budget
  static Future<void> deleteBudget(String budgetId) async {
    final headers = await _authHeaders();
    final res = await http.delete(
      Uri.parse(ApiConfig.deleteBudgetEndpoint(budgetId)),
      headers: headers,
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Gagal menghapus budget (${res.statusCode})');
    }
  }

  /// Dapatkan saran pengelolaan keuangan berbasis AI
  static Future<Map<String, dynamic>> fetchFinancialAdvice() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse(ApiConfig.financialAdviceEndpoint),
      headers: headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Gagal memuat saran AI (${res.statusCode})');
  }
}
