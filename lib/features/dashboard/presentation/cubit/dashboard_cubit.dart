import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/dashboard_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardInitial());

  Future<void> fetchSummary() async {
    emit(DashboardLoading());
    try {
      final summary = await DashboardRepository.fetchDashboardSummary();
      emit(DashboardLoaded(summary: summary));
    } catch (e) {
      emit(DashboardError(error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> refreshSummary() async {
    // Keep loaded state or loading depending on preferences. We emit DashboardLoading for clarity.
    try {
      final summary = await DashboardRepository.fetchDashboardSummary();
      emit(DashboardLoaded(summary: summary));
    } catch (e) {
      emit(DashboardError(error: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
