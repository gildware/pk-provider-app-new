import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class PaymentAccessTokenHelper {
  static String? _cachedToken;
  static DateTime? _cachedAt;

  static Future<String> forProvider() async {
    if (_cachedToken != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < const Duration(minutes: 50)) {
      return _cachedToken!;
    }

    final response = await Get.find<ApiClient>().postData(
      '/api/v1/provider/payment/access-token',
      {},
    );

    final dynamic content = response.body is Map ? response.body['content'] : null;
    final token = content is Map ? content['access_token']?.toString() : null;

    if (response.statusCode == 200 && token != null && token.isNotEmpty) {
      _cachedToken = token;
      _cachedAt = DateTime.now();
      return token;
    }

    throw Exception(response.statusText ?? 'Failed to get payment access token');
  }

  static void clearCache() {
    _cachedToken = null;
    _cachedAt = null;
  }
}
