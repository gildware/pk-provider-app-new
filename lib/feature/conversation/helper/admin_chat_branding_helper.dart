import 'package:demandium_provider/feature/splash/controller/splash_controller.dart';
import 'package:demandium_provider/helper/mobile_app_icon_helper.dart';
import 'package:demandium_provider/util/app_constants.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:demandium_provider/util/images.dart';
import 'package:flutter/material.dart';
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

  static String logoImageUrl() {
    final url =
        MobileAppIconHelper.remoteUrl(MobileAppIconHelper.customerAppLogoKey) ?? '';
    if (_isBusinessLogoUrl(url)) {
      return '';
    }
    return url;
  }

  static String get logoPlaceholder => Images.logo;

  static Widget supportAvatar({required double size}) {
    final url = logoImageUrl();
    if (url.isEmpty) {
      return Image.asset(
        logoPlaceholder,
        height: size,
        width: size,
        fit: BoxFit.contain,
      );
    }

    return CustomImage(
      image: url,
      height: size,
      width: size,
      fit: BoxFit.contain,
      placeHolderBoxFit: BoxFit.contain,
      placeholder: logoPlaceholder,
    );
  }

  static bool _isBusinessLogoUrl(String url) {
    if (url.isEmpty) {
      return false;
    }
    final businessLogo = MobileAppIconHelper.normalizeMediaUrl(
      Get.find<SplashController>().configModel.content?.logoFullPath,
    );
    return businessLogo != null && businessLogo.isNotEmpty && url == businessLogo;
  }

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
