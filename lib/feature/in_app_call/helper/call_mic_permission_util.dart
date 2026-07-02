import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

class CallMicPermissionUtil {
  static Future<bool> ensureGranted() async {
    if (kIsWeb) return true;

    if (Platform.isIOS) {
      return _ensureOnIos();
    }

    var status = await Permission.microphone.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied || status.isRestricted) {
      return false;
    }

    status = await Permission.microphone.request();
    return status.isGranted;
  }

  static Future<void> openSettingsIfNeeded() async {
    if (kIsWeb) return;

    if (Platform.isIOS) {
      final status = await Permission.microphone.status;
      if (status.isPermanentlyDenied || status.isRestricted) {
        await openAppSettings();
      }
      return;
    }

    final status = await Permission.microphone.status;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  static Future<bool> _ensureOnIos() async {
    final existing = await Permission.microphone.status;
    if (existing.isGranted) return true;

    try {
      final stream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': false,
      });
      for (final track in stream.getTracks()) {
        track.stop();
      }
      await stream.dispose();
      return true;
    } catch (_) {
      final after = await Permission.microphone.status;
      return after.isGranted;
    }
  }
}
