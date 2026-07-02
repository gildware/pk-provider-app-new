import 'package:demandium_provider/feature/splash/controller/splash_controller.dart';
import 'package:demandium_provider/helper/mobile_app_icon_helper.dart';
import 'package:demandium_provider/util/app_constants.dart';
import 'package:demandium_provider/util/images.dart';
import 'package:get/get.dart';

class AdminChatBrandingHelper {
  AdminChatBrandingHelper._();

  static String get displayName {
    if (Get.isRegistered<SplashController>()) {
      final name = Get.find<SplashController>()
          .configModel
          .content
          ?.businessName
          ?.trim();
      if (name != null && name.isNotEmpty) {
        return name;
      }
    }
    return AppConstants.appName;
  }

  static String get adminPhone {
    if (Get.isRegistered<SplashController>()) {
      final phone = Get.find<SplashController>()
          .configModel
          .content
          ?.businessPhone
          ?.toString()
          .trim();
      if (phone != null && phone.isNotEmpty) {
        return phone;
      }
    }
    return '';
  }

  static bool isSuperAdmin(String? userType) {
    final normalized = userType?.toLowerCase().trim() ?? '';
    return normalized == 'super-admin' ||
        normalized == 'supper-admin' ||
        normalized == 'super_admin' ||
        normalized == 'admin-employee' ||
        normalized == 'admin' ||
        normalized == 'staff';
  }

  static String logoImageUrl() => MobileAppIconHelper.customerAppLogoUrl() ?? '';

  static String get logoPlaceholder => Images.logo;

  static String chatImageUrl({required String? userType, String? fallback}) {
    if (isSuperAdmin(userType)) {
      return logoImageUrl();
    }
    return fallback?.trim() ?? '';
  }

  static String chatPhone({required String? userType, String? fallback}) {
    if (isSuperAdmin(userType)) {
      return adminPhone;
    }
    return fallback?.trim() ?? '';
  }
}
