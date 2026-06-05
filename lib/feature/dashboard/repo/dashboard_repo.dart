import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class DashBoardRepo{
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  DashBoardRepo({required this.apiClient,required this.sharedPreferences});

  Future<Response> getDashBoardData() async {
    // SERVICEMAN_DISABLED: omit serviceman_list until AppFeatureFlags.servicemanEnabled
    return await apiClient.getData(
      "${AppConstants.dashboardUri}?sections=top_cards,earning_stats,booking_stats,recent_bookings,my_subscriptions,customized_post,additional_info_count",
    );
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