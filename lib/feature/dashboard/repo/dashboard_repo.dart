import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class DashBoardRepo{
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  DashBoardRepo({required this.apiClient,required this.sharedPreferences});

  Future<Response> getDashBoardData({bool includeCustomizedPost = true}) async {
    // SERVICEMAN_DISABLED: omit serviceman_list until AppFeatureFlags.servicemanEnabled
    final sections = [
      'top_cards',
      'earning_stats',
      'booking_stats',
      'recent_bookings',
      'my_subscriptions',
      if (includeCustomizedPost) 'customized_post',
      'additional_info_count',
    ].join(',');
    return await apiClient.getData("${AppConstants.dashboardUri}?sections=$sections");
  }

  Future<Response> getYearlyDashBoardChartData(String year) async {
    return await apiClient.getData("${AppConstants.dashboardUri}?sections=earning_stats&stats_type=full_year&year=$year");
  }

  Future<Response> getDigitalPaymentMethodData() async {
    Response response = await apiClient.getData(AppConstants.paymentUri,headers: AppConstants.configHeader);
    return response;
  }

  Future<Response> getEarningData() async {
    return await apiClient.getData(AppConstants.earningDataUrl);
  }
}