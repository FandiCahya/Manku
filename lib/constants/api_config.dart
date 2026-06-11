import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  ApiConfig._();

  // Configurable base URL for API connection.
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'https://151.145.68.195.nip.io';

  static String get saveTransactionEndpoint =>
      '$baseUrl/api/transactions/save-transaction/';
  static String get chatInputEndpoint =>
      '$baseUrl/api/transactions/chat-input/';
  static String get registerEndpoint => '$baseUrl/api/auth/register/';
  static String get verifyOtpEndpoint => '$baseUrl/api/auth/verify-otp/';
  static String get loginEndpoint => '$baseUrl/api/auth/login/';
  static String get googleLoginEndpoint => '$baseUrl/api/auth/google-login/';

  // ── Aggregate / Read Endpoints ──────────────────────────────────────────
  static String get dashboardSummaryEndpoint =>
      '$baseUrl/api/transactions/dashboard-summary/';
  static String get transactionHistoryEndpoint =>
      '$baseUrl/api/transactions/history/';
  static String get reportSummaryEndpoint =>
      '$baseUrl/api/transactions/report-summary/';

  // ── Savings Goals ────────────────────────────────────────────────────────
  static String get savingsGoalsEndpoint => '$baseUrl/api/savings-goals/';

  static String savingsGoalDetailEndpoint(String id) =>
      '$baseUrl/api/savings-goals/$id/';

  static String savingsGoalAddFundsEndpoint(String id) =>
      '$baseUrl/api/savings-goals/$id/add-funds/';

  static String savingsGoalWithdrawEndpoint(String id) =>
      '$baseUrl/api/savings-goals/$id/withdraw/';

  // ── Budget Goals ─────────────────────────────────────────────────────────
  static String get budgetGoalsEndpoint => '$baseUrl/api/budget-goals/';
  static String get setBudgetEndpoint => '$baseUrl/api/budget-goals/set/';
  static String get savingsOverviewEndpoint =>
      '$baseUrl/api/budget-goals/savings-overview/';
  static String get financialAdviceEndpoint =>
      '$baseUrl/api/budget-goals/financial-advice/';

  static String deleteBudgetEndpoint(String id) =>
      '$baseUrl/api/budget-goals/$id/';

  // ── Google Sign In ────────────────────────────────────────────────────────
  static const String googleClientId =
      '624243434810-sudpasffpr3oi3o2fu03tq67oot8ts9g.apps.googleusercontent.com';
}
