import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/transaction_repository.dart';
import '../../../../models/transaction_api.dart';
import '../../domain/chat_transaction_response.dart';
import 'transaction_state.dart';
import 'package:image_picker/image_picker.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit() : super(TransactionInitial());

  Future<void> fetchTransactionsAndReport() async {
    emit(TransactionLoading());
    try {
      final history = await TransactionRepository.fetchHistory();
      final report = await TransactionRepository.fetchReportSummary();
      emit(TransactionLoaded(
        history: history,
        report: report,
        filteredGroups: history.groups,
      ));
    } catch (e) {
      debugPrint('TransactionCubit Error (fetch): $e');
      emit(TransactionError(error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void searchTransactions(String query) {
    final currentState = state;
    if (currentState is TransactionLoaded) {
      if (query.trim().isEmpty) {
        emit(currentState.copyWith(
          filteredGroups: currentState.history.groups,
          searchQuery: '',
        ));
        return;
      }

      final lowercaseQuery = query.toLowerCase();
      final filtered = currentState.history.groups.map((group) {
        final filteredTxns = group.transactions.where((txn) {
          return txn.description.toLowerCase().contains(lowercaseQuery) ||
              txn.categoryName.toLowerCase().contains(lowercaseQuery);
        }).toList();

        if (filteredTxns.isEmpty) return null;
        return TransactionGroup(
          dateLabel: group.dateLabel,
          date: group.date,
          transactions: filteredTxns,
        );
      }).whereType<TransactionGroup>().toList();

      emit(currentState.copyWith(
        filteredGroups: filtered,
        searchQuery: query,
      ));
    }
  }

  Future<void> addManualTransaction({
    required String amount,
    required String categoryHint,
    required String description,
    required String date,
    required String time,
    required String type,
  }) async {
    final currentState = state;
    emit(TransactionSubmitting());
    try {
      await TransactionRepository.saveTransaction(
        amount: amount,
        categoryHint: categoryHint,
        description: description,
        date: date,
        time: time,
        type: type,
      );
      emit(const TransactionSubmitSuccess(message: 'Transaksi berhasil disimpan!'));
      // Reload the data
      await fetchTransactionsAndReport();
    } catch (e) {
      debugPrint('TransactionCubit Error (add): $e');
      emit(TransactionError(error: e.toString().replaceFirst('Exception: ', '')));
      if (currentState is TransactionLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> updateTransaction({
    required String id,
    required String amount,
    required String categoryHint,
    required String description,
    required String date,
    required String time,
    required String type,
  }) async {
    debugPrint('TransactionCubit: updateTransaction called for id $id');
    final currentState = state;
    emit(TransactionSubmitting());
    try {
      await TransactionRepository.updateTransaction(
        id: id,
        amount: amount,
        categoryHint: categoryHint,
        description: description,
        date: date,
        time: time,
        type: type,
      );
      emit(const TransactionSubmitSuccess(message: 'Transaksi berhasil diubah!'));
      await fetchTransactionsAndReport();
    } catch (e) {
      debugPrint('TransactionCubit Error (update): $e');
      emit(TransactionError(error: e.toString().replaceFirst('Exception: ', '')));
      if (currentState is TransactionLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> deleteTransaction(String id) async {
    debugPrint('TransactionCubit: deleteTransaction called for id $id');
    final currentState = state;
    emit(TransactionSubmitting());
    try {
      await TransactionRepository.deleteTransaction(id);
      emit(const TransactionSubmitSuccess(message: 'Transaksi berhasil dihapus!'));
      await fetchTransactionsAndReport();
    } catch (e) {
      debugPrint('TransactionCubit Error (delete): $e');
      emit(TransactionError(error: e.toString().replaceFirst('Exception: ', '')));
      if (currentState is TransactionLoaded) {
        emit(currentState);
      }
    }
  }

  Future<ChatTransactionResponse?> addChatTransaction(String text) async {
    // For chat transactions, we might want to return the extracted response so the UI can print it in the chat bubble.
    try {
      final response = await TransactionRepository.saveChatTransaction(text);
      emit(const TransactionSubmitSuccess(message: 'Transaksi berhasil disimpan dari Chat!'));
      // Reload history in background
      unawaited(fetchTransactionsAndReport()); // tidak di-await agar chat tidak tertunda
      return response;
    } catch (e) {
      debugPrint('TransactionCubit Error (chat): $e');
      // Kembalikan state yang sebelumnya agar UI tidak crash
      final currentState = state;
      emit(TransactionError(error: e.toString().replaceFirst('Exception: ', '')));
      if (currentState is TransactionLoaded) {
        emit(currentState);
      }
      // Rethrow agar widget dapat menampilkan pesan error yang spesifik
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> scanReceiptImage(XFile image) async {
    emit(TransactionSubmitting());
    try {
      final response = await TransactionRepository.scanReceipt(image);
      emit(const TransactionSubmitSuccess(message: 'Struk berhasil diproses!'));
      return response;
    } catch (e) {
      emit(TransactionError(error: e.toString().replaceFirst('Exception: ', '')));
      return null;
    }
  }
}
