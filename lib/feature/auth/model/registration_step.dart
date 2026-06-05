/// Onboarding steps aligned with provider registration UI design.
enum RegistrationStep {
  providerType,
  contactInfo,
  identityVerification,
  companyInformation,
  companyDocuments,
  serviceAreas,
  currentAddress,
  serviceCategories,
  serviceSubcategories,
  review,
}

extension RegistrationStepExtension on RegistrationStep {
  String get titleKey {
    switch (this) {
      case RegistrationStep.providerType:
        return 'choose_provider_type';
      case RegistrationStep.contactInfo:
        return 'contact_person_info_title';
      case RegistrationStep.identityVerification:
        return 'identity_verification';
      case RegistrationStep.companyInformation:
        return 'company_information';
      case RegistrationStep.companyDocuments:
        return 'company_documents';
      case RegistrationStep.serviceAreas:
        return 'service_zones';
      case RegistrationStep.currentAddress:
        return 'address_information';
      case RegistrationStep.serviceCategories:
        return 'service_categories';
      case RegistrationStep.serviceSubcategories:
        return 'service_subcategories';
      case RegistrationStep.review:
        return 'review_and_submit';
    }
  }

  bool get isCompanyOnly =>
      this == RegistrationStep.companyInformation || this == RegistrationStep.companyDocuments;
}

extension RegistrationStepApi on RegistrationStep {
  String get apiStepKey {
    switch (this) {
      case RegistrationStep.providerType:
        return 'provider_type';
      case RegistrationStep.contactInfo:
        return 'contact_info';
      case RegistrationStep.identityVerification:
        return 'identity_verification';
      case RegistrationStep.companyInformation:
        return 'company_information';
      case RegistrationStep.companyDocuments:
        return 'company_documents';
      case RegistrationStep.serviceAreas:
        return 'service_areas';
      case RegistrationStep.currentAddress:
        return 'current_address';
      case RegistrationStep.serviceCategories:
        return 'service_categories';
      case RegistrationStep.serviceSubcategories:
        return 'service_subcategories';
      case RegistrationStep.review:
        return 'review';
    }
  }
}

RegistrationStep? registrationStepFromApiKey(String? key) {
  if (key == null || key.isEmpty) return null;
  if (key == 'services') {
    return RegistrationStep.serviceSubcategories;
  }
  for (final step in RegistrationStep.values) {
    if (step.apiStepKey == key) return step;
  }
  return null;
}

List<RegistrationStep> registrationStepFlow({required bool isCompany}) {
  const shared = [
    RegistrationStep.providerType,
    RegistrationStep.contactInfo,
    RegistrationStep.identityVerification,
  ];
  const afterAddress = [
    RegistrationStep.serviceCategories,
    RegistrationStep.serviceSubcategories,
    RegistrationStep.review,
  ];
  if (isCompany) {
    return [
      ...shared,
      RegistrationStep.companyInformation,
      RegistrationStep.companyDocuments,
      RegistrationStep.serviceAreas,
      RegistrationStep.currentAddress,
      ...afterAddress,
    ];
  }
  return [
    ...shared,
    RegistrationStep.serviceAreas,
    RegistrationStep.currentAddress,
    ...afterAddress,
  ];
}
