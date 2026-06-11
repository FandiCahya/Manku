class ExtractedTransaction {
  final double? amount;
  final String? date;
  final String? categoryHint;
  final String? description;
  final String? type;

  const ExtractedTransaction({
    this.amount,
    this.date,
    this.categoryHint,
    this.description,
    this.type,
  });

  factory ExtractedTransaction.fromJson(Map<String, dynamic> json) {
    return ExtractedTransaction(
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      date: json['date'] as String?,
      categoryHint: json['category_hint'] as String?,
      description: json['description'] as String?,
      type: json['type'] as String?,
    );
  }
}

class ChatTransactionResponse {
  final ExtractedTransaction? extractedData;
  final String? message;

  const ChatTransactionResponse({
    this.extractedData,
    this.message,
  });

  factory ChatTransactionResponse.fromJson(Map<String, dynamic> json) {
    final extracted = json['extracted_data'] as Map<String, dynamic>?;
    return ChatTransactionResponse(
      extractedData: extracted != null ? ExtractedTransaction.fromJson(extracted) : null,
      message: json['message'] as String?,
    );
  }
}
