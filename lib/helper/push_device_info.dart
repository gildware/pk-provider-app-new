import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class PushDeviceInfo {
  static Future<Map<String, String?>> collect() async {
    if (kIsWeb) {
      return const {
        'platform': 'web',
        'device_model': 'Web browser',
        'device_manufacturer': null,
        'os_version': null,
      };
    }

    final plugin = DeviceInfoPlugin();

    if (GetPlatform.isAndroid) {
      final info = await plugin.androidInfo;

      return {
        'platform': 'android',
        'device_model': info.model,
        'device_manufacturer': info.manufacturer,
        'os_version': 'Android ${info.version.release}',
      };
    }

    if (GetPlatform.isIOS) {
      final info = await plugin.iosInfo;

      return {
        'platform': 'ios',
        'device_model': info.utsname.machine,
        'device_manufacturer': 'Apple',
        'os_version': 'iOS ${info.systemVersion}',
      };
    }

    return {
      'platform': _pushPlatform(),
      'device_model': null,
      'device_manufacturer': null,
      'os_version': null,
    };
  }

  static String _pushPlatform() {
    if (GetPlatform.isWeb) return 'web';
    if (GetPlatform.isIOS) return 'ios';
    return 'android';
  }
}
