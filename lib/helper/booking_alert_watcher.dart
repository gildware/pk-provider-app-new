import 'dart:async';

import 'package:demandium_provider/feature/auth/controller/auth_controller.dart';
import 'package:demandium_provider/feature/booking_requests/controller/booking_request_controller.dart';
import 'package:demandium_provider/feature/booking_requests/repo/service_request_repo.dart';
import 'package:demandium_provider/feature/dashboard/controller/dashboard_controller.dart';
import 'package:demandium_provider/feature/profile/controller/user_controller.dart';
import 'package:demandium_provider/helper/booking_notification_action_handler.dart';
import 'package:demandium_provider/common/enums/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class BookingAlertWatcher extends GetxService with WidgetsBindingObserver {
  Timer? _timer;
  bool _baselineEstablished = false;
  final Set<String> _knownPendingBookingIds = <String>{};
  bool _isForeground = true;

  static const Duration pollInterval = Duration(seconds: 10);

  void start() {
    if (!GetPlatform.isMobile) {
      return;
    }
    WidgetsBinding.instance.addObserver(this);
    _timer?.cancel();
    _timer = Timer.periodic(pollInterval, (_) => unawaited(_pollPendingBookings()));
    unawaited(_pollPendingBookings());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    WidgetsBinding.instance.removeObserver(this);
    _baselineEstablished = false;
    _knownPendingBookingIds.clear();
  }

  void resetBaseline() {
    _baselineEstablished = false;
    _knownPendingBookingIds.clear();
  }

  static void markBookingHandled(String bookingId) {
    if (Get.isRegistered<BookingAlertWatcher>()) {
      Get.find<BookingAlertWatcher>()._knownPendingBookingIds.add(bookingId);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isForeground = state == AppLifecycleState.resumed;
    if (_isForeground) {
      unawaited(_pollPendingBookings());
    }
  }

  bool _canPoll() {
    if (!_isForeground) {
      return false;
    }
    if (!Get.isRegistered<AuthController>() ||
        !Get.find<AuthController>().isLoggedIn()) {
      return false;
    }
    if (!Get.isRegistered<UserProfileController>()) {
      return false;
    }
    final profile = Get.find<UserProfileController>();
    if (profile.isPendingAdminVerification) {
      return false;
    }
    if (profile.providerModel?.content?.providerInfo?.serviceAvailability != 1) {
      return false;
    }
    return true;
  }

  Future<void> _pollPendingBookings() async {
    if (!_canPoll()) {
      return;
    }
    if (!Get.isRegistered<BookingRequestRepo>()) {
      return;
    }

    try {
      final response = await Get.find<BookingRequestRepo>().getBookingRequestData(
        'pending',
        1,
        ServiceType.all,
      );
      if (response.statusCode != 200) {
        return;
      }

      final bookings =
          response.body['content']?['bookings']?['data'] as List<dynamic>? ??
          [];

      for (final raw in bookings) {
        if (raw is! Map) {
          continue;
        }
        final booking = Map<String, dynamic>.from(raw);
        final bookingId = booking['id']?.toString();
        if (bookingId == null || bookingId.isEmpty) {
          continue;
        }

        if (_knownPendingBookingIds.contains(bookingId)) {
          continue;
        }

        _knownPendingBookingIds.add(bookingId);

        if (_baselineEstablished) {
          await _presentNewBookingAlert(booking);
        }
      }

      _baselineEstablished = true;
    } catch (e) {
      if (kDebugMode) {
        print('BookingAlertWatcher poll failed: $e');
      }
    }
  }

  Future<void> _presentNewBookingAlert(Map<String, dynamic> booking) async {
    final bookingId = booking['id']?.toString() ?? '';
    if (bookingId.isEmpty) {
      return;
    }

    final readableId = booking['readable_id']?.toString();
    final subCategory = booking['sub_category']?['name']?.toString();
    final title = readableId != null && readableId.isNotEmpty
        ? 'Booking #$readableId'
        : 'New Booking Received';
    final body = subCategory ?? '';

    final data = <String, dynamic>{
      'type': 'booking',
      'booking_id': bookingId,
      'title': title,
      'body': body,
      'booking_type': booking['is_repeat_booking'] == 1 ? 'repeat' : 'regular',
      'repeat_type': booking['booking_type']?.toString() ?? '',
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      BookingNotificationActionHandler.showBookingAlert(data);
    });

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
}
