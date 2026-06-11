import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/savings_repository.dart';
import '../../domain/financial_advice.dart';
import 'savings_state.dart';

class SavingsCubit extends Cubit<SavingsState> {
  SavingsCubit() : super(SavingsInitial());

  Future<void> fetchSavingsData() async {
    emit(SavingsLoading());
    try {
      final budgets = await SavingsRepository.fetchBudgetGoals();
      
      // Load financial advice, handle optional exception so advice loading failure doesn't block budget view
      FinancialAdvice advice;
      try {
        advice = await SavingsRepository.fetchFinancialAdvice();
      } catch (e) {
        advice = FinancialAdvice(
          statusKeuangan: 'Belum Menganalisis',
          ringkasanAnalisis: 'Gagal memuat saran AI: ${e.toString().replaceFirst('Exception: ', '')}',
          saranList: const [],
        );
      }

      emit(SavingsLoaded(budgetGoals: budgets, financialAdvice: advice));
    } catch (e) {
      emit(SavingsError(error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> setCategoryBudget({
    required String categoryName,
    required double amount,
  }) async {
    emit(SavingsSubmitting());
    try {
      await SavingsRepository.setBudget(categoryName: categoryName, amount: amount);
      emit(const SavingsSuccess(message: 'Budget berhasil diatur!'));
      await fetchSavingsData();
    } catch (e) {
      emit(SavingsError(error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> deleteCategoryBudget(String budgetId) async {
    emit(SavingsSubmitting());
    try {
      await SavingsRepository.deleteBudget(budgetId);
      emit(const SavingsSuccess(message: 'Budget berhasil dihapus!'));
      await fetchSavingsData();
    } catch (e) {
      emit(SavingsError(error: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
