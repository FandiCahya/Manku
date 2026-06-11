import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../models/savings_goal.dart';
import '../domain/budget_models.dart';
import '../domain/financial_advice.dart';

/// Repository for Savings Goals and Budget HTTP calls using Dio client.
class SavingsRepository {
  SavingsRepository._();

  // ── Savings Overview ───────────────────────────────────────────────────────
  static Future<SavingsOverview> fetchSavingsOverview() async {
    try {
      final res = await ApiClient.dio.get<Map<String, dynamic>>(
        ApiConfig.savingsOverviewEndpoint,
      );
      if (res.statusCode == 200 && res.data != null) {
        return SavingsOverview.fromJson(res.data!);
      }
      throw Exception('Gagal memuat savings overview (${res.statusCode})');
    } on DioException catch (e) {
      throw Exception('Gagal memuat savings overview (${e.message})');
    }
  }

  // ── Savings Goals CRUD ─────────────────────────────────────────────────────
  static Future<List<SavingsGoalModel>> fetchSavingsGoals() async {
    try {
      final res = await ApiClient.dio.get<List<dynamic>>(
        ApiConfig.savingsGoalsEndpoint,
      );
      if (res.statusCode == 200 && res.data != null) {
        return res.data!
            .map((e) => SavingsGoalModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Gagal memuat savings goals (${res.statusCode})');
    } on DioException catch (e) {
      throw Exception('Gagal memuat savings goals (${e.message})');
    }
  }

  static Future<SavingsGoalModel> createSavingsGoal({
    required String name,
    required double targetAmount,
    double currentAmount = 0,
    String? deadline,
    String? description,
    String color = '#4A90D9',
    String icon = 'savings',
  }) async {
    try {
      final res = await ApiClient.dio.post<Map<String, dynamic>>(
        ApiConfig.savingsGoalsEndpoint,
        data: {
          'name': name,
          'target_amount': targetAmount,
          'current_amount': currentAmount,
          if (deadline != null) 'deadline': deadline,
          if (description != null && description.isNotEmpty)
            'description': description,
          'color': color,
          'icon': icon,
        },
      );

      if (res.statusCode == 201 && res.data != null) {
        return SavingsGoalModel.fromJson(res.data!);
      }
      debugPrint('createSavingsGoal error: ${res.statusCode} - ${res.data}');
      throw Exception('Gagal membuat savings goal (${res.statusCode})');
    } on DioException catch (e) {
      throw Exception(
        ((e.response?.data as Map<String, dynamic>?)?['error'] as String?) ??
            'Gagal membuat savings goal (${e.message})',
      );
    }
  }

  static Future<SavingsGoalModel> updateSavingsGoal(
    String id, {
    String? name,
    double? targetAmount,
    String? deadline,
    String? description,
    String? color,
    String? icon,
  }) async {
    try {
      final res = await ApiClient.dio.patch<Map<String, dynamic>>(
        ApiConfig.savingsGoalDetailEndpoint(id),
        data: {
          if (name != null) 'name': name,
          if (targetAmount != null) 'target_amount': targetAmount,
          if (deadline != null) 'deadline': deadline,
          if (description != null) 'description': description,
          if (color != null) 'color': color,
          if (icon != null) 'icon': icon,
        },
      );

      if (res.statusCode == 200 && res.data != null) {
        return SavingsGoalModel.fromJson(res.data!);
      }
      throw Exception('Gagal mengupdate savings goal (${res.statusCode})');
    } on DioException catch (e) {
      throw Exception(
        ((e.response?.data as Map<String, dynamic>?)?['error'] as String?) ??
            'Gagal mengupdate savings goal (${e.message})',
      );
    }
  }

  static Future<SavingsGoalModel> addFunds(String goalId, double amount) async {
    try {
      final res = await ApiClient.dio.post<Map<String, dynamic>>(
        ApiConfig.savingsGoalAddFundsEndpoint(goalId),
        data: {'amount': amount},
      );

      if (res.statusCode == 200 && res.data != null) {
        final data = res.data!;
        return SavingsGoalModel.fromJson(data['goal'] as Map<String, dynamic>);
      }
      throw Exception('Gagal tambah dana (${res.statusCode})');
    } on DioException catch (e) {
      throw Exception(
        ((e.response?.data as Map<String, dynamic>?)?['error'] as String?) ??
            'Gagal tambah dana (${e.message})',
      );
    }
  }

  static Future<SavingsGoalModel> withdrawFunds(
    String goalId,
    double amount,
  ) async {
    try {
      final res = await ApiClient.dio.post<Map<String, dynamic>>(
        ApiConfig.savingsGoalWithdrawEndpoint(goalId),
        data: {'amount': amount},
      );

      if (res.statusCode == 200 && res.data != null) {
        final data = res.data!;
        return SavingsGoalModel.fromJson(data['goal'] as Map<String, dynamic>);
      }
      throw Exception('Gagal tarik dana (${res.statusCode})');
    } on DioException catch (e) {
      throw Exception(
        ((e.response?.data as Map<String, dynamic>?)?['error'] as String?) ??
            'Gagal tarik dana (${e.message})',
      );
    }
  }

  static Future<void> deleteSavingsGoal(String id) async {
    try {
      final res = await ApiClient.dio.delete<void>(
        ApiConfig.savingsGoalDetailEndpoint(id),
      );
      if (res.statusCode != 204 && res.statusCode != 200) {
        throw Exception('Gagal menghapus savings goal (${res.statusCode})');
      }
    } on DioException catch (e) {
      throw Exception('Gagal menghapus savings goal (${e.message})');
    }
  }

  // ── Budget Goals ───────────────────────────────────────────────────────────
  static Future<BudgetGoalsResponse> fetchBudgetGoals() async {
    try {
      final res = await ApiClient.dio.get<Map<String, dynamic>>(
        ApiConfig.budgetGoalsEndpoint,
      );
      if (res.statusCode == 200 && res.data != null) {
        return BudgetGoalsResponse.fromJson(res.data!);
      }
      throw Exception('Gagal memuat budget goals (${res.statusCode})');
    } on DioException catch (e) {
      throw Exception('Gagal memuat budget goals (${e.message})');
    }
  }

  static Future<Map<String, dynamic>> setBudget({
    required String categoryName,
    required double amount,
    String? monthYear,
  }) async {
    try {
      final res = await ApiClient.dio.post<Map<String, dynamic>>(
        ApiConfig.setBudgetEndpoint,
        data: {
          'category_name': categoryName,
          'amount': amount,
          if (monthYear != null) 'month_year': monthYear,
        },
      );

      if (res.statusCode == 200 && res.data != null) {
        return res.data!;
      }
      throw Exception('Gagal set budget (${res.statusCode})');
    } on DioException catch (e) {
      throw Exception(
        ((e.response?.data as Map<String, dynamic>?)?['error'] as String?) ??
            'Gagal set budget (${e.message})',
      );
    }
  }

  static Future<void> deleteBudget(String budgetId) async {
    try {
      final res = await ApiClient.dio.delete<void>(
        ApiConfig.deleteBudgetEndpoint(budgetId),
      );
      if (res.statusCode != 200 && res.statusCode != 204) {
        throw Exception('Gagal menghapus budget (${res.statusCode})');
      }
    } on DioException catch (e) {
      throw Exception('Gagal menghapus budget (${e.message})');
    }
  }

  static Future<FinancialAdvice> fetchFinancialAdvice() async {
    try {
      final res = await ApiClient.dio.get<Map<String, dynamic>>(
        ApiConfig.financialAdviceEndpoint,
      );
      if (res.statusCode == 200 && res.data != null) {
        return FinancialAdvice.fromJson(res.data!);
      }
      throw Exception('Gagal memuat saran AI (${res.statusCode})');
    } on DioException catch (e) {
      throw Exception('Gagal memuat saran AI (${e.message})');
    }
  }
}
