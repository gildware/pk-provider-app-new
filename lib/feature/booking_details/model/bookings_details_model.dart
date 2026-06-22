import 'package:demandium_provider/common/model/booking_status_ui_model.dart';
import 'package:demandium_provider/feature/dashboard/model/dashboard_serviceman_model.dart';
import 'package:demandium_provider/feature/review/model/review_model.dart';
import 'package:demandium_provider/feature/serviceman/model/service_man_model.dart';

class BookingDetailsModel {
  String? responseCode;
  String? message;
  BookingDetailsContent? content;

  BookingDetailsModel({this.responseCode, this.message, this.content});

  BookingDetailsModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    content = json['content'] != null ? BookingDetailsContent.fromJson(json['content']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['message'] = message;
    if (content != null) {
      data['content'] = content!.toJson();
    }
    return data;
  }
}

class BookingDetailsContent {
  String? id;
  String? readableId;
  /// Parent booking UUID when this row is a repeat visit (`booking_id` from API).
  String? parentBookingId;
  String? customerId;
  String? providerId;
  String? zoneId;
  String? bookingStatus;
  int? isPaid;
  String? paymentMethod;
  String? transactionId;
  double? totalBookingAmount;
  double? payableGrandTotal;
  double? listDisplayTotal;
  double? totalTaxAmount;
  double? totalDiscountAmount;
  String? serviceSchedule;
  String? serviceAddressId;
  String? createdAt;
  String? updatedAt;
  String? servicemanId;
  String? categoryId;
  String? subcategoryId;
  BookingCategoryInfo? category;
  BookingCategoryInfo? subCategory;
  List<ItemService>? details;
  List<ScheduleHistories>? scheduleHistories;
  List<StatusHistories>? statusHistories;
  List<PartialPayment>? partialPayments;
  ServiceAddress? serviceAddress;
  String? offlinePaymentMethodName;
  List<BookingOfflinePayment>? bookingOfflinePayment;
  Customer? customer;
  Provider? provider;
  BookingDetailsServiceman? serviceman;
  double ? totalCampaignDiscountAmount;
  double ? totalCouponDiscountAmount;
  double ? additionalCharge;
  List<String>? photoEvidence;
  List<String>? photoEvidenceFullPath;
  double? extraFee;
  int? isGuest;
  double ? totalReferralDiscountAmount;
  int? isRepeatBooking;
  String? time;
  String? startDate;
  String? endDate;
  int? totalCount;
  String? bookingType;
  List<String>? weekNames;
  int? completedCount;
  int? canceledCount;
  BookingDetailsContent? nextService;
  List<RepeatBooking>? repeatBookingList;
  List<RepeatHistory>? repeatEditHistory;
  BookingDetailsContent? subBooking;
  String? serviceLocation;
  BookingStatusUiFields? statusUi;
  PaymentDetailsSummary? paymentDetails;
  BookingPaymentLedger? paymentLedger;
  RevenueSettlement? revenueSettlement;
  ServiceLocationDetails? serviceLocationDetails;
  ProviderBookingSummary? bookingSummary;
  List<ProviderExtraServiceLine>? extraServiceLines;
  List<BookingChangeLog>? changeLogs;
  LossMakingSettlement? lossMakingSettlement;
  SpecialFinancialSettlement? specialFinancialSettlement;
  DisputedSettlement? disputedSettlement;

  BookingDetailsContent({
    this.id,
    this.readableId,
    this.parentBookingId,
    this.customerId,
    this.providerId,
    this.zoneId,
    this.bookingStatus,
    this.isPaid,
    this.paymentMethod,
    this.transactionId,
    this.totalBookingAmount,
    this.payableGrandTotal,
    this.listDisplayTotal,
    this.totalTaxAmount,
    this.totalDiscountAmount,
    this.serviceSchedule,
    this.serviceAddressId,
    this.createdAt,
    this.updatedAt,
    this.servicemanId,
    this.details,
    this.scheduleHistories,
    this.statusHistories,
    this.partialPayments,
    this.serviceAddress,
    this.customer,
    this.provider,
    this.serviceman,
    this.totalCampaignDiscountAmount,
    this.totalCouponDiscountAmount,
    this.additionalCharge,
    this.photoEvidence,
    this.photoEvidenceFullPath,
    this.extraFee,
    this.isGuest,
    this.totalReferralDiscountAmount,
    this.categoryId,
    this.subcategoryId,
    this.category,
    this.subCategory,
    this.bookingOfflinePayment,
    this.offlinePaymentMethodName,
    this.time,
    this.startDate,
    this.endDate,
    this.totalCount,
    this.bookingType,
    this.completedCount,
    this.canceledCount,
    this.nextService,
    this.isRepeatBooking,
    this.weekNames,
    this.repeatBookingList,
    this.subBooking,
    this.repeatEditHistory,
    this.serviceLocation,
    this.statusUi,
    this.paymentDetails,
    this.paymentLedger,
    this.revenueSettlement,
    this.serviceLocationDetails,
    this.bookingSummary,
    this.extraServiceLines,
    this.changeLogs,
    this.lossMakingSettlement,
    this.specialFinancialSettlement,
  });

  BookingDetailsContent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    readableId = json['readable_id'].toString();
    parentBookingId = json['booking_id']?.toString();
    customerId = json['customer_id'];
    providerId = json['provider_id'];
    zoneId = json['zone_id'];
    bookingStatus = json['booking_status'];
    isPaid = json['is_paid'];
    paymentMethod = json['payment_method'];
    transactionId = json['transaction_id'];
    totalBookingAmount = double.tryParse(json['total_booking_amount'].toString());
    payableGrandTotal = double.tryParse(json['payable_grand_total']?.toString() ?? '');
    listDisplayTotal = double.tryParse(json['list_display_total']?.toString() ?? '');
    totalTaxAmount = double.tryParse(json['total_tax_amount'].toString());
    totalDiscountAmount = double.tryParse(json['total_discount_amount'].toString());
    serviceSchedule = json['service_schedule'];
    serviceAddressId = json['service_address_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    servicemanId = json['serviceman_id'];
    categoryId = json['category_id'];
    subcategoryId = json['sub_category_id'];
    category = json['category'] != null
        ? BookingCategoryInfo.fromJson(json['category'])
        : null;
    subCategory = json['sub_category'] != null
        ? BookingCategoryInfo.fromJson(json['sub_category'])
        : null;
    if (json['detail'] != null) {
      details = <ItemService>[];
      json['detail'].forEach((v) {
        details!.add(ItemService.fromJson(v));
      });
    }
    if (json['schedule_histories'] != null || json['scheduleHistories'] != null) {
      scheduleHistories = <ScheduleHistories>[];
      (json['schedule_histories'] ?? json['scheduleHistories']).forEach((v) {
        scheduleHistories!.add(ScheduleHistories.fromJson(v));
      });
    }
    if (json['status_histories'] != null || json['statusHistories'] != null) {
      statusHistories = <StatusHistories>[];
      (json['status_histories'] ?? json['statusHistories']).forEach((v) {

        statusHistories!.add(StatusHistories.fromJson(v));
      });
    }

    if (json['booking_partial_payments'] != null) {
      partialPayments = <PartialPayment>[];
      json['booking_partial_payments'].forEach((v) {
        partialPayments!.add(PartialPayment.fromJson(v));
      });
    }

    serviceAddress = json['service_address'] != null
        ? ServiceAddress.fromJson(json['service_address'])
        : null;


    if (json['booking_offline_payment'] != null) {
      bookingOfflinePayment = <BookingOfflinePayment>[];
      json['booking_offline_payment'].forEach((v) { bookingOfflinePayment!.add(
          BookingOfflinePayment.fromJson(v));
      });
    }


    customer = json['customer'] != null
        ? Customer.fromJson(json['customer'])
        : null;
    provider = json['provider'] != null
        ? Provider.fromJson(json['provider'])
        : null;

    serviceman = json['serviceman'] != null
        ? BookingDetailsServiceman.fromJson(json['serviceman'])
        : null;
    totalCampaignDiscountAmount = double.tryParse(json['total_campaign_discount_amount'].toString());
    totalCouponDiscountAmount = double.tryParse(json['total_coupon_discount_amount'].toString());
    additionalCharge = double.tryParse(json['additional_charge'].toString());
    totalReferralDiscountAmount = double.tryParse(json['total_referral_discount_amount'].toString());
    photoEvidence = json["evidence_photos"]!=null? json["evidence_photos"].cast<String>(): [];
    photoEvidenceFullPath = json["evidence_photos_full_path"]!=null? json["evidence_photos_full_path"].cast<String>(): [];
    extraFee = double.tryParse(json["extra_fee"].toString());
    isGuest = int.tryParse(json["is_guest"].toString());
    offlinePaymentMethodName = json["booking_offline_payment_method"];
    isRepeatBooking = int.tryParse(json['is_repeated'].toString());
    time = json['time'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    totalCount = json['totalCount'];
    bookingType = json['bookingType'];
    weekNames = json['weekNames']?.cast<String>();
    completedCount = json['completedCount'];
    canceledCount = json['canceledCount'];
    nextService = json['nextService'] != null
        ? BookingDetailsContent?.fromJson(json['nextService'])
        : null;
    if (json['repeats'] != null) {
      repeatBookingList = <RepeatBooking>[];
      json['repeats'].forEach((v) {
        repeatBookingList!.add(RepeatBooking.fromJson(v));
      });
    }
    subBooking = json['booking'] != null
        ? BookingDetailsContent.fromJson(json['booking'])
        : null;

    if (json['repeatHistory'] != null) {
      repeatEditHistory = <RepeatHistory>[];
      json['repeatHistory'].forEach((v) {
        repeatEditHistory!.add(RepeatHistory.fromJson(v));
      });
    }
    serviceLocation = json['service_location'];
    statusUi = BookingStatusUiFields.fromJson(json);
    paymentDetails = json['payment_details'] != null
        ? PaymentDetailsSummary.fromJson(json['payment_details'])
        : null;
    paymentLedger = json['payment_ledger'] != null
        ? BookingPaymentLedger.fromJson(json['payment_ledger'])
        : null;
    if (json['change_logs'] != null) {
      changeLogs = <BookingChangeLog>[];
      json['change_logs'].forEach((v) {
        changeLogs!.add(BookingChangeLog.fromJson(v));
      });
    }
    revenueSettlement = json['revenue_settlement'] != null
        ? RevenueSettlement.fromJson(json['revenue_settlement'])
        : null;
    serviceLocationDetails = json['service_location_details'] != null
        ? ServiceLocationDetails.fromJson(json['service_location_details'])
        : null;
    bookingSummary = json['booking_summary'] != null
        ? ProviderBookingSummary.fromJson(Map<String, dynamic>.from(json['booking_summary']))
        : null;
    if (json['extra_service_lines'] is List) {
      extraServiceLines = (json['extra_service_lines'] as List)
          .map((v) => ProviderExtraServiceLine.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }
    lossMakingSettlement = json['loss_making_settlement'] != null
        ? LossMakingSettlement.fromJson(Map<String, dynamic>.from(json['loss_making_settlement']))
        : null;
    specialFinancialSettlement = json['special_financial_settlement'] != null
        ? SpecialFinancialSettlement.fromJson(Map<String, dynamic>.from(json['special_financial_settlement']))
        : null;
    disputedSettlement = json['disputed_settlement'] != null
        ? DisputedSettlement.fromJson(Map<String, dynamic>.from(json['disputed_settlement']))
        : null;

    _applyHistoryDataFallbacks(json);
  }

  void _applyHistoryDataFallbacks(Map<String, dynamic> json) {
    if ((partialPayments == null || partialPayments!.isEmpty) && json['booking'] is Map) {
      final nested = Map<String, dynamic>.from(json['booking'] as Map);
      if (nested['booking_partial_payments'] != null) {
        partialPayments = <PartialPayment>[];
        nested['booking_partial_payments'].forEach((v) {
          partialPayments!.add(PartialPayment.fromJson(v));
        });
      }
    }

    if (subBooking != null) {
      customer ??= subBooking!.customer;
      provider ??= subBooking!.provider;
      if (partialPayments == null || partialPayments!.isEmpty) {
        partialPayments = subBooking!.partialPayments;
      }
    }

    if (paymentLedger == null || (paymentLedger!.installments?.isEmpty ?? true)) {
      paymentLedger = buildPaymentLedgerFallback() ?? paymentLedger;
    }

    if (transactionId != null && transactionId!.isNotEmpty) {
      paymentLedger?.installments?.forEach((entry) {
        if (entry.transactionId == null || entry.transactionId!.isEmpty) {
          entry.transactionId = transactionId;
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['readable_id'] = readableId;
    data['customer_id'] = customerId;
    data['provider_id'] = providerId;
    data['zone_id'] = zoneId;
    data['booking_status'] = bookingStatus;
    data['is_paid'] = isPaid;
    data['payment_method'] = paymentMethod;
    data['transaction_id'] = transactionId;
    data['total_booking_amount'] = totalBookingAmount;
    data['payable_grand_total'] = payableGrandTotal;
    data['list_display_total'] = listDisplayTotal;
    data['total_tax_amount'] = totalTaxAmount;
    data['total_discount_amount'] = totalDiscountAmount;
    data['service_schedule'] = serviceSchedule;
    data['service_address_id'] = serviceAddressId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['serviceman_id'] = servicemanId;
    data['booking_offline_payment_method'] = offlinePaymentMethodName;
    if (details != null) {
      data['detail'] = details!.map((v) => v.toJson()).toList();
    }
    if (scheduleHistories != null) {
      data['schedule_histories'] =
          scheduleHistories!.map((v) => v.toJson()).toList();
    }
    if (statusHistories != null) {
      data['status_histories'] =
          statusHistories!.map((v) => v.toJson()).toList();
    }
    if (serviceAddress != null) {
      data['service_address'] = serviceAddress!.toJson();
    }
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    if (provider != null) {
      data['provider'] = provider!.toJson();
    }

    if (bookingOfflinePayment != null) {
      data['booking_offline_payment'] = bookingOfflinePayment!.map((v) => v.toJson()).toList();
    }

    if (serviceman != null) {
      data['serviceman'] = provider!.toJson();
    }
    data['service_location'] = serviceLocation;
    return data;
  }
}

class ItemService {

  String? id;
  String? bookingId;
  String? serviceId;
  String? serviceName;
  String? variantKey;
  double? serviceCost;
  int? quantity;
  double? discountAmount;
  double? taxAmount;
  double? totalCost;
  String? createdAt;
  String? updatedAt;
  double? campaignDiscountAmount;
  double? overallCouponDiscountAmount;
  BookingDetailsService? service;

  ItemService.copy(ItemService value) {
    quantity = value.quantity;
  }


  ItemService(
      {
        this.id,
        this.bookingId,
        this.serviceId,
        this.serviceName,
        this.variantKey,
        this.serviceCost,
        this.quantity,
        this.discountAmount,
        this.taxAmount,
        this.totalCost,
        this.createdAt,
        this.updatedAt,
        this.service,
        this.campaignDiscountAmount,
        this.overallCouponDiscountAmount,});

  ItemService.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    bookingId = json['booking_id'];
    serviceId = json['service_id'];
    serviceName = json['service_name'];
    variantKey = json['variant_key'];
    serviceCost = double.tryParse(json['service_cost'].toString());
    quantity = int.tryParse(json['quantity'].toString());
    discountAmount = double.tryParse(json['discount_amount'].toString());
    taxAmount = double.tryParse(json['tax_amount'].toString());
    totalCost = double.tryParse(json['total_cost'].toString());
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    campaignDiscountAmount = double.tryParse(json['campaign_discount_amount'].toString());
    service =
    json['service'] != null ? BookingDetailsService.fromJson(json['service']) : null;
    overallCouponDiscountAmount = double.tryParse(json['overall_coupon_discount_amount'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['booking_id'] = bookingId;
    data['service_id'] = serviceId;
    data['service_name'] = serviceName;
    data['variant_key'] = variantKey;
    data['service_cost'] = serviceCost;
    data['quantity'] = quantity;
    data['discount_amount'] = discountAmount;
    data['tax_amount'] = taxAmount;
    data['total_cost'] = totalCost;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['campaign_discount_amount'] = campaignDiscountAmount;
    if (service != null) {
      data['service'] = service!.toJson();
    }
    return data;
  }
}

class BookingDetailsService {
  String? id;
  String? name;
  String? shortDescription;
  String? description;
  String? coverImage;
  String? thumbnail;
  String? thumbnailFullPath;
  String? categoryId;
  String? subCategoryId;
  double? tax;
  int? orderCount;
  int? isActive;
  int? ratingCount;
  String? createdAt;
  String? updatedAt;

  BookingDetailsService(
      {this.id,
      this.name,
      this.shortDescription,
      this.description,
      this.coverImage,
      this.thumbnail,
      this.thumbnailFullPath,
      this.categoryId,
      this.subCategoryId,
      this.tax,
      this.orderCount,
      this.isActive,
      this.ratingCount,
      this.createdAt,
      this.updatedAt});

  BookingDetailsService.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    shortDescription = json['short_description'];
    description = json['description'];
    coverImage = json['cover_image'];
    thumbnail = json['thumbnail'];
    thumbnailFullPath = json['thumbnail_full_path'];
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    tax = double.tryParse(json['tax'].toString());
    orderCount = json['order_count'];
    isActive = json['is_active'];
    ratingCount = json['rating_count'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['short_description'] = shortDescription;
    data['description'] = description;
    data['cover_image'] = coverImage;
    data['thumbnail'] = thumbnail;
    data['thumbnail_full_path'] = thumbnailFullPath;
    data['category_id'] = categoryId;
    data['sub_category_id'] = subCategoryId;
    data['tax'] = tax;
    data['order_count'] = orderCount;
    data['is_active'] = isActive;
    data['rating_count'] = ratingCount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}


class ScheduleHistories {
  int? id;
  String? bookingId;
  String? changedBy;
  String? schedule;
  String? createdAt;
  String? updatedAt;
  User? user;

  ScheduleHistories(
      {this.id,
        this.bookingId,
        this.changedBy,
        this.schedule,
        this.createdAt,
        this.updatedAt,
        this.user});

  ScheduleHistories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingId = json['booking_id'];
    changedBy = json['changed_by'];
    schedule = json['schedule'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['booking_id'] = bookingId;
    data['changed_by'] = changedBy;
    data['schedule'] = schedule;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}


class BookingChangeLog {
  int? id;
  String? bookingId;
  String? changedBy;
  String? actorName;
  String? propertyKey;
  String? propertyLabel;
  String? oldValue;
  String? newValue;
  String? context;
  String? createdAt;
  String? eventTitle;
  String? eventDescription;
  String? eventType;
  User? changedByUser;

  BookingChangeLog({
    this.id,
    this.bookingId,
    this.changedBy,
    this.actorName,
    this.propertyKey,
    this.propertyLabel,
    this.oldValue,
    this.newValue,
    this.context,
    this.createdAt,
    this.eventTitle,
    this.eventDescription,
    this.eventType,
    this.changedByUser,
  });

  BookingChangeLog.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingId = json['booking_id']?.toString();
    actorName = json['actor_name'];
    propertyKey = json['property_key'];
    propertyLabel = json['property_label'];
    oldValue = json['old_value']?.toString();
    newValue = json['new_value']?.toString();
    context = json['context'];
    createdAt = json['created_at'];
    eventTitle = json['event_title'];
    eventDescription = json['event_description'];
    eventType = json['event_type'];
    final changedByRaw = json['changed_by'];
    if (changedByRaw is Map<String, dynamic>) {
      changedByUser = User.fromJson(changedByRaw);
    } else {
      changedBy = changedByRaw?.toString();
    }
    if (json['changedBy'] is Map<String, dynamic>) {
      changedByUser = User.fromJson(json['changedBy']);
    }
  }

  String get actorDisplayName {
    if (changedByUser != null) {
      final name = '${changedByUser?.firstName ?? ''} ${changedByUser?.lastName ?? ''}'.trim();
      if (name.isNotEmpty) return name;
    }
    if (actorName != null && actorName!.trim().isNotEmpty) return actorName!.trim();
    return '';
  }
}

class StatusHistories {
  int? id;
  String? bookingId;
  String? changedBy;
  String? bookingStatus;
  String? createdAt;
  String? updatedAt;
  User? user;
  int? bookingHoldReopenReasonId;
  String? holdReopenReasonName;

  bool get isReopenStatusChange =>
      (bookingHoldReopenReasonId ?? 0) > 0 ||
      (holdReopenReasonName != null && holdReopenReasonName!.trim().isNotEmpty);

  StatusHistories(
      {this.id,
      this.bookingId,
      this.changedBy,
      this.bookingStatus,
      this.createdAt,
      this.updatedAt,
      this.user,
      this.bookingHoldReopenReasonId,
      this.holdReopenReasonName});

  StatusHistories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingId = json['booking_id'];
    changedBy = json['changed_by'];
    bookingStatus = json['booking_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    bookingHoldReopenReasonId = int.tryParse(json['booking_hold_reopen_reason_id']?.toString() ?? '');
    final reason = json['hold_reopen_reason'];
    if (reason is Map) {
      holdReopenReasonName = reason['name']?.toString();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['booking_id'] = bookingId;
    data['changed_by'] = changedBy;
    data['booking_status'] = bookingStatus;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class ServiceAddress {
  int? id;
  String? userId;
  double? lat;
  double? lon;
  String? city;
  String? house;
  String? floor;
  String? street;
  String? zipCode;
  String? country;
  String? address;
  String? createdAt;
  String? updatedAt;
  String? addressType;
  String? contactPersonName;
  String? contactPersonNumber;
  String? addressLabel;


  ServiceAddress({
    this.id,
    this.userId,
    this.lat,
    this.lon,
    this.city,
    this.street,
    this.zipCode,
    this.country,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.addressType,
    this.contactPersonName,
    this.contactPersonNumber,
    this.addressLabel,
    this.floor,
    this.house,
  });

  ServiceAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    lat = double.tryParse(json['lat'].toString());
    lon = double.tryParse(json['lon'].toString());
    city = json['city'];
    house = json['house'];
    floor = json['floor'];
    street = json['street'];
    zipCode = json['zip_code'];
    country = json['country'];
    address = json['address'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    addressType = json['address_type'];
    contactPersonName = json['contact_person_name'];
    contactPersonNumber = json['contact_person_number'];
    addressLabel = json['address_label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['lat'] = lat;
    data['lon'] = lon;
    data['city'] = city;
    data['house'] = house;
    data['floor'] = floor;
    data['street'] = street;
    data['zip_code'] = zipCode;
    data['country'] = country;
    data['address'] = address;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['address_type'] = addressType;
    data['contact_person_name'] = contactPersonName;
    data['contact_person_number'] = contactPersonNumber;
    data['address_label'] = addressLabel;
    return data;
  }
}

class Customer {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? identificationType;
  String? gender;
  String? profileImage;
  String? profileImageFullPath;
  int? isPhoneVerified;
  int? isEmailVerified;
  int? isActive;
  String? userType;
  double? receivedAvgRating;
  int? receivedRatingCount;
  String? createdAt;
  String? updatedAt;

  Customer(
      {this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.phone,
      this.identificationType,
      this.gender,
      this.profileImage,
      this.profileImageFullPath,
      this.isPhoneVerified,
      this.isEmailVerified,
      this.isActive,
      this.userType,
      this.receivedAvgRating,
      this.receivedRatingCount,
      this.createdAt,
      this.updatedAt});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    phone = json['phone'];
    identificationType = json['identification_type'];
    gender = json['gender'];
    profileImage = json['profile_image'];
    profileImageFullPath = json['profile_image_full_path'];
    isPhoneVerified = json['is_phone_verified'];
    isEmailVerified = json['is_email_verified'];
    isActive = json['is_active'];
    userType = json['user_type'];
    receivedAvgRating = json['received_avg_rating'] != null
        ? double.tryParse(json['received_avg_rating'].toString())
        : null;
    receivedRatingCount = json['received_rating_count'] != null
        ? int.tryParse(json['received_rating_count'].toString())
        : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['phone'] = phone;
    data['identification_type'] = identificationType;
    data['gender'] = gender;
    data['profile_image'] = profileImage;
    data['profile_image_full_path'] = profileImageFullPath;
    data['is_phone_verified'] = isPhoneVerified;
    data['is_email_verified'] = isEmailVerified;
    data['is_active'] = isActive;
    data['user_type'] = userType;
    data['received_avg_rating'] = receivedAvgRating;
    data['received_rating_count'] = receivedRatingCount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class BookingDetailsServiceman {
  String? id;
  String? providerId;
  String? userId;
  String? createdAt;
  String? updatedAt;
  ServicemanModel? user;

  BookingDetailsServiceman(
      {this.id,
        this.providerId,
        this.userId,
        this.createdAt,
        this.updatedAt,
        this.user});

  BookingDetailsServiceman.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    providerId = json['provider_id'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? ServicemanModel.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['provider_id'] = providerId;
    data['user_id'] = userId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}



class PaymentDetailsSummary {
  double? total;
  double? amountPaidDisplay;
  double? dueBalance;
  String? statusLabel;
  String? amountRowLabel;
  bool? showAsAmountPaidLabel;
  String? paymentMethodDisplay;
  String? offlineVerifyStatus;
  double? scaledBadDebtBalanceNotDue;
  double? scaledLossCompanyShare;
  double? scaledLossProviderShare;
  double? scaledLossWriteoffAmount;
  bool? isWriteoffSettled;
  bool? canComplete;
  bool? canRecordPayment;
  bool? isDisputedSettlement;
  double? customerPaidTotal;
  double? refundedAmount;
  double? refundTotal;
  double? finalBookingAmount;
  double? retainedAmount;
  double? refundableAmount;
  double? refundableRemaining;
  double? pendingRefund;

  PaymentDetailsSummary({
    this.total,
    this.amountPaidDisplay,
    this.dueBalance,
    this.statusLabel,
    this.amountRowLabel,
    this.showAsAmountPaidLabel,
    this.paymentMethodDisplay,
    this.offlineVerifyStatus,
    this.scaledBadDebtBalanceNotDue,
    this.scaledLossCompanyShare,
    this.scaledLossProviderShare,
    this.scaledLossWriteoffAmount,
    this.isWriteoffSettled,
    this.canComplete,
    this.canRecordPayment,
    this.isDisputedSettlement,
    this.customerPaidTotal,
    this.refundedAmount,
    this.refundTotal,
    this.finalBookingAmount,
    this.retainedAmount,
    this.refundableAmount,
    this.refundableRemaining,
    this.pendingRefund,
  });

  PaymentDetailsSummary.fromJson(Map<String, dynamic> json) {
    total = double.tryParse(json['total']?.toString() ?? '');
    amountPaidDisplay = double.tryParse(json['amount_paid_display']?.toString() ?? '');
    dueBalance = double.tryParse(json['due_balance']?.toString() ?? '');
    statusLabel = json['status_label'];
    amountRowLabel = json['amount_row_label'];
    showAsAmountPaidLabel = json['show_as_amount_paid_label'] == true;
    paymentMethodDisplay = json['payment_method_display'];
    offlineVerifyStatus = json['offline_verify_status'];
    scaledBadDebtBalanceNotDue = double.tryParse(json['scaled_bad_debt_balance_not_due']?.toString() ?? '');
    scaledLossCompanyShare = double.tryParse(json['scaled_loss_company_share']?.toString() ?? '');
    scaledLossProviderShare = double.tryParse(json['scaled_loss_provider_share']?.toString() ?? '');
    scaledLossWriteoffAmount = double.tryParse(json['scaled_loss_writeoff_amount']?.toString() ?? '');
    isWriteoffSettled = json['is_writeoff_settled'] == true;
    canComplete = _parseNullableBool(json['can_complete']);
    canRecordPayment = _parseNullableBool(json['can_record_payment']);
    isDisputedSettlement = json['is_disputed_settlement'] == true;
    customerPaidTotal = double.tryParse(json['customer_paid_total']?.toString() ?? '');
    refundedAmount = double.tryParse(json['refunded_amount']?.toString() ?? '');
    refundTotal = double.tryParse(json['refund_total']?.toString() ?? '');
    finalBookingAmount = double.tryParse(json['final_booking_amount']?.toString() ?? '');
    retainedAmount = double.tryParse(json['retained_amount']?.toString() ?? '');
    refundableAmount = double.tryParse(json['refundable_amount']?.toString() ?? '');
    refundableRemaining = double.tryParse(json['refundable_remaining']?.toString() ?? '');
    pendingRefund = double.tryParse(json['pending_refund']?.toString() ?? '');
  }

  static bool? _parseNullableBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == '1' || normalized == 'true') return true;
      if (normalized == '0' || normalized == 'false') return false;
    }
    return null;
  }
}

class BookingPaymentLedger {
  List<BookingPaymentLedgerEntry>? installments;
  List<BookingRefundLedgerEntry>? refunds;

  BookingPaymentLedger({this.installments, this.refunds});

  BookingPaymentLedger.fromJson(Map<String, dynamic> json) {
    if (json['installments'] != null) {
      installments = <BookingPaymentLedgerEntry>[];
      json['installments'].forEach((v) {
        installments!.add(BookingPaymentLedgerEntry.fromJson(v));
      });
    }
    if (json['refunds'] != null) {
      refunds = <BookingRefundLedgerEntry>[];
      json['refunds'].forEach((v) {
        refunds!.add(BookingRefundLedgerEntry.fromJson(v));
      });
    }
  }
}

class BookingPaymentLedgerEntry {
  int? serial;
  String? date;
  String? receivedByLabel;
  double? amount;
  String? paymentMethodLabel;
  String? transactionId;
  double? dueAfterPayment;

  BookingPaymentLedgerEntry({
    this.serial,
    this.date,
    this.receivedByLabel,
    this.amount,
    this.paymentMethodLabel,
    this.transactionId,
    this.dueAfterPayment,
  });

  BookingPaymentLedgerEntry.fromJson(Map<String, dynamic> json) {
    serial = int.tryParse(json['serial']?.toString() ?? '');
    date = json['date'];
    receivedByLabel = json['received_by_label'];
    amount = double.tryParse(json['amount']?.toString() ?? '');
    paymentMethodLabel = json['payment_method_label'];
    transactionId = json['transaction_id'];
    dueAfterPayment = double.tryParse(json['due_after_payment']?.toString() ?? '');
  }
}

class BookingRefundLedgerEntry {
  int? serial;
  String? date;
  double? amount;
  String? transactionId;
  String? referenceNote;

  BookingRefundLedgerEntry({
    this.serial,
    this.date,
    this.amount,
    this.transactionId,
    this.referenceNote,
  });

  BookingRefundLedgerEntry.fromJson(Map<String, dynamic> json) {
    serial = int.tryParse(json['serial']?.toString() ?? '');
    date = json['date'];
    amount = double.tryParse(json['amount']?.toString() ?? '');
    transactionId = json['transaction_id'];
    referenceNote = json['reference_note'];
  }
}

extension BookingDetailsContentPaymentLedger on BookingDetailsContent {
  BookingPaymentLedger? buildPaymentLedgerFallback() {
    if (partialPayments == null || partialPayments!.isEmpty) {
      return null;
    }

    final cap = paymentDetails?.total ??
        payableGrandTotal ??
        bookingSummary?.grandTotal ??
        totalBookingAmount ??
        0;
    var runningPaid = 0.0;
    final installments = <BookingPaymentLedgerEntry>[];

    for (final partial in partialPayments!) {
      final amount = partial.paidAmount ?? 0;
      if (amount == 0) {
        continue;
      }
      runningPaid += amount;
      installments.add(BookingPaymentLedgerEntry(
        serial: installments.length + 1,
        date: partial.createdAt,
        receivedByLabel: partial.receivedByLabel ?? partial.receivedBy,
        amount: amount,
        paymentMethodLabel: partial.paymentMethodLabel ?? partial.paidWith,
        transactionId: (partial.transactionId != null && partial.transactionId!.isNotEmpty)
            ? partial.transactionId
            : transactionId,
        dueAfterPayment: partial.dueAfterPayment ??
            (cap - runningPaid).clamp(0, double.infinity).toDouble(),
      ));
    }

    if (installments.isEmpty) {
      return null;
    }

    return BookingPaymentLedger(installments: installments, refunds: []);
  }
}

class RevenueSettlement {
  bool? showBreakdown;
  double? companyShare;
  double? providerShare;
  double? amountReceivedByCompany;
  double? amountReceivedByProvider;
  double? totalPaid;
  double? payToProvider;
  double? providerOwesCompany;
  bool? netRevenueZeroedAfterRefund;
  String? settlementMessageKey;
  double? scaledLossWriteoffAmount;
  double? scaledLossWriteoffCompanyAmount;
  double? scaledLossWriteoffProviderAmount;

  RevenueSettlement({
    this.showBreakdown,
    this.companyShare,
    this.providerShare,
    this.amountReceivedByCompany,
    this.amountReceivedByProvider,
    this.totalPaid,
    this.payToProvider,
    this.providerOwesCompany,
    this.netRevenueZeroedAfterRefund,
    this.settlementMessageKey,
    this.scaledLossWriteoffAmount,
    this.scaledLossWriteoffCompanyAmount,
    this.scaledLossWriteoffProviderAmount,
  });

  RevenueSettlement.fromJson(Map<String, dynamic> json) {
    showBreakdown = json['show_breakdown'] == true;
    companyShare = double.tryParse(json['company_share']?.toString() ?? '');
    providerShare = double.tryParse(json['provider_share']?.toString() ?? '');
    amountReceivedByCompany = double.tryParse(json['amount_received_by_company']?.toString() ?? '');
    amountReceivedByProvider = double.tryParse(json['amount_received_by_provider']?.toString() ?? '');
    totalPaid = double.tryParse(json['total_paid']?.toString() ?? '');
    payToProvider = double.tryParse(json['pay_to_provider']?.toString() ?? '');
    providerOwesCompany = double.tryParse(json['provider_owes_company']?.toString() ?? '');
    netRevenueZeroedAfterRefund = json['net_revenue_zeroed_after_refund'] == true;
    settlementMessageKey = json['settlement_message_key'];
    scaledLossWriteoffAmount = double.tryParse(json['scaled_loss_writeoff_amount']?.toString() ?? '');
    scaledLossWriteoffCompanyAmount = double.tryParse(json['scaled_loss_writeoff_company_amount']?.toString() ?? '');
    scaledLossWriteoffProviderAmount = double.tryParse(json['scaled_loss_writeoff_provider_amount']?.toString() ?? '');
  }
}

class ServiceLocationDetails {
  String? zoneName;
  String? serviceLocation;
  String? address;
  bool? addressPending;
  String? travelNote;

  ServiceLocationDetails({
    this.zoneName,
    this.serviceLocation,
    this.address,
    this.addressPending,
    this.travelNote,
  });

  ServiceLocationDetails.fromJson(Map<String, dynamic> json) {
    zoneName = json['zone_name'];
    serviceLocation = json['service_location'];
    address = json['address'];
    addressPending = json['address_pending'] == true;
    travelNote = json['travel_note'];
  }
}

class PartialPayment {
  String? id;
  String? bookingId;
  String? paidWith;
  double? paidAmount;
  double? dueAmount;
  String? createdAt;
  String? updatedAt;
  String? receivedBy;
  String? receivedByLabel;
  String? paymentMethodLabel;
  String? transactionId;
  double? dueAfterPayment;

  PartialPayment(
      {this.id,
        this.bookingId,
        this.paidWith,
        this.paidAmount,
        this.dueAmount,
        this.createdAt,
        this.updatedAt,
        this.receivedBy,
        this.receivedByLabel,
        this.paymentMethodLabel,
        this.transactionId,
        this.dueAfterPayment});

  PartialPayment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingId = json['booking_id'];
    paidWith = json['paid_with'];
    paidAmount = double.tryParse(json['paid_amount'].toString());
    dueAmount = double.tryParse(json['due_amount'].toString());
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    receivedBy = json['received_by'];
    receivedByLabel = json['received_by_label'];
    paymentMethodLabel = json['payment_method_label'];
    transactionId = json['transaction_id'];
    dueAfterPayment = double.tryParse(json['due_after_payment']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['booking_id'] = bookingId;
    data['paid_with'] = paidWith;
    data['paid_amount'] = paidAmount;
    data['due_amount'] = dueAmount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}


class BookingOfflinePayment {
  String? key;
  String? value;

  BookingOfflinePayment({String? key, String? value}) {
    if (key != null) {
      key = key;
    }
    if (value != null) {
      value = value;
    }
  }


  BookingOfflinePayment.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['value'] = value;
    return data;
  }
}


class RepeatBooking {
  String? id;
  String? readableId;
  String? customerId;
  String? providerId;
  String? zoneId;
  String? bookingStatus;
  int? isPaid;
  String? paymentMethod;
  String? transactionId;
  double? totalBookingAmount;
  double? totalTaxAmount;
  double? totalDiscountAmount;
  String? serviceSchedule;
  String? serviceAddressId;
  String? createdAt;
  String? updatedAt;
  String? servicemanId;
  String? categoryId;
  String? subcategoryId;
  List<ItemService>? details;
  List<ScheduleHistories>? scheduleHistories;
  List<StatusHistories>? statusHistories;
  List<PartialPayment>? partialPayments;
  ServiceAddress? serviceAddress;
  BookingDetailsServiceman? serviceman;
  String ? totalCampaignDiscountAmount;
  String ? totalCouponDiscountAmount;
  double ? additionalCharge;
  List<String>? photoEvidence;
  List<String>? photoEvidenceFullPath;
  double? extraFee;
  int? isGuest;
  double ? totalReferralDiscountAmount;
  String? serviceLocation;

  RepeatBooking({
    this.id,
    this.readableId,
    this.customerId,
    this.providerId,
    this.zoneId,
    this.bookingStatus,
    this.isPaid,
    this.paymentMethod,
    this.transactionId,
    this.totalBookingAmount,
    this.totalTaxAmount,
    this.totalDiscountAmount,
    this.serviceSchedule,
    this.serviceAddressId,
    this.createdAt,
    this.updatedAt,
    this.servicemanId,
    this.details,
    this.scheduleHistories,
    this.statusHistories,
    this.partialPayments,
    this.serviceAddress,
    this.serviceman,
    this.totalCampaignDiscountAmount,
    this.totalCouponDiscountAmount,
    this.additionalCharge,
    this.photoEvidence,
    this.photoEvidenceFullPath,
    this.extraFee,
    this.isGuest,
    this.totalReferralDiscountAmount,
    this.categoryId,
    this.subcategoryId,
    this.serviceLocation
  });

  RepeatBooking.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    readableId = json['readable_id'].toString();
    customerId = json['customer_id'];
    providerId = json['provider_id'];
    zoneId = json['zone_id'];
    bookingStatus = json['booking_status'];
    isPaid = json['is_paid'];
    paymentMethod = json['payment_method'];
    transactionId = json['transaction_id'];
    totalBookingAmount = double.tryParse(json['total_booking_amount'].toString());
    totalTaxAmount = double.tryParse(json['total_tax_amount'].toString());
    totalDiscountAmount = double.tryParse(json['total_discount_amount'].toString());
    serviceSchedule = json['service_schedule'];
    serviceAddressId = json['service_address_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    servicemanId = json['serviceman_id'];
    categoryId = json['category_id'];
    subcategoryId = json['sub_category_id'];
    if (json['detail'] != null) {
      details = <ItemService>[];
      json['detail'].forEach((v) {
        details!.add(ItemService.fromJson(v));
      });
    }
    if (json['schedule_histories'] != null || json['scheduleHistories'] != null) {
      scheduleHistories = <ScheduleHistories>[];
      (json['schedule_histories'] ?? json['scheduleHistories']).forEach((v) {
        scheduleHistories!.add(ScheduleHistories.fromJson(v));
      });
    }
    if (json['status_histories'] != null || json['statusHistories'] != null) {
      statusHistories = <StatusHistories>[];
      (json['status_histories'] ?? json['statusHistories']).forEach((v) {

        statusHistories!.add(StatusHistories.fromJson(v));
      });
    }

    if (json['booking_partial_payments'] != null) {
      partialPayments = <PartialPayment>[];
      json['booking_partial_payments'].forEach((v) {
        partialPayments!.add(PartialPayment.fromJson(v));
      });
    }

    serviceAddress = json['service_address'] != null
        ? ServiceAddress.fromJson(json['service_address'])
        : null;
    serviceman = json['serviceman'] != null
        ? BookingDetailsServiceman.fromJson(json['serviceman'])
        : null;
    totalCampaignDiscountAmount = json['total_campaign_discount_amount'].toString();
    totalCouponDiscountAmount =json['total_coupon_discount_amount'].toString();
    additionalCharge = double.tryParse(json['additional_charge'].toString());
    totalReferralDiscountAmount = double.tryParse(json['total_referral_discount_amount'].toString());
    photoEvidence = json["evidence_photos"]!=null? json["evidence_photos"].cast<String>(): [];
    photoEvidenceFullPath = json["evidence_photos_full_path"]!=null? json["evidence_photos_full_path"].cast<String>(): [];
    extraFee = double.tryParse(json["extra_fee"].toString());
    isGuest = int.tryParse(json["is_guest"].toString());
    serviceLocation = json['service_location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['readable_id'] = readableId;
    data['customer_id'] = customerId;
    data['provider_id'] = providerId;
    data['zone_id'] = zoneId;
    data['booking_status'] = bookingStatus;
    data['is_paid'] = isPaid;
    data['payment_method'] = paymentMethod;
    data['transaction_id'] = transactionId;
    data['total_booking_amount'] = totalBookingAmount;
    data['total_tax_amount'] = totalTaxAmount;
    data['total_discount_amount'] = totalDiscountAmount;
    data['service_schedule'] = serviceSchedule;
    data['service_address_id'] = serviceAddressId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['serviceman_id'] = servicemanId;
    if (details != null) {
      data['detail'] = details!.map((v) => v.toJson()).toList();
    }
    if (scheduleHistories != null) {
      data['schedule_histories'] =
          scheduleHistories!.map((v) => v.toJson()).toList();
    }
    if (statusHistories != null) {
      data['status_histories'] =
          statusHistories!.map((v) => v.toJson()).toList();
    }
    if (serviceAddress != null) {
      data['service_address'] = serviceAddress!.toJson();
    }
    return data;
  }
}

class RepeatHistory {
  int? id;
  String? bookingId;
  String? bookingRepeatId;
  String? bookingRepeatDetailsId;
  String? readableId;
  int? oldQuantity;
  int? newQuantity;
  int? isMultiple;
  double? totalBookingAmount;
  double? totalTaxAmount;
  double? totalDiscountAmount;
  double? extraFee;
  String? createdAt;
  String? updatedAt;
  List<RepeatHistoryLog>? repeatHistoryLogs;

  RepeatHistory({this.id,
    this.bookingId,
    this.bookingRepeatId,
    this.bookingRepeatDetailsId,
    this.readableId,
    this.oldQuantity,
    this.newQuantity,
    this.isMultiple,
    this.createdAt,
    this.updatedAt,
    this.repeatHistoryLogs,
    this.totalBookingAmount,
    this.totalDiscountAmount,
    this.totalTaxAmount,
    this.extraFee
  });

  RepeatHistory.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id'].toString());
    bookingId = json['booking_id'];
    bookingRepeatId = json['booking_repeat_id'];
    bookingRepeatDetailsId = json['booking_repeat_details_id'];
    readableId = json['readable_id'];
    oldQuantity = int.tryParse(json['old_quantity'].toString());
    newQuantity = int.tryParse(json['new_quantity'].toString());
    isMultiple = int.tryParse(json['is_multiple'].toString());
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    totalBookingAmount = double.tryParse(json['total_booking_amount'].toString());
    totalTaxAmount = double.tryParse(json['total_tax_amount'].toString());
    totalDiscountAmount = double.tryParse(json['total_discount_amount'].toString());
    extraFee = double.tryParse(json['extra_fee'].toString());
    if (json['log_details'] != null) {
      repeatHistoryLogs = <RepeatHistoryLog>[];
      json['log_details'].forEach((v) {
        repeatHistoryLogs!.add(RepeatHistoryLog.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['booking_id'] = bookingId;
    data['booking_repeat_id'] = bookingRepeatId;
    data['booking_repeat_details_id'] = bookingRepeatDetailsId;
    data['readable_id'] = readableId;
    data['old_quantity'] = oldQuantity;
    data['new_quantity'] = newQuantity;
    data['is_multiple'] = isMultiple;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class RepeatHistoryLog {
  String? serviceId;
  int? quantity;
  String? variantKey;
  String? serviceName;
  double? serviceCost;
  double? discountAmount;
  double? taxAmount;
  double? totalCost;
  String? repeatDetailsId;

  RepeatHistoryLog(
      {this.serviceId,
        this.quantity,
        this.variantKey,
        this.serviceName,
        this.serviceCost,
        this.discountAmount,
        this.taxAmount,
        this.totalCost,
        this.repeatDetailsId});

  RepeatHistoryLog.fromJson(Map<String, dynamic> json) {
    serviceId = json['service_id'];
    quantity = json['quantity'];
    variantKey = json['variant_key'].toString();
    serviceName = json['service_name'];
    serviceCost = double.tryParse(json['service_cost'].toString());
    discountAmount = double.tryParse(json['discount_amount'].toString());
    taxAmount = double.tryParse(json['tax_amount'].toString());
    totalCost = double.tryParse(json['total_cost'].toString());
    repeatDetailsId = json['repeat_details_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['service_id'] = serviceId;
    data['quantity'] = quantity;
    data['variant_key'] = variantKey;
    data['service_name'] = serviceName;
    data['service_cost'] = serviceCost;
    data['discount_amount'] = discountAmount;
    data['tax_amount'] = taxAmount;
    data['total_cost'] = totalCost;
    data['repeat_details_id'] = repeatDetailsId;
    return data;
  }
}

class ProviderExtraServiceLine {
  String? id;
  String? name;
  double? amount;
  String? type;
  String? details;
  double? price;
  int? quantity;
  double? discount;
  double? total;

  ProviderExtraServiceLine({
    this.id,
    this.name,
    this.amount,
    this.type,
    this.details,
    this.price,
    this.quantity,
    this.discount,
    this.total,
  });

  ProviderExtraServiceLine.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    amount = double.tryParse(json['amount']?.toString() ?? '');
    type = json['type']?.toString();
    details = json['details']?.toString();
    price = double.tryParse(json['price']?.toString() ?? '');
    quantity = int.tryParse(json['quantity']?.toString() ?? '');
    discount = double.tryParse(json['discount']?.toString() ?? '');
    total = double.tryParse(json['total']?.toString() ?? '');
  }

  bool get isSparePart => type == 'spare_part';
}

class ProviderBookingSummaryLine {
  String? name;
  double? amount;

  ProviderBookingSummaryLine({this.name, this.amount});

  ProviderBookingSummaryLine.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    amount = double.tryParse(json['amount']?.toString() ?? '');
  }
}

class ProviderBookingSummary {
  double? serviceAmount;
  List<ProviderBookingSummaryLine>? extraServiceLines;
  List<ProviderBookingSummaryLine>? sparePartLines;
  List<ProviderBookingSummaryLine>? additionalChargeLines;
  double? grossTotal;
  double? serviceDiscount;
  double? couponDiscount;
  double? campaignDiscount;
  double? referralDiscount;
  double? tax;
  bool? hasTax;
  double? grandTotal;
  double? totalPaid;
  double? dueAmount;

  ProviderBookingSummary({
    this.serviceAmount,
    this.extraServiceLines,
    this.sparePartLines,
    this.additionalChargeLines,
    this.grossTotal,
    this.serviceDiscount,
    this.couponDiscount,
    this.campaignDiscount,
    this.referralDiscount,
    this.tax,
    this.hasTax,
    this.grandTotal,
    this.totalPaid,
    this.dueAmount,
  });

  ProviderBookingSummary.fromJson(Map<String, dynamic> json) {
    serviceAmount = double.tryParse(json['service_amount']?.toString() ?? '');
    grossTotal = double.tryParse(json['gross_total']?.toString() ?? '');
    serviceDiscount = double.tryParse(json['service_discount']?.toString() ?? '');
    couponDiscount = double.tryParse(json['coupon_discount']?.toString() ?? '');
    campaignDiscount = double.tryParse(json['campaign_discount']?.toString() ?? '');
    referralDiscount = double.tryParse(json['referral_discount']?.toString() ?? '');
    tax = double.tryParse(json['tax']?.toString() ?? '');
    hasTax = json['has_tax'] == true;
    grandTotal = double.tryParse(json['grand_total']?.toString() ?? '');
    totalPaid = double.tryParse(json['total_paid']?.toString() ?? '');
    dueAmount = double.tryParse(json['due_amount']?.toString() ?? '');

    if (json['extra_service_lines'] is List) {
      extraServiceLines = (json['extra_service_lines'] as List)
          .map((v) => ProviderBookingSummaryLine.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }
    if (json['spare_part_lines'] is List) {
      sparePartLines = (json['spare_part_lines'] as List)
          .map((v) => ProviderBookingSummaryLine.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }
    if (json['additional_charge_lines'] is List) {
      additionalChargeLines = (json['additional_charge_lines'] as List)
          .map((v) => ProviderBookingSummaryLine.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }
  }
}

class BookingCategoryInfo {
  String? id;
  String? name;

  BookingCategoryInfo({this.id, this.name});

  BookingCategoryInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class SpecialFinancialSettlement {
  bool? hasSpecialSettlement;
  String? settlementOutcome;
  String? scenarioLabelKey;
  double? finalBookingAmount;
  double? finalServiceCharges;
  double? finalSparePartsCharges;
  double? finalAdminCommission;
  double? finalProviderEarning;
  String? notes;

  SpecialFinancialSettlement({
    this.hasSpecialSettlement,
    this.settlementOutcome,
    this.scenarioLabelKey,
    this.finalBookingAmount,
    this.finalServiceCharges,
    this.finalSparePartsCharges,
    this.finalAdminCommission,
    this.finalProviderEarning,
    this.notes,
  });

  SpecialFinancialSettlement.fromJson(Map<String, dynamic> json) {
    hasSpecialSettlement = json['has_special_settlement'] == true;
    settlementOutcome = json['settlement_outcome']?.toString();
    scenarioLabelKey = json['scenario_label_key']?.toString();
    finalBookingAmount = double.tryParse(json['final_booking_amount']?.toString() ?? '');
    finalServiceCharges = double.tryParse(json['final_service_charges']?.toString() ?? '');
    finalSparePartsCharges = double.tryParse(json['final_spare_parts_charges']?.toString() ?? '');
    finalAdminCommission = double.tryParse(json['final_admin_commission']?.toString() ?? '');
    finalProviderEarning = double.tryParse(json['final_provider_earning']?.toString() ?? '');
    notes = json['notes']?.toString();
  }
}

class DisputedSettlement {
  bool? hasDisputedSettlement;
  double? customerPaidTotal;
  double? refundTotal;
  double? refundCompanyAmount;
  double? refundProviderAmount;
  double? finalBookingAmount;
  double? retainedFromCustomer;
  double? finalAdminCommission;
  double? finalProviderEarning;
  double? providerOwesCompany;
  double? companyOwesProvider;
  double? pendingRefund;
  bool? isFullRefund;
  bool? isPartialRefund;

  DisputedSettlement({
    this.hasDisputedSettlement,
    this.customerPaidTotal,
    this.refundTotal,
    this.refundCompanyAmount,
    this.refundProviderAmount,
    this.finalBookingAmount,
    this.retainedFromCustomer,
    this.finalAdminCommission,
    this.finalProviderEarning,
    this.providerOwesCompany,
    this.companyOwesProvider,
    this.pendingRefund,
    this.isFullRefund,
    this.isPartialRefund,
  });

  DisputedSettlement.fromJson(Map<String, dynamic> json) {
    hasDisputedSettlement = json['has_disputed_settlement'] == true;
    customerPaidTotal = double.tryParse(json['customer_paid_total']?.toString() ?? '');
    refundTotal = double.tryParse(json['refund_total']?.toString() ?? '');
    refundCompanyAmount = double.tryParse(json['refund_company_amount']?.toString() ?? '');
    refundProviderAmount = double.tryParse(json['refund_provider_amount']?.toString() ?? '');
    finalBookingAmount = double.tryParse(json['final_booking_amount']?.toString() ?? '');
    retainedFromCustomer = double.tryParse(json['retained_from_customer']?.toString() ?? '');
    finalAdminCommission = double.tryParse(json['final_admin_commission']?.toString() ?? '');
    finalProviderEarning = double.tryParse(json['final_provider_earning']?.toString() ?? '');
    providerOwesCompany = double.tryParse(json['provider_owes_company']?.toString() ?? '');
    companyOwesProvider = double.tryParse(json['company_owes_provider']?.toString() ?? '');
    pendingRefund = double.tryParse(json['pending_refund']?.toString() ?? '');
    isFullRefund = json['is_full_refund'] == true;
    isPartialRefund = json['is_partial_refund'] == true;
  }
}

class LossMakingSettlement {
  bool? isLossMaking;
  double? totalBookingAmount;
  double? amountPaid;
  double? pendingBalance;
  double? amountPaidByCustomer;
  double? lossAmount;
  double? lossToCompany;
  double? lossToProvider;
  double? companyCommissionFullBooking;
  double? providerShareBeforeLossFullBooking;
  double? netCompanyShareAfterLoss;
  double? netProviderShareAfterLoss;
  String? notes;

  LossMakingSettlement({
    this.isLossMaking,
    this.totalBookingAmount,
    this.amountPaid,
    this.pendingBalance,
    this.amountPaidByCustomer,
    this.lossAmount,
    this.lossToCompany,
    this.lossToProvider,
    this.companyCommissionFullBooking,
    this.providerShareBeforeLossFullBooking,
    this.netCompanyShareAfterLoss,
    this.netProviderShareAfterLoss,
    this.notes,
  });

  LossMakingSettlement.fromJson(Map<String, dynamic> json) {
    isLossMaking = json['is_loss_making'] == true;
    totalBookingAmount = double.tryParse(json['total_booking_amount']?.toString() ?? '');
    amountPaid = double.tryParse(json['amount_paid']?.toString() ?? '');
    pendingBalance = double.tryParse(json['pending_balance']?.toString() ?? '');
    amountPaidByCustomer = double.tryParse(json['amount_paid_by_customer']?.toString() ?? '');
    lossAmount = double.tryParse(json['loss_amount']?.toString() ?? '');
    lossToCompany = double.tryParse(json['loss_to_company']?.toString() ?? '');
    lossToProvider = double.tryParse(json['loss_to_provider']?.toString() ?? '');
    companyCommissionFullBooking = double.tryParse(json['company_commission_full_booking']?.toString() ?? '');
    providerShareBeforeLossFullBooking = double.tryParse(json['provider_share_before_loss_full_booking']?.toString() ?? '');
    netCompanyShareAfterLoss = double.tryParse(json['net_company_share_after_loss']?.toString() ?? '');
    netProviderShareAfterLoss = double.tryParse(json['net_provider_share_after_loss']?.toString() ?? '');
    notes = json['notes'];
  }
}
