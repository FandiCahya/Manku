import '../../../models/transaction_api.dart';
import '../../../models/report_summary.dart';
import '../domain/chat_transaction_response.dart';
import '../../../services/transaction_service.dart';
import 'package:image_picker/image_picker.dart';

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
    return await TransactionService.saveChatTransaction(text);
  }

  static Future<Map<String, dynamic>?> scanReceipt(XFile image) async {
    return await TransactionService.scanReceipt(image);
  }
}
