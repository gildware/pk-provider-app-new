import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      // Avoid iCloud Keychain sync sharing one push_device_id across iPhones.
      synchronizable: false,
    ),
  );

  static const String _deviceIdKey = 'push_device_id';
  static const String _legacyPrefsKey = 'push_device_id';

  static String _memoryCache = '';

  static Future<String> getOrCreate([SharedPreferences? sharedPreferences]) async {
    if (_memoryCache.isNotEmpty) {
      return _memoryCache;
    }

    final hardwareId = await _hardwareDeviceId();
    if (hardwareId != null && hardwareId.isNotEmpty) {
      _memoryCache = hardwareId;
      return hardwareId;
    }

    if (sharedPreferences != null) {
      await _migrateLegacy(sharedPreferences);
    }

    final stored = await _storage.read(key: _deviceIdKey);
    if (stored != null && stored.isNotEmpty) {
      _memoryCache = stored;
      return stored;
    }

    final generated = _generateId();
    _memoryCache = generated;
    await _storage.write(key: _deviceIdKey, value: generated);
    return generated;
  }

  static Future<String?> _hardwareDeviceId() async {
    if (kIsWeb) {
      return null;
    }

    try {
      final plugin = DeviceInfoPlugin();

      if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await plugin.androidInfo;
        final androidId = info.id.trim();
        if (androidId.isNotEmpty && androidId != 'unknown') {
          return 'android:$androidId';
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final info = await plugin.iosInfo;
        final vendorId = info.identifierForVendor?.trim() ?? '';
        if (vendorId.isNotEmpty) {
          return 'ios:$vendorId';
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static Future<void> _migrateLegacy(SharedPreferences sharedPreferences) async {
    final legacy = sharedPreferences.getString(_legacyPrefsKey);
    if (legacy != null && legacy.isNotEmpty) {
      await _storage.write(key: _deviceIdKey, value: legacy);
      await sharedPreferences.remove(_legacyPrefsKey);
      _memoryCache = legacy;
    }
  }

  static String _generateId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
