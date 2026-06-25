import 'dart:convert';

import 'package:demandium_provider/common/model/notification_body.dart';
import 'package:demandium_provider/helper/booking_alert_watcher.dart';
import 'package:demandium_provider/common/widgets/booking_alert_dialog_widget.dart';
import 'package:demandium_provider/feature/booking_details/controller/booking_details_controller.dart';
import 'package:demandium_provider/feature/booking_requests/controller/booking_request_controller.dart';
import 'package:demandium_provider/feature/dashboard/controller/dashboard_controller.dart';
import 'package:demandium_provider/firebase_options.dart';
import 'package:demandium_provider/helper/booking_notification_constants.dart';
import 'package:demandium_provider/helper/secure_token_storage.dart';
import 'package:demandium_provider/util/app_constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void bookingNotificationBackgroundHandler(NotificationResponse response) {
  BookingNotificationActionHandler.handleResponse(
    response,
    fromBackground: true,
  );
}

class BookingNotificationActionHandler {
  static final Set<String> _shownAlertBookingIds = <String>{};

  static Future<void> handleResponse(
    NotificationResponse response, {
    required bool fromBackground,
  }) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      return;
    }

    Map<String, dynamic> data;
    try {
      data = Map<String, dynamic>.from(jsonDecode(payload));
    } catch (_) {
      return;
    }

    if (!BookingNotificationConstants.isPendingBookingAcceptance(data)) {
      return;
    }

    final bookingId = data['booking_id']?.toString();
    if (bookingId == null || bookingId.isEmpty) {
      return;
    }

    final actionId = response.actionId;
    if (actionId == BookingNotificationConstants.acceptActionId) {
      await _performBookingAction(
        accept: true,
        bookingId: bookingId,
        cancelNotification: true,
      );
      BookingAlertWatcher.markBookingHandled(bookingId);
      if (!fromBackground) {
        _refreshBookingData();
      }
      return;
    }

    if (actionId == BookingNotificationConstants.rejectActionId) {
      await _performBookingAction(
        accept: false,
        bookingId: bookingId,
        cancelNotification: true,
      );
      BookingAlertWatcher.markBookingHandled(bookingId);
      if (!fromBackground) {
        _refreshBookingData();
      }
      return;
    }

    if (!fromBackground) {
      showBookingAlert(data);
    }
  }

  static void showBookingAlert(Map<String, dynamic> data) {
    if (!BookingNotificationConstants.isPendingBookingAcceptance(data)) {
      return;
    }

    final bookingId = data['booking_id']?.toString();
    if (bookingId == null || bookingId.isEmpty) {
      return;
    }
    if (_shownAlertBookingIds.contains(bookingId)) {
      return;
    }
    if (Get.isDialogOpen == true) {
      return;
    }

    _shownAlertBookingIds.add(bookingId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen == true) {
        _shownAlertBookingIds.remove(bookingId);
        return;
      }
      Get.dialog(
        BookingAlertDialogWidget(
          bookingId: bookingId,
          title: data['title']?.toString() ?? 'new_booking_received'.tr,
          body: data['body']?.toString() ?? '',
          bookingType: data['booking_type']?.toString(),
          repeatBookingType: data['repeat_type']?.toString(),
          onClosed: () => _shownAlertBookingIds.remove(bookingId),
        ),
        barrierDismissible: false,
      ).whenComplete(() => _shownAlertBookingIds.remove(bookingId));
    });
  }

  static void showBookingAlertFromBody(NotificationBody body) {
    showBookingAlert(body.toJson());
  }

  static void _refreshBookingData() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().getDashboardData(reload: true);
    }
    if (Get.isRegistered<BookingRequestController>()) {
      Get.find<BookingRequestController>().getBookingRequestList(
        Get.find<BookingRequestController>().bookingStatus,
        1,
        reload: true,
      );
    }
  }

  static Future<void> _performBookingAction({
    required bool accept,
    required String bookingId,
    required bool cancelNotification,
  }) async {
    if (!_isAppInitialized()) {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await SecureTokenStorage.preload(prefs);
    final token = SecureTokenStorage.cachedToken();
    if (token.isEmpty) {
      return;
    }

    final languageCode =
        prefs.getString(AppConstants.languageCode) ??
        AppConstants.languages.first.languageCode ??
        'en';
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
      AppConstants.localizationKey: languageCode,
      'Accept': 'application/json',
    };

    final uri = accept
        ? Uri.parse(
            '${AppConstants.baseUrl}${AppConstants.acceptBookingRequestUrl}/$bookingId',
          )
        : Uri.parse(
            '${AppConstants.baseUrl}${AppConstants.ignoreBookingRequestUrl}/$bookingId',
          );

    try {
      final response = accept
          ? await http
                .put(uri, headers: headers, body: jsonEncode({'method': 'put'}))
                .timeout(const Duration(seconds: 30))
          : await http
                .post(uri, headers: headers, body: jsonEncode({}))
                .timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print(
          'Booking notification action ${accept ? 'accept' : 'reject'}: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Booking notification action failed: $e');
      }
    }

    if (cancelNotification) {
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.cancel(
        id: BookingNotificationConstants.notificationIdFor(bookingId),
      );
    }
  }

  static bool _isAppInitialized() => Get.isRegistered<SharedPreferences>();

  static Future<void> acceptFromDialog(String bookingId) async {
    if (!Get.isRegistered<BookingDetailsController>()) {
      await _performBookingAction(
        accept: true,
        bookingId: bookingId,
        cancelNotification: true,
      );
      _refreshBookingData();
      return;
    }

    await Get.find<BookingDetailsController>().acceptBookingRequest(bookingId);
    await FlutterLocalNotificationsPlugin().cancel(
      id: BookingNotificationConstants.notificationIdFor(bookingId),
    );
    BookingAlertWatcher.markBookingHandled(bookingId);
    _refreshBookingData();
  }

  static Future<void> rejectFromDialog(String bookingId) async {
    if (!Get.isRegistered<BookingDetailsController>()) {
      await _performBookingAction(
        accept: false,
        bookingId: bookingId,
        cancelNotification: true,
      );
      _refreshBookingData();
      return;
    }

    await Get.find<BookingDetailsController>().ignoreBookingRequest(bookingId);
    await FlutterLocalNotificationsPlugin().cancel(
      id: BookingNotificationConstants.notificationIdFor(bookingId),
    );
    BookingAlertWatcher.markBookingHandled(bookingId);
    _refreshBookingData();
  }
}
