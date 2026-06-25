class BookingNotificationConstants {
  BookingNotificationConstants._();

  static const String iosCategoryId = 'booking_alert';
  static const String acceptActionId = 'accept_booking';
  static const String rejectActionId = 'ignore_booking';

  static bool isIncomingBookingRequest(String? type) => type == 'booking';

  static bool isPendingBookingAcceptance(Map<String, dynamic> data) {
    if (data['type']?.toString() != 'booking') {
      return false;
    }
    return data['booking_status']?.toString().toLowerCase() == 'pending';
  }

  static int notificationIdFor(String bookingId) =>
      bookingId.hashCode & 0x7FFFFFFF;
}
