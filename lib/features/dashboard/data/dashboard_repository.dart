import 'package:flutter/foundation.dart';
import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../models/dashboard_summary.dart';

/// Repository for Dashboard HTTP calls using Dio client.
class DashboardRepository {
  DashboardRepository._();

  static Future<DashboardSummary> fetchDashboardSummary() async {
    try {
      final response = await ApiClient.dio.get<Map<String, dynamic>>(
        ApiConfig.dashboardSummaryEndpoint,
      );

      if (response.statusCode == 200 && response.data != null) {
        return DashboardSummary.fromJson(response.data!);
      }
      debugPrint('dashboard-summary error ${response.statusCode}: ${response.data}');
      throw Exception(
        'Gagal memuat dashboard summary (${response.statusCode})',
      );
    } catch (e) {
      debugPrint('fetchDashboardSummary exception: $e');
      rethrow;
    }
  }
}
