import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/feature/splash/controller/splash_controller.dart';
import 'package:demandium_provider/util/app_constants.dart';
import 'package:demandium_provider/util/images.dart';

/// Resolves menu / branding icons from admin `mobile_app_icons` API or bundled assets.
class MobileAppIconHelper {
  static const String loginLogoKey = 'provider_app_login_logo';
  static const String homeLogoKey = 'provider_app_home_logo';
  static const String legacyLogoKey = 'provider_app_logo';

  static const String heroTag = 'app_logo';

  static String get _apiBase {
    var base = AppConstants.baseUrl.trim();
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    return base;
  }

  static Map<String, Map<String, String?>>? get _icons {
    try {
      final raw = Get.find<SplashController>().configModel.content?.mobileAppIcons;
      if (raw == null || raw.isEmpty) {
        return null;
      }
      return raw;
    } catch (_) {
      return null;
    }
  }

  static bool get _isDark => Get.isDarkMode;

  /// Turns API paths (/storage/...) or remote URLs into a URL the app can load.
  static String? resolveMediaUrl(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'null') {
      return null;
    }

    if (trimmed.startsWith('/storage/')) {
      return '$_apiBase$trimmed';
    }

    if (trimmed.startsWith('storage/')) {
      return '$_apiBase/$trimmed';
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      try {
        final parsed = Uri.parse(trimmed);
        var path = parsed.path;
        if (path.startsWith('/public/storage/')) {
          path = path.replaceFirst('/public/storage/', '/storage/');
        }
        final storageIdx = path.indexOf('/storage/');
        if (storageIdx >= 0) {
          path = path.substring(storageIdx);
          return '$_apiBase$path';
        }
      } catch (_) {
        //
      }
      return trimmed;
    }

    try {
      final parsed = Uri.parse(trimmed);
      var path = parsed.path;
      if (path.startsWith('/public/storage/')) {
        path = path.replaceFirst('/public/storage/', '/storage/');
      }
      if (path.startsWith('/storage/')) {
        return '$_apiBase$path';
      }
    } catch (_) {
      //
    }

    return trimmed;
  }

  static String? remoteUrl(String key) {
    final entry = _icons?[key];
    if (entry == null) {
      return null;
    }
    final raw = _isDark ? (entry['dark'] ?? entry['light']) : (entry['light'] ?? entry['dark']);
    return resolveMediaUrl(raw);
  }

  static String? logoUrlForKey(String primaryKey) {
    final custom = remoteUrl(primaryKey) ?? remoteUrl(legacyLogoKey);
    if (custom != null && custom.isNotEmpty) {
      return custom;
    }
    return resolveMediaUrl(
      Get.find<SplashController>().configModel.content?.logoFullPath,
    );
  }

  static Widget loginLogo({
    required double width,
    double? height,
    BoxFit fit = BoxFit.contain,
    bool useHero = false,
    String? heroTag,
  }) {
    return _BrandedLogo(
      logoKey: loginLogoKey,
      width: width,
      height: height,
      fit: fit,
      fallbackAsset: Images.logo,
      useHero: useHero,
      heroTag: heroTag,
    );
  }

  static Widget homeLogo({
    required double width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return _BrandedLogo(
      logoKey: homeLogoKey,
      width: width,
      height: height,
      fit: fit,
      fallbackAsset: Images.logo,
    );
  }

  static Widget homeLeadingLogo({
    required double width,
    double? height,
    BoxFit fit = BoxFit.fitWidth,
  }) {
    return _BrandedLogo(
      logoKey: homeLogoKey,
      width: width,
      height: height,
      fit: fit,
      fallbackAsset: Images.appbarLogo,
    );
  }

  static Widget icon({
    required String key,
    required String fallbackAsset,
    double height = 30,
    double width = 30,
    BoxFit fit = BoxFit.contain,
    Color? color,
  }) {
    return _BrandedIcon(
      iconKey: key,
      fallbackAsset: fallbackAsset,
      height: height,
      width: width,
      fit: fit,
      color: color,
    );
  }
}

class _BrandedLogo extends StatelessWidget {
  final String logoKey;
  final double width;
  final double? height;
  final BoxFit fit;
  final String fallbackAsset;
  final bool useHero;
  final String? heroTag;

  const _BrandedLogo({
    required this.logoKey,
    required this.width,
    this.height,
    required this.fit,
    required this.fallbackAsset,
    this.useHero = false,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      builder: (_) {
        final h = height ?? width;
        final remote = MobileAppIconHelper.logoUrlForKey(logoKey);

        Widget child = _NetworkOrAssetImage(
          url: remote,
          width: width,
          height: h,
          fit: fit,
          fallbackAsset: fallbackAsset,
        );

        if (useHero) {
          child = Hero(
            tag: heroTag ?? MobileAppIconHelper.heroTag,
            child: child,
          );
        }

        return child;
      },
    );
  }
}

class _BrandedIcon extends StatelessWidget {
  final String iconKey;
  final String fallbackAsset;
  final double height;
  final double width;
  final BoxFit fit;
  final Color? color;

  const _BrandedIcon({
    required this.iconKey,
    required this.fallbackAsset,
    required this.height,
    required this.width,
    required this.fit,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      builder: (_) {
        return _NetworkOrAssetImage(
          url: MobileAppIconHelper.remoteUrl(iconKey),
          width: width,
          height: height,
          fit: fit,
          fallbackAsset: fallbackAsset,
          color: color,
        );
      },
    );
  }
}

class _NetworkOrAssetImage extends StatelessWidget {
  final String? url;
  final double width;
  final double height;
  final BoxFit fit;
  final String fallbackAsset;
  final Color? color;

  const _NetworkOrAssetImage({
    required this.url,
    required this.width,
    required this.height,
    required this.fit,
    required this.fallbackAsset,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Image.asset(
        fallbackAsset,
        width: width,
        height: height,
        fit: fit,
        color: color,
      );
    }

    return Image.network(
      url!,
      width: width,
      height: height,
      fit: fit,
      color: color,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, error, stack) => Image.asset(
        fallbackAsset,
        width: width,
        height: height,
        fit: fit,
        color: color,
      ),
      loadingBuilder: (_, child, progress) {
        if (progress == null) {
          return child;
        }
        return Image.asset(
          fallbackAsset,
          width: width,
          height: height,
          fit: fit,
          color: color,
        );
      },
    );
  }
}
