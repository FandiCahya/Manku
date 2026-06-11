import '../../../models/transaction_api.dart';
import '../../../models/report_summary.dart';
import '../domain/chat_transaction_response.dart';
import '../../../services/transaction_service.dart';

/// Repository for Transaction using Offline-First SQLite approach.
class TransactionRepository {
  TransactionRepository._();

  static Future<TransactionHistory> fetchHistory() async {
    return TransactionService.fetchHistory();
  }

  static Future<ReportSummary> fetchReportSummary() async {
    return TransactionService.fetchReportSummary();
  }

  static Future<void> saveTransaction({
    required String amount,
    required String categoryHint,
    required String description,
    required String date,
    required String time,
    required String type,
  }) async {
    await TransactionService.addTransaction(
      amount: double.tryParse(amount.replaceAll(RegExp('[^0-9.]'), '')) ?? 0.0,
      categoryName: categoryHint,
      description: description,
      categoryType: type,
      inputSource: 'manual',
    );
  }

  static Future<void> updateTransaction({
    required String id,
    required String amount,
    required String categoryHint,
    required String description,
    required String date,
    required String time,
    required String type,
  }) async {
    await TransactionService.updateTransaction(
      id: id,
      amount: double.tryParse(amount.replaceAll(RegExp('[^0-9.]'), '')) ?? 0.0,
      categoryName: categoryHint,
      description: description,
      date: date,
      time: time,
      categoryType: type,
      inputSource: 'manual',
    );
  }

  static Future<void> deleteTransaction(String id) async {
    await TransactionService.deleteTransaction(id);
  }

  static Future<ChatTransactionResponse> saveChatTransaction(
    String text,
  ) async {
    // Note: Local NLP for chat is complex to do offline.
    // Ideally, you still need an API for parsing chat text into categories and amounts.
    // Since we are offline-first, if they use the chat feature, we might still need to call the NLP API,
    // then save the parsed result locally.
    // For now, as a placeholder, we can just save it as "Uncategorized" locally if offline,
    // or you can leave the chat feature to require internet connection.
    throw Exception('Fitur chat saat ini butuh koneksi internet (karena butuh AI backend). Gunakan input manual untuk offline.');
  }
}
