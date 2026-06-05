class SignUpBody {
  String? providerType;
  String? contactPersonName;
  String? contactPersonPhone;
  String? contactPersonEmail;
  String? companyName;
  String? companyPhone;
  String? companyAddress;
  String? companyEmail;
  String? identityType;
  String? identityNumber;
  String? companyIdentityType;
  String? companyIdentityNumber;
  List<String>? zoneIds;
  List<String>? subscribedSubCategoryIds;
  String? lat;
  String? lon;
  String? chooseBusinessPlan;
  String? subscriptionPackageId;
  String? paymentMethod;
  String? freeTrialOrPayment;
  String? paymentPlatform;
  String? registrationToken;

  SignUpBody({
    this.providerType,
    this.contactPersonName,
    this.contactPersonPhone,
    this.contactPersonEmail,
    this.companyName,
    this.companyPhone,
    this.companyAddress,
    this.companyEmail,
    this.identityType,
    this.identityNumber,
    this.companyIdentityType,
    this.companyIdentityNumber,
    this.zoneIds,
    this.subscribedSubCategoryIds,
    this.lat,
    this.lon,
    this.chooseBusinessPlan,
    this.subscriptionPackageId,
    this.paymentMethod,
    this.freeTrialOrPayment,
    this.paymentPlatform,
    this.registrationToken,
  });

  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    final type = providerType ?? 'individual';
    data['provider_type'] = type;
    data['contact_person_name'] = contactPersonName ?? '';
    data['contact_person_phone'] = contactPersonPhone ?? '';
    if (contactPersonEmail != null && contactPersonEmail!.isNotEmpty) {
      data['contact_person_email'] = contactPersonEmail!;
    }
    data['company_address'] = companyAddress ?? '';
    data['identity_type'] = identityType ?? '';
    data['identity_number'] = identityNumber ?? '';
    data['latitude'] = lat ?? '';
    data['longitude'] = lon ?? '';
    data['choose_business_plan'] = chooseBusinessPlan ?? 'commission_base';
    data['payment_platform'] = paymentPlatform ?? 'app';
    if (registrationToken != null && registrationToken!.isNotEmpty) {
      data['registration_token'] = registrationToken!;
    }

    if (type == 'company') {
      if (companyName != null && companyName!.isNotEmpty) {
        data['company_name'] = companyName!;
      }
      if (companyPhone != null && companyPhone!.isNotEmpty) {
        data['company_phone'] = companyPhone!;
      }
      if (companyEmail != null && companyEmail!.isNotEmpty) {
        data['company_email'] = companyEmail!;
      }
      if (companyIdentityType != null && companyIdentityType!.isNotEmpty) {
        data['company_identity_type'] = companyIdentityType!;
      }
      if (companyIdentityNumber != null && companyIdentityNumber!.isNotEmpty) {
        data['company_identity_number'] = companyIdentityNumber!;
      }
    }

    if (subscriptionPackageId != null && subscriptionPackageId!.isNotEmpty) {
      data['selected_package_id'] = subscriptionPackageId!;
    }
    if (paymentMethod != null && paymentMethod!.isNotEmpty) {
      data['payment_method'] = paymentMethod!;
    }
    if (freeTrialOrPayment != null && freeTrialOrPayment!.isNotEmpty) {
      data['free_trial_or_payment'] = freeTrialOrPayment!;
    }

    if (zoneIds != null) {
      for (int i = 0; i < zoneIds!.length; i++) {
        data['zone_ids[$i]'] = zoneIds![i];
      }
    }

    if (subscribedSubCategoryIds != null) {
      for (int i = 0; i < subscribedSubCategoryIds!.length; i++) {
        data['subscribed_sub_category_ids[$i]'] = subscribedSubCategoryIds![i];
      }
    }

    return data;
  }
}
