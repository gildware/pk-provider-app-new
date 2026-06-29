import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class NotificationRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  NotificationRepo({required this.sharedPreferences, required this.apiClient});

  Future<Response> getNotification(int offset) async {
    return await apiClient.getData(
        '${AppConstants.notificationUrl}?limit=30&offset=$offset');
  }

  Future<Response> getUnreadCount() async {
    return await apiClient.getData(AppConstants.notificationUnreadCountUrl);
  }

  Future<Response> markAsRead(String notificationId) async {
    return await apiClient.putData(
      '${AppConstants.notificationUrl}/$notificationId/read',
      {},
    );
  }

  Future<Response> markAllAsRead() async {
    return await apiClient.putData(AppConstants.notificationMarkAllReadUrl, {});
  }
}
