import 'dart:async';

import 'package:get/get.dart';
import '../helper/auth_session_helper.dart';
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

    if (response.statusCode == 429) {
      showCustomSnackBar(trLabel('too_many_request', fallback: 'Too many requests. Please try again later.'));
      return;
    }

    if (response.statusCode != null && response.statusCode! >= 400) {
      _showErrorMessage(response);
    }
  }

  static void _executeUnAuthorized(Response response, [String? errorMessage]) {
    final isLoggedIn = Get.find<AuthController>().isLoggedIn();

    if (isLoggedIn) {
      unawaited(_handleUnauthorizedLogout());
    } else if (!AuthSessionHelper.isProtectedRoute()) {
      return;
    }

    if (Get.currentRoute != RouteHelper.getSignInRoute('splash') &&
        Get.currentRoute != RouteHelper.getSignInRoute('LogIn')) {
      Get.offAllNamed(RouteHelper.getSignInRoute('splash'));
      if (isLoggedIn) {
        final message = errorMessage ??
            response.statusText ??
            'Session expired. Please sign in again.';
        if (message.isNotEmpty) {
          showCustomSnackBar(message);
        }
      }
    }
  }

  static Future<void> _handleUnauthorizedLogout() async {
    await Get.find<AuthController>().clearSharedData();
    Get.find<UserProfileController>().clearUserProfileData();
  }

  static void _showErrorMessage(Response response) {
    final extracted = ApiErrorHelper.extractMessage(response);
    if (extracted != null && extracted.isNotEmpty) {
      showCustomSnackBar(trLabel(extracted, fallback: extracted));
      return;
    }

    if (response.statusCode == 500) {
      showCustomSnackBar(trLabel('internal_server_error'));
      return;
    }

    showCustomSnackBar(trLabel('something_went_wrong'));
  }
}
