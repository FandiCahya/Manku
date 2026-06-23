import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/investment_repository.dart';
import '../../domain/investment_models.dart';
import 'investment_state.dart';

class InvestmentCubit extends Cubit<InvestmentState> {
  InvestmentCubit() : super(InvestmentInitial());

  Future<void> loadInvestments() async {
    emit(InvestmentLoading());
    try {
      final investments = await InvestmentRepository.fetchInvestments();
      final summary = await InvestmentRepository.fetchPortfolioSummary();
      emit(InvestmentLoaded(investments: investments, summary: summary));
    } catch (e) {
      debugPrint('InvestmentCubit Error (load): $e');
      emit(InvestmentError(e.toString()));
    }
  }

  Future<void> addInvestment({
    required String assetType,
    required String symbol,
    required String name,
    required double quantity,
    required double buyPrice,
    required DateTime purchaseDate,
    String? notes,
  }) async {
    final currentState = state;
    emit(InvestmentSubmitting());
    try {
      await InvestmentRepository.createInvestment(
        assetType: assetType,
        symbol: symbol,
        name: name,
        quantity: quantity,
        buyPrice: buyPrice,
        purchaseDate: purchaseDate,
        notes: notes,
      );
      emit(InvestmentSubmitSuccess('Investment added successfully!'));
      await loadInvestments();
    } catch (e) {
      debugPrint('InvestmentCubit Error (add): $e');
      emit(InvestmentError(e.toString()));
      if (currentState is InvestmentLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> editInvestment({
    required String id,
    double? quantity,
    double? buyPrice,
    String? notes,
  }) async {
    final currentState = state;
    emit(InvestmentSubmitting());
    try {
      await InvestmentRepository.updateInvestment(
        id: id,
        quantity: quantity,
        buyPrice: buyPrice,
        notes: notes,
      );
      emit(InvestmentSubmitSuccess('Investment berhasil diperbarui!'));
      await loadInvestments();
    } catch (e) {
      debugPrint('InvestmentCubit Error (edit): $e');
      emit(InvestmentError(e.toString()));
      if (currentState is InvestmentLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> deleteInvestment(String id) async {
    final currentState = state;
    emit(InvestmentSubmitting());
    try {
      await InvestmentRepository.deleteInvestment(id);
      emit(InvestmentSubmitSuccess('Investment deleted successfully!'));
      await loadInvestments();
    } catch (e) {
      debugPrint('InvestmentCubit Error (delete): $e');
      emit(InvestmentError(e.toString()));
      if (currentState is InvestmentLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> addTransaction({
    required String investmentId,
    required String transactionType,
    required double quantity,
    required double price,
    required DateTime transactionDate,
    String? notes,
  }) async {
    final currentState = state;
    emit(InvestmentSubmitting());
    try {
      await InvestmentRepository.addTransaction(
        investmentId: investmentId,
        transactionType: transactionType,
        quantity: quantity,
        price: price,
        transactionDate: transactionDate,
        notes: notes,
      );
      emit(InvestmentSubmitSuccess('Transaction added successfully!'));
      await loadInvestments();
    } catch (e) {
      debugPrint('InvestmentCubit Error (transaction): $e');
      emit(InvestmentError(e.toString()));
      if (currentState is InvestmentLoaded) {
        emit(currentState);
      }
    }
  }

  Future<PriceData?> getPrice(String symbol, String type) async {
    try {
      return await InvestmentRepository.fetchPrice(symbol, type);
    } catch (e) {
      debugPrint('InvestmentCubit Error (price): $e');
      return null;
    }
  }

  Future<void> refreshPrices() async {
    try {
      await InvestmentRepository.refreshPrices();
      await loadInvestments();
    } catch (e) {
      debugPrint('InvestmentCubit Error (refresh): $e');
    }
  }
}
