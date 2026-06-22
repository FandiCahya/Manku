import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';
import '../domain/investment_models.dart';

/// Repository for Investment Portfolio API
class InvestmentRepository {
  InvestmentRepository._();

  /// Get all investments for current user
  static Future<List<Investment>> fetchInvestments() async {
    final response = await ApiClient.dio.get<List<dynamic>>(
      ApiConfig.investmentsEndpoint,
    );

    final data = response.data ?? [];
    return data
        .map((json) => Investment.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get portfolio summary with profit/loss
  static Future<PortfolioSummary> fetchPortfolioSummary() async {
    final response = await ApiClient.dio.get<Map<String, dynamic>>(
      ApiConfig.portfolioSummaryEndpoint,
    );

    return PortfolioSummary.fromJson(response.data!);
  }

  /// Create new investment
  static Future<Investment> createInvestment({
    required String assetType,
    required String symbol,
    required String name,
    required double quantity,
    required double buyPrice,
    required DateTime purchaseDate,
    String? notes,
  }) async {
    final response = await ApiClient.dio.post<Map<String, dynamic>>(
      ApiConfig.investmentsEndpoint,
      data: {
        'asset_type': assetType,
        'symbol': symbol,
        'name': name,
        'quantity': quantity,
        'buy_price': buyPrice,
        'purchase_date': purchaseDate.toIso8601String().split('T')[0],
        if (notes != null) 'notes': notes,
      },
    );

    return Investment.fromJson(response.data!);
  }

  /// Get investment detail by ID
  static Future<Investment> fetchInvestmentDetail(String id) async {
    final response = await ApiClient.dio.get<Map<String, dynamic>>(
      ApiConfig.investmentDetailEndpoint(id),
    );

    return Investment.fromJson(response.data!);
  }

  /// Update investment
  static Future<Investment> updateInvestment({
    required String id,
    double? quantity,
    double? buyPrice,
    String? notes,
  }) async {
    final response = await ApiClient.dio.patch<Map<String, dynamic>>(
      ApiConfig.investmentDetailEndpoint(id),
      data: {
        if (quantity != null) 'quantity': quantity,
        if (buyPrice != null) 'buy_price': buyPrice,
        if (notes != null) 'notes': notes,
      },
    );

    return Investment.fromJson(response.data!);
  }

  /// Delete investment
  static Future<void> deleteInvestment(String id) async {
    await ApiClient.dio.delete<dynamic>(ApiConfig.investmentDetailEndpoint(id));
  }

  /// Add transaction (buy/sell)
  static Future<InvestmentTransaction> addTransaction({
    required String investmentId,
    required String transactionType,
    required double quantity,
    required double price,
    required DateTime transactionDate,
    String? notes,
  }) async {
    final response = await ApiClient.dio.post<Map<String, dynamic>>(
      ApiConfig.addInvestmentTransactionEndpoint(investmentId),
      data: {
        'transaction_type': transactionType,
        'quantity': quantity,
        'price': price,
        'transaction_date': transactionDate.toIso8601String(),
        if (notes != null) 'notes': notes,
      },
    );

    final data = response.data!;
    return InvestmentTransaction.fromJson(
      data['transaction'] as Map<String, dynamic>,
    );
  }

  /// Get transaction history for an investment
  static Future<List<InvestmentTransaction>> fetchTransactions(
    String investmentId,
  ) async {
    final response = await ApiClient.dio.get<List<dynamic>>(
      ApiConfig.investmentTransactionsEndpoint(investmentId),
    );

    final data = response.data ?? [];
    return data
        .map(
          (json) =>
              InvestmentTransaction.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Get real-time price for an asset
  static Future<PriceData> fetchPrice(String symbol, String type) async {
    final response = await ApiClient.dio.get<Map<String, dynamic>>(
      ApiConfig.priceEndpoint(symbol, type),
    );

    return PriceData.fromJson(response.data!);
  }

  /// Search cryptocurrency
  static Future<List<CryptoSearchResult>> searchCrypto(String query) async {
    final response = await ApiClient.dio.get<List<dynamic>>(
      '${ApiConfig.searchCryptoEndpoint}?q=$query',
    );

    final data = response.data ?? [];
    return data
        .map(
          (json) => CryptoSearchResult.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Refresh all prices (bypass cache)
  static Future<Map<String, PriceData>> refreshPrices() async {
    final response = await ApiClient.dio.get<Map<String, dynamic>>(
      ApiConfig.refreshPricesEndpoint,
    );

    final data = response.data!;
    final prices = data['prices'] as Map<String, dynamic>;

    return prices.map(
      (key, value) =>
          MapEntry(key, PriceData.fromJson(value as Map<String, dynamic>)),
    );
  }
}
