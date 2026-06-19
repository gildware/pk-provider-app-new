enum DataSourceEnum { client, local }

enum LocalCachesTypeEnum { all, none }

enum ApiMethodType { get, post }

enum SendOtpType {forgetPassword, firebase, verification}
enum LoginMedium { manual, otp }
enum SignUpPageStep {step1, step2, step3}
enum ProviderType {individual, company}
enum BusinessPlanType {commissionBase, subscriptionBase}
enum SubscriptionPaymentType {freeTrail, digital}
enum BookingDetailsTabControllerState {bookingDetails, payments, revenue, status, history}
enum ServicemanTabControllerState {generalInfo,accountIno}
enum FileType{png,jpg,jpeg,csv,txt,xlx,xls,pdf}
enum ToasterMessageType {success, error, info}
enum ServiceType { all, regular, repeat}
enum CalendarViewType { month, week, day }

extension ServiceTypeExtension on ServiceType {
  /// Get the API value for this service type
  String get value {
    switch (this) {
      case ServiceType.all:
        return 'all';
      case ServiceType.regular:
        return 'regular_booking';
      case ServiceType.repeat:
        return 'repeat';
    }
  }

  /// Get the translation key for this service type
  String get translationKey {
    switch (this) {
      case ServiceType.all:
        return 'all';
      case ServiceType.regular:
        return 'regular';
      case ServiceType.repeat:
        return 'repeat';
    }
  }

  /// Parse from API value string
  static ServiceType serviceTypeFromValue(String value) {
    switch (value) {
      case 'all':
        return ServiceType.all;
      case 'regular':
        return ServiceType.regular;
      case 'repeat':
        return ServiceType.repeat;
      default:
        return ServiceType.all;
    }
  }
}

enum BookingStatusEnum {
  pending,
  accepted,
  ongoing,
  onHold,
  completed,
  canceled,
  refunded,
}

extension BookingStatusEnumExtension on BookingStatusEnum {
  /// Get the API value for this booking status
  String get value {
    switch (this) {
      case BookingStatusEnum.pending:
        return 'pending';
      case BookingStatusEnum.accepted:
        return 'accepted';
      case BookingStatusEnum.ongoing:
        return 'ongoing';
      case BookingStatusEnum.onHold:
        return 'on_hold';
      case BookingStatusEnum.completed:
        return 'completed';
      case BookingStatusEnum.canceled:
        return 'canceled';
      case BookingStatusEnum.refunded:
        return 'refunded';
    }
  }

  /// Get the translation key for this booking status
  String get translationKey {
    switch (this) {
      case BookingStatusEnum.pending:
        return 'pending';
      case BookingStatusEnum.accepted:
        return 'accepted';
      case BookingStatusEnum.ongoing:
        return 'ongoing';
      case BookingStatusEnum.onHold:
        return 'on_hold';
      case BookingStatusEnum.completed:
        return 'completed';
      case BookingStatusEnum.canceled:
        return 'canceled';
      case BookingStatusEnum.refunded:
        return 'refunded';
    }
  }

  /// Parse from API value string
  static BookingStatusEnum? fromValue(String value) {
    for (var status in BookingStatusEnum.values) {
      if (status.value == value) {
        return status;
      }
    }
    return null;
  }
}


enum BookingEditType { regular , repeat, subBooking}
enum ServiceLocationType {customer, provider}
enum AddressLabel {home, office, others }
enum AddressType {service, billing }

enum HtmlType {
  termsAndCondition('terms-and-conditions'),
  aboutUs('about-us'),
  privacyPolicy('privacy-policy'),
  cancellationPolicy('cancellation-policy'),
  refundPolicy('refund-policy'),
  others('');

  final String value;
  const HtmlType(this.value);

  /// Hidden from menus until re-enabled in the app.
  bool get isDisabledInApp =>
      this == HtmlType.cancellationPolicy || this == HtmlType.refundPolicy;

  static const Set<String> _hiddenPageKeys = {
    'cancellation-policy',
    'refund-policy',
    'cancellation_policy',
    'refund_policy',
  };

  static bool isVisibleBusinessPage(String? pageKey, {String? title}) {
    if (pageKey == null || pageKey.isEmpty) return false;
    final normalizedKey = pageKey.trim().toLowerCase();
    if (_hiddenPageKeys.contains(normalizedKey)) return false;
    final normalizedTitle = (title ?? '').trim().toLowerCase();
    if (normalizedTitle.contains('cancellation policy') ||
        normalizedTitle.contains('refund policy')) {
      return false;
    }
    return true;
  }

  /// Convert string to enum
  static HtmlType? fromValue(String value) {
    return HtmlType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => others,
    );
  }
}

enum NoDataType {
  request,
  notification,
  faq,
  conversation,
  transaction,
  others,
  service,
  customPost,
  myBids,
  subscriptions,
  none,
  advertisement,
  paymentInfo
}

enum TransactionType {none ,payable, withdrawAble, adjust , adjustAndPayable, adjustWithdrawAble}
enum UserAccountStatus {deletable ,haveExistingBooking, needPaymentSettled}