// Domain models for Investment Portfolio feature

/// Investment asset (Crypto or Stock)
class Investment {
  final String id;
  final String assetType; // 'crypto' or 'stock'
  final String symbol;
  final String name;
  final double quantity;
  final double buyPrice;
  final double totalCost;
  final double? currentPrice;
  final double? currentValue;
  final double? profitLoss;
  final double? profitLossPercentage;
  final DateTime purchaseDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Investment({
    required this.id,
    required this.assetType,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.buyPrice,
    required this.totalCost,
    this.currentPrice,
    this.currentValue,
    this.profitLoss,
    this.profitLossPercentage,
    required this.purchaseDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id'] as String,
      assetType: json['asset_type'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      quantity: double.parse(json['quantity'].toString()),
      buyPrice: double.parse(json['buy_price'].toString()),
      totalCost: double.parse(json['total_cost'].toString()),
      currentPrice: json['current_price'] != null
          ? double.parse(json['current_price'].toString())
          : null,
      currentValue: json['current_value'] != null
          ? (json['current_value'] as num).toDouble()
          : null,
      profitLoss: json['profit_loss'] != null
          ? (json['profit_loss'] as num).toDouble()
          : null,
      profitLossPercentage: json['profit_loss_percentage'] != null
          ? (json['profit_loss_percentage'] as num).toDouble()
          : null,
      purchaseDate: DateTime.parse(json['purchase_date'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset_type': assetType,
      'symbol': symbol,
      'name': name,
      'quantity': quantity,
      'buy_price': buyPrice,
      'purchase_date': purchaseDate.toIso8601String().split('T')[0],
      if (notes != null) 'notes': notes,
    };
  }

  bool get isCrypto => assetType.toLowerCase() == 'crypto';
  bool get isStock => assetType.toLowerCase() == 'stock';
  bool get hasProfit => (profitLoss ?? 0) > 0;
  bool get hasLoss => (profitLoss ?? 0) < 0;
}

/// Portfolio summary
class PortfolioSummary {
  final double totalInvestment;
  final double currentValue;
  final double totalProfitLoss;
  final double profitLossPercentage;
  final int totalAssets;
  final PortfolioByType? byType;

  PortfolioSummary({
    required this.totalInvestment,
    required this.currentValue,
    required this.totalProfitLoss,
    required this.profitLossPercentage,
    required this.totalAssets,
    this.byType,
  });

  factory PortfolioSummary.fromJson(Map<String, dynamic> json) {
    return PortfolioSummary(
      totalInvestment: (json['total_investment'] as num).toDouble(),
      currentValue: (json['current_value'] as num).toDouble(),
      totalProfitLoss: (json['total_profit_loss'] as num).toDouble(),
      profitLossPercentage: (json['profit_loss_percentage'] as num).toDouble(),
      totalAssets: json['total_assets'] as int,
      byType: json['by_type'] != null
          ? PortfolioByType.fromJson(json['by_type'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get hasProfit => totalProfitLoss > 0;
  bool get hasLoss => totalProfitLoss < 0;
}

/// Portfolio breakdown by asset type
class PortfolioByType {
  final AssetTypeInfo? crypto;
  final AssetTypeInfo? stock;

  PortfolioByType({this.crypto, this.stock});

  factory PortfolioByType.fromJson(Map<String, dynamic> json) {
    return PortfolioByType(
      crypto: json['crypto'] != null
          ? AssetTypeInfo.fromJson(json['crypto'] as Map<String, dynamic>)
          : null,
      stock: json['stock'] != null
          ? AssetTypeInfo.fromJson(json['stock'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Asset type information
class AssetTypeInfo {
  final double totalInvestment;
  final double currentValue;
  final double profitLoss;
  final int count;

  AssetTypeInfo({
    required this.totalInvestment,
    required this.currentValue,
    required this.profitLoss,
    required this.count,
  });

  factory AssetTypeInfo.fromJson(Map<String, dynamic> json) {
    return AssetTypeInfo(
      totalInvestment: (json['total_investment'] as num).toDouble(),
      currentValue: (json['current_value'] as num).toDouble(),
      profitLoss: (json['profit_loss'] as num).toDouble(),
      count: json['count'] as int,
    );
  }

  double get profitLossPercentage =>
      totalInvestment > 0 ? (profitLoss / totalInvestment) * 100 : 0;
}

/// Investment transaction (Buy/Sell)
class InvestmentTransaction {
  final String id;
  final String investmentId;
  final String? investmentSymbol;
  final String? investmentName;
  final String transactionType; // 'buy' or 'sell'
  final double quantity;
  final double price;
  final double totalAmount;
  final DateTime transactionDate;
  final String? notes;
  final DateTime createdAt;

  InvestmentTransaction({
    required this.id,
    required this.investmentId,
    this.investmentSymbol,
    this.investmentName,
    required this.transactionType,
    required this.quantity,
    required this.price,
    required this.totalAmount,
    required this.transactionDate,
    this.notes,
    required this.createdAt,
  });

  factory InvestmentTransaction.fromJson(Map<String, dynamic> json) {
    return InvestmentTransaction(
      id: json['id'] as String,
      investmentId: json['investment'] as String,
      investmentSymbol: json['investment_symbol'] as String?,
      investmentName: json['investment_name'] as String?,
      transactionType: json['transaction_type'] as String,
      quantity: double.parse(json['quantity'].toString()),
      price: double.parse(json['price'].toString()),
      totalAmount: double.parse(json['total_amount'].toString()),
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_type': transactionType,
      'quantity': quantity,
      'price': price,
      'transaction_date': transactionDate.toIso8601String(),
      if (notes != null) 'notes': notes,
    };
  }

  bool get isBuy => transactionType.toLowerCase() == 'buy';
  bool get isSell => transactionType.toLowerCase() == 'sell';
}

/// Real-time price data
class PriceData {
  final String symbol;
  final String name;
  final double currentPrice;
  final double? priceChange24h;
  final DateTime lastUpdated;

  PriceData({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    this.priceChange24h,
    required this.lastUpdated,
  });

  factory PriceData.fromJson(Map<String, dynamic> json) {
    return PriceData(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      currentPrice: (json['current_price'] as num).toDouble(),
      priceChange24h: json['price_change_24h'] != null
          ? (json['price_change_24h'] as num).toDouble()
          : null,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  bool get isPriceUp => (priceChange24h ?? 0) > 0;
  bool get isPriceDown => (priceChange24h ?? 0) < 0;
}

/// Crypto search result
class CryptoSearchResult {
  final String id;
  final String symbol;
  final String name;

  CryptoSearchResult({
    required this.id,
    required this.symbol,
    required this.name,
  });

  factory CryptoSearchResult.fromJson(Map<String, dynamic> json) {
    return CryptoSearchResult(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
    );
  }
}
