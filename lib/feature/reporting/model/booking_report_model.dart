
import 'dart:core';
import 'package:demandium_provider/common/model/booking_status_ui_model.dart';
import 'package:demandium_provider/feature/booking_details/model/bookings_details_model.dart';

class BookingReportModel {
  BookingReportContent? content;
  BookingReportModel({this.content});

  BookingReportModel.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'];
    if (rawContent is Map<String, dynamic>) {
      try {
        content = BookingReportContent.fromJson(rawContent);
      } catch (_) {
        content = null;
      }
    } else if (rawContent is Map) {
      try {
        content = BookingReportContent.fromJson(Map<String, dynamic>.from(rawContent));
      } catch (_) {
        content = null;
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (content != null) {
      data['content'] = content!.toJson();
    }
    return data;
  }
}

class BookingReportContent {
  List<ZonesList>? zones;
  List<Categories>? categories;
  List<SubCategories>? subCategories;
  BookingsCount? bookingsCount;
  BookingAmount? bookingAmount;
  FilterData? filterData;
  BookingReportChartData? chartData;

  BookingReportContent(
      {this.zones,
        this.categories,
        this.subCategories,
        this.bookingsCount,
        this.bookingAmount,
        this.chartData,
        this.filterData
      });

  BookingReportContent.fromJson(Map<String, dynamic> json) {
    try {
      if (json['zones'] != null) {
        zones = <ZonesList>[];
        for (final v in json['zones']) {
          if (v is Map) {
            zones!.add(ZonesList.fromJson(Map<String, dynamic>.from(v)));
          }
        }
      }
      if (json['categories'] != null) {
        categories = <Categories>[];
        for (final v in json['categories']) {
          if (v is Map) {
            categories!.add(Categories.fromJson(Map<String, dynamic>.from(v)));
          }
        }
      }
      if (json['sub_categories'] != null) {
        subCategories = <SubCategories>[];
        for (final v in json['sub_categories']) {
          if (v is Map) {
            subCategories!.add(SubCategories.fromJson(Map<String, dynamic>.from(v)));
          }
        }
      }
      bookingsCount = json['bookings_count'] is Map
          ? BookingsCount.fromJson(Map<String, dynamic>.from(json['bookings_count']))
          : null;
      bookingAmount = json['booking_amount'] is Map
          ? BookingAmount.fromJson(Map<String, dynamic>.from(json['booking_amount']))
          : null;
      chartData = json['chart_data'] is Map
          ? BookingReportChartData.fromJson(Map<String, dynamic>.from(json['chart_data']))
          : null;
      filterData = json['filtered_bookings'] is Map
          ? FilterData.fromJson(Map<String, dynamic>.from(json['filtered_bookings']))
          : null;
    } catch (_) {
      zones = null;
      categories = null;
      subCategories = null;
      bookingsCount = null;
      bookingAmount = null;
      chartData = null;
      filterData = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (zones != null) {
      data['zones'] = zones!.map((v) => v.toJson()).toList();
    }
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    if (subCategories != null) {
      data['sub_categories'] =
          subCategories!.map((v) => v.toJson()).toList();
    }
    if (bookingsCount != null) {
      data['bookings_count'] = bookingsCount!.toJson();
    }
    if (bookingAmount != null) {
      data['booking_amount'] = bookingAmount!.toJson();
    }

    if (chartData != null) {
      data['chart_data'] = chartData!.toJson();
    }
    if (filterData != null) {
      data['filtered_bookings'] = filterData!.toJson();
    }
    return data;
  }
}

class ZonesList {
  String? id;
  String? name;

  ZonesList({this.id, this.name});

  ZonesList.fromJson(Map<String, dynamic> json) {
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

class SubCategories {
  String? id;
  String? parentId;
  String? name;

  SubCategories({this.id, this.parentId, this.name});

  SubCategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parent_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['parent_id'] = parentId;
    data['name'] = name;
    return data;
  }
}

class BookingsCount {
  int? totalBookings;
  int? accepted;
  int? ongoing;
  int? onHold;
  int? completed;
  int? canceled;
  int? refunded;

  BookingsCount(
      {this.totalBookings,
        this.ongoing,
        this.onHold,
        this.completed,
        this.canceled,
        this.accepted,
        this.refunded});

  BookingsCount.fromJson(Map<String, dynamic> json) {
    totalBookings = json['total_bookings'];
    ongoing = json['ongoing'];
    onHold = json['on_hold'];
    accepted = json['accepted'];
    completed = json['completed'];
    canceled = json['canceled'];
    refunded = json['refunded'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_bookings'] = totalBookings;
    data['ongoing'] = ongoing;
    data['on_hold'] = onHold;
    data['accepted'] = accepted;
    data['completed'] = completed;
    data['canceled'] = canceled;
    data['refunded'] = refunded;
    return data;
  }
}

class Categories {
  String? id;
  String? name;

  Categories({this.id, this.name});

  Categories.fromJson(Map<String, dynamic> json) {
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

class BookingAmount {
  double? totalBookingAmount;
  double? totalPaidBookingAmount;
  double? totalUnpaidBookingAmount;

  BookingAmount(
      {this.totalBookingAmount,
        this.totalPaidBookingAmount,
        this.totalUnpaidBookingAmount});

  BookingAmount.fromJson(Map<String, dynamic> json) {
    totalBookingAmount = double.tryParse(json['total_booking_amount'].toString());
    totalPaidBookingAmount = double.tryParse(json['total_paid_booking_amount'].toString());
    totalUnpaidBookingAmount = double.tryParse(json['total_unpaid_booking_amount'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_booking_amount'] = totalBookingAmount;
    data['total_paid_booking_amount'] = totalPaidBookingAmount;
    data['total_unpaid_booking_amount'] = totalUnpaidBookingAmount;
    return data;
  }
}

class BookingReportChartData {
  List<double>? bookingAmount;
  List<double>? taxAmount;
  List<double>? adminCommission;
  List<int>? timeline;

  BookingReportChartData(
      {this.bookingAmount,
        this.taxAmount,
        this.adminCommission,
        this.timeline});

  BookingReportChartData.fromJson(Map<String, dynamic> json) {
    if (json['booking_amount'] != null) {
      bookingAmount = [];
      json['booking_amount'].forEach((v){
        bookingAmount?.add(double.tryParse(v.toString()) ?? 0);
      });
    }
    if (json['tax_amount'] != null) {
      taxAmount = [];
      json['tax_amount'].forEach((v){
        taxAmount?.add(double.tryParse(v.toString()) ?? 0);
      });
    }
    if (json['admin_commission'] != null) {
      adminCommission = [];
      json['admin_commission'].forEach((v){
        adminCommission?.add(double.tryParse(v.toString()) ?? 0);
      });
    }
    if (json['timeline'] != null) {
      timeline = (json['timeline'] as List)
          .map((v) => int.tryParse(v.toString()) ?? 0)
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_amount'] = bookingAmount;
    data['tax_amount'] = taxAmount;
    data['admin_commission'] = adminCommission;
    data['timeline'] = timeline;
    return data;
  }
}

class FilterData {
  List<BookingFilterData>? data;
  int? lastPage;
  int? total;

  FilterData({this.data, this.lastPage, this.total});

  FilterData.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <BookingFilterData>[];
      for (final v in json['data']) {
        if (v is! Map) continue;
        try {
          data!.add(BookingFilterData.fromJson(Map<String, dynamic>.from(v)));
        } catch (_) {
          // Skip malformed booking rows instead of failing the whole report.
        }
      }
    }
    lastPage = int.tryParse(json['last_page']?.toString() ?? '') ?? 1;
    total = int.tryParse(json['total']?.toString() ?? '') ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['last_page'] = lastPage;
    data['total'] = total;
    return data;
  }
}

class BookingFilterData {
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
  String? categoryId;
  String? subCategoryId;
  String? servicemanId;
  double? totalCampaignDiscountAmount;
  double? totalCouponDiscountAmount;
  int? isChecked;
  Customer? customer;
  Provider? provider;
  ServiceAddress? serviceAddress;
  BookingStatusUiFields? statusUi;

  BookingFilterData(
      {this.id,
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
        this.categoryId,
        this.subCategoryId,
        this.servicemanId,
        this.totalCampaignDiscountAmount,
        this.totalCouponDiscountAmount,
        this.isChecked,
        this.customer,
        this.provider,
        this.serviceAddress,
        this.statusUi});

  BookingFilterData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    readableId = json['readable_id']?.toString();
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
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    servicemanId = json['serviceman_id'];
    totalCampaignDiscountAmount = double.tryParse(json['total_campaign_discount_amount'].toString());
    totalCouponDiscountAmount = double.tryParse(json['total_coupon_discount_amount'].toString());
    isChecked = json['is_checked'];
    customer = json['customer_info'] != null
        ? Customer.fromJson(json['customer_info'])
        : null;
    provider = json['provider'] != null
        ? Provider.fromJson(json['provider'])
        : null;
    serviceAddress = json['service_address'] != null
        ? ServiceAddress.fromJson(json['service_address'])
        : null;
    statusUi = BookingStatusUiFields.fromJson(json);
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
    data['category_id'] = categoryId;
    data['sub_category_id'] = subCategoryId;
    data['serviceman_id'] = servicemanId;
    data['total_campaign_discount_amount'] = totalCampaignDiscountAmount;
    data['total_coupon_discount_amount'] = totalCouponDiscountAmount;
    data['is_checked'] = isChecked;
    if (customer != null) {
      data['customer_info'] = customer!.toJson();
    }
    if (provider != null) {
      data['provider'] = provider!.toJson();
    }
    if (serviceAddress != null) {
      data['service_address'] = serviceAddress!.toJson();
    }
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
  String? fcmToken;
  int? isPhoneVerified;
  int? isEmailVerified;
  int? isActive;
  String? userType;
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
        this.fcmToken,
        this.isPhoneVerified,
        this.isEmailVerified,
        this.isActive,
        this.userType,
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
    fcmToken = json['fcm_token'];
    isPhoneVerified = json['is_phone_verified'];
    isEmailVerified = json['is_email_verified'];
    isActive = json['is_active'];
    userType = json['user_type'];
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
    data['fcm_token'] = fcmToken;
    data['is_phone_verified'] = isPhoneVerified;
    data['is_email_verified'] = isEmailVerified;
    data['is_active'] = isActive;
    data['user_type'] = userType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Provider {
  String? id;
  String? userId;
  String? companyName;
  String? companyPhone;
  String? companyAddress;
  String? companyEmail;
  String? logo;
  String? contactPersonName;
  String? contactPersonPhone;
  String? contactPersonEmail;
  int? orderCount;
  int? serviceManCount;
  int? serviceCapacityPerDay;
  int? ratingCount;
  double? avgRating;
  int? commissionStatus;
  int? commissionPercentage;
  int? isActive;
  String? createdAt;
  String? updatedAt;
  int? isApproved;
  String? zoneId;
  Owner? owner;

  Provider(
      {this.id,
        this.userId,
        this.companyName,
        this.companyPhone,
        this.companyAddress,
        this.companyEmail,
        this.logo,
        this.contactPersonName,
        this.contactPersonPhone,
        this.contactPersonEmail,
        this.orderCount,
        this.serviceManCount,
        this.serviceCapacityPerDay,
        this.ratingCount,
        this.avgRating,
        this.commissionStatus,
        this.commissionPercentage,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.isApproved,
        this.zoneId,
        this.owner});

  Provider.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    companyName = json['company_name'];
    companyPhone = json['company_phone'];
    companyAddress = json['company_address'];
    companyEmail = json['company_email'];
    logo = json['logo'];
    contactPersonName = json['contact_person_name'];
    contactPersonPhone = json['contact_person_phone'];
    contactPersonEmail = json['contact_person_email'];
    orderCount = json['order_count'];
    serviceManCount = json['service_man_count'];
    serviceCapacityPerDay = json['service_capacity_per_day'];
    ratingCount = json['rating_count'];
    avgRating = double.tryParse(json['avg_rating'].toString());
    commissionStatus = json['commission_status'];
    commissionPercentage = json['commission_percentage'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isApproved = json['is_approved'];
    zoneId = json['zone_id'];
    owner = json['owner'] != null ? Owner.fromJson(json['owner']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['company_name'] = companyName;
    data['company_phone'] = companyPhone;
    data['company_address'] = companyAddress;
    data['company_email'] = companyEmail;
    data['logo'] = logo;
    data['contact_person_name'] = contactPersonName;
    data['contact_person_phone'] = contactPersonPhone;
    data['contact_person_email'] = contactPersonEmail;
    data['order_count'] = orderCount;
    data['service_man_count'] = serviceManCount;
    data['service_capacity_per_day'] = serviceCapacityPerDay;
    data['rating_count'] = ratingCount;
    data['avg_rating'] = avgRating;
    data['commission_status'] = commissionStatus;
    data['commission_percentage'] = commissionPercentage;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_approved'] = isApproved;
    data['zone_id'] = zoneId;
    if (owner != null) {
      data['owner'] = owner!.toJson();
    }
    return data;
  }
}

class Owner {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? identificationNumber;
  String? identificationType;
  List<String>? identificationImage;
  String? gender;
  String? profileImage;
  String? fcmToken;
  int? isPhoneVerified;
  int? isEmailVerified;
  int? isActive;
  String? userType;
  String? createdAt;
  String? updatedAt;

  Owner(
      {this.id,
        this.firstName,
        this.lastName,
        this.email,
        this.phone,
        this.identificationNumber,
        this.identificationType,
        this.identificationImage,
        this.gender,
        this.profileImage,
        this.fcmToken,
        this.isPhoneVerified,
        this.isEmailVerified,
        this.isActive,
        this.userType,
        this.createdAt,
        this.updatedAt});

  Owner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    phone = json['phone'];
    identificationNumber = json['identification_number'];
    identificationType = json['identification_type'];
    if (json['identification_image'] != null) {
      identificationImage = (json['identification_image'] as List)
          .map((v) => v.toString())
          .toList();
    }
    gender = json['gender'];
    profileImage = json['profile_image'];
    fcmToken = json['fcm_token'];
    isPhoneVerified = json['is_phone_verified'];
    isEmailVerified = json['is_email_verified'];
    isActive = json['is_active'];
    userType = json['user_type'];
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
    data['identification_number'] = identificationNumber;
    data['identification_type'] = identificationType;
    data['identification_image'] = identificationImage;
    data['gender'] = gender;
    data['profile_image'] = profileImage;
    data['fcm_token'] = fcmToken;
    data['is_phone_verified'] = isPhoneVerified;
    data['is_email_verified'] = isEmailVerified;
    data['is_active'] = isActive;
    data['user_type'] = userType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

