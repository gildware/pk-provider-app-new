import 'package:demandium_provider/firebase_options.dart';
import 'package:demandium_provider/helper/error_logger.dart';
import 'package:demandium_provider/helper/get_di.dart' as di;
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class AppStartup {
  AppStartup._();

  static Future<void>? _deferredFuture;
  static NotificationBody? initialNotificationBody;

  static Future<Map<String, Map<String, String>>> prepareForRunApp() async {
    final results = await Future.wait([
      di.init(),
      _initFirebase(),
    ]);
    return results.first as Map<String, Map<String, String>>;
  }

  static Future<void> _initFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (!kIsWeb) {
        await ErrorLogger.initialize();
      }
    } catch (e, stack) {
      ErrorLogger.record(e, stack, reason: 'Firebase.initializeApp');
    }
  }

  static void scheduleDeferredInit(FlutterLocalNotificationsPlugin notificationsPlugin) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deferredFuture ??= _runDeferredInit(notificationsPlugin);
    });
  }

  static Future<void> ensureDeferredReady() {
    return _deferredFuture ?? Future.value();
  }

  static Future<void> _runDeferredInit(
    FlutterLocalNotificationsPlugin notificationsPlugin,
  ) async {
    if (!GetPlatform.isMobile) {
      return;
    }

    try {
      await _requestNotificationPermission();
    } catch (e, stack) {
      ErrorLogger.record(e, stack, reason: 'AppStartup.FCM permission');
    }

    try {
      await FlutterDownloader.initialize();
    } catch (e, stack) {
      ErrorLogger.record(e, stack, reason: 'AppStartup.FlutterDownloader');
    }

    try {
      final remoteMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null) {
        initialNotificationBody = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(notificationsPlugin);
    } catch (e, stack) {
      ErrorLogger.record(e, stack, reason: 'AppStartup.deferredNotifications');
    }
  }

  static Future<void> _requestNotificationPermission() async {
    if (GetPlatform.isIOS) {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (GetPlatform.isAndroid) {
      await Permission.notification.request();
    }

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
