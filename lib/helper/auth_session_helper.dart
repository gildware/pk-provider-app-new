import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

/// Keeps [SecureTokenStorage], [ApiClient.token], and request headers aligned.
class AuthSessionHelper {
  AuthSessionHelper._();

  static const _publicRoutes = {
    RouteHelper.splash,
    RouteHelper.signIn,
    RouteHelper.signUp,
    RouteHelper.language,
    RouteHelper.languageScreen,
    RouteHelper.update,
    RouteHelper.maintenanceRoute,
    RouteHelper.sendOtpScreen,
    RouteHelper.verification,
    RouteHelper.changePassword,
    RouteHelper.html,
  };

  static Future<void> syncFromStorage() async {
    if (!Get.isRegistered<SharedPreferences>()) {
      return;
    }

    final sharedPreferences = Get.find<SharedPreferences>();
    await SecureTokenStorage.preload(sharedPreferences);

    if (!Get.isRegistered<ApiClient>()) {
      return;
    }

    final apiClient = Get.find<ApiClient>();
    final token = SecureTokenStorage.cachedToken();
    apiClient.token = token.isEmpty ? null : token;
    apiClient.updateHeader(
      apiClient.token,
      sharedPreferences.getString(AppConstants.languageCode),
    );
  }

  static bool isProtectedRoute([String? route]) {
    final path = (route ?? Get.currentRoute).split('?').first;
    return !_publicRoutes.contains(path);
  }

  static void redirectToSignInIfNeeded() {
    if (!Get.isRegistered<AuthController>()) {
      return;
    }
    if (!Get.find<AuthController>().isLoggedIn() && isProtectedRoute()) {
      Get.offAllNamed(RouteHelper.getSignInRoute('LogIn'));
    }
  }
}
