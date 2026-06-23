import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  ApiConfig._();

  // Base URL loaded dynamically from .env
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://151.145.68.195.nip.io';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static String get registerEndpoint => '$baseUrl/api/auth/register/';
  static String get verifyOtpEndpoint => '$baseUrl/api/auth/verify-otp/';
  static String get loginEndpoint => '$baseUrl/api/auth/login/';
  static String get googleLoginEndpoint => '$baseUrl/api/auth/google-login/';

  // ── Transactions ──────────────────────────────────────────────────────────
  static String get saveTransactionEndpoint =>
      '$baseUrl/api/transactions/save-transaction/';
  static String get saveChatTransactionEndpoint =>
      '$baseUrl/api/transactions/chat-input/';
  static String get chatInputEndpoint =>
      '$baseUrl/api/transactions/chat-input/';
  static String get scanReceiptEndpoint =>
      '$baseUrl/api/transactions/scan-receipt/';

  /// Flat list endpoint — returns List<Transaction> with category_type field
  static String get transactionListEndpoint => '$baseUrl/api/transactions/';
  static String get dashboardSummaryEndpoint =>
      '$baseUrl/api/transactions/dashboard-summary/';
  static String get transactionHistoryEndpoint =>
      '$baseUrl/api/transactions/history/';
  static String get reportSummaryEndpoint =>
      '$baseUrl/api/transactions/report-summary/';
  static String updateTransactionEndpoint(String id) =>
      '$baseUrl/api/transactions/$id/';
  static String deleteTransactionEndpoint(String id) =>
      '$baseUrl/api/transactions/$id/';

  // ── Savings Goals ─────────────────────────────────────────────────────────
  static String get savingsGoalsEndpoint => '$baseUrl/api/savings-goals/';

  static String savingsGoalDetailEndpoint(String id) =>
      '$baseUrl/api/savings-goals/$id/';
  static String savingsGoalAddFundsEndpoint(String id) =>
      '$baseUrl/api/savings-goals/$id/add-funds/';
  static String savingsGoalWithdrawEndpoint(String id) =>
      '$baseUrl/api/savings-goals/$id/withdraw/';

  // ── Budget Goals ──────────────────────────────────────────────────────────
  static String get budgetGoalsEndpoint => '$baseUrl/api/budget-goals/';
  static String get setBudgetEndpoint => '$baseUrl/api/budget-goals/set/';
  static String get savingsOverviewEndpoint =>
      '$baseUrl/api/budget-goals/savings-overview/';
  static String get financialAdviceEndpoint =>
      '$baseUrl/api/budget-goals/financial-advice/';

  static String deleteBudgetEndpoint(String id) =>
      '$baseUrl/api/budget-goals/$id/';

  // ── Investment Portfolio ──────────────────────────────────────────────────
  static String get investmentsEndpoint => '$baseUrl/api/investments/';
  static String get portfolioSummaryEndpoint =>
      '$baseUrl/api/investments/portfolio-summary/';
  static String get searchCryptoEndpoint =>
      '$baseUrl/api/investments/search-crypto/';
  static String get refreshPricesEndpoint =>
      '$baseUrl/api/investments/refresh-prices/';

  static String investmentDetailEndpoint(String id) =>
      '$baseUrl/api/investments/$id/';
  static String investmentTransactionsEndpoint(String id) =>
      '$baseUrl/api/investments/$id/transactions/';
  static String addInvestmentTransactionEndpoint(String id) =>
      '$baseUrl/api/investments/$id/add-transaction/';

  /// Get real-time price for an asset
  /// [symbol] - Asset symbol (e.g., BTC, BBCA)
  /// [type] - Asset type: 'crypto' or 'stock'
  static String priceEndpoint(String symbol, String type) =>
      '$baseUrl/api/investments/price/?symbol=$symbol&type=$type';

  // ── Google OAuth ──────────────────────────────────────────────────────────
  static const String googleClientId =
      '624243434810-sudpasffpr3oi3o2fu03tq67oot8ts9g.apps.googleusercontent.com';
}
