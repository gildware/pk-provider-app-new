import 'package:get/get.dart';
import '../util/core_export.dart';

class ApiChecker {
  static void checkApi(Response response, {bool showDefaultToaster = true}) {
    if (!showDefaultToaster || (SilentApiContext.isActive && response.statusCode != 401)) {
      return;
    }

    if (response.statusCode == 401) {
      _executeUnAuthorized(response);
      return;
    }

    final isAppNotActive = response.statusCode == 503 &&
        '${response.body?['code']}'.contains('activation-503');
    if (isAppNotActive) {
      _executeUnAuthorized(response, response.body?['message']?.toString());
      return;
    }

    if (response.statusCode == 500) {
      showCustomSnackBar(trLabel('internal_server_error'));
      return;
    }

    _showFallbackMessage(response);
  }

  static void _executeUnAuthorized(Response response, [String? errorMessage]) {
    if (!Get.find<AuthController>().isLoggedIn()) {
      return;
    }

    Get.find<AuthController>().clearSharedData();
    Get.find<UserProfileController>().clearUserProfileData();

    if (Get.currentRoute != RouteHelper.getSignInRoute('splash')) {
      Get.offAllNamed(RouteHelper.getSignInRoute('splash'));
      final message = errorMessage ??
          response.statusText ??
          'Session expired. Please sign in again.';
      if (message.isNotEmpty) {
        showCustomSnackBar(message);
      }
    }
  }

  static void _showFallbackMessage(Response response) {
    final body = response.body;
    if (body is Map && body['message'] != null) {
      showCustomSnackBar('${body['message']}');
      return;
    }

    final statusText = response.statusText;
    if (statusText != null &&
        statusText.isNotEmpty &&
        statusText.toLowerCase() != 'internal server error') {
      showCustomSnackBar(statusText);
      return;
    }

    showCustomSnackBar(trLabel('something_went_wrong'));
  }
}
