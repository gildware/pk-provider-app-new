import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class SignUpController extends GetxController {
  final AuthRepo authRepo;
  SignUpController({required this.authRepo});


  bool? _isLoading = false;
  bool? get isLoading => _isLoading;

  bool _isLogoValid = true;
  bool get isLogoValid => _isLogoValid;

  bool _isContactPhotoValid = true;
  bool get isContactPhotoValid => _isContactPhotoValid;

  bool _isZoneValid = true;
  bool get isZoneValid => _isZoneValid;

  bool _isIdentityTypeValid = true;
  bool get isIdentityTypeValid => _isIdentityTypeValid;

  bool _isIdentityImageValid = true;
  bool get isIdentityImageValid => _isIdentityImageValid;

  bool _isCompanyIdentityTypeValid = true;
  bool get isCompanyIdentityTypeValid => _isCompanyIdentityTypeValid;

  bool _isCompanyIdentityImageValid = true;
  bool get isCompanyIdentityImageValid => _isCompanyIdentityImageValid;

  String? _emailErrorText;
  String? get emailErrorText => _emailErrorText;

  String? _phoneErrorText;
  String? get phoneErrorText => _phoneErrorText;

  int _selectedDigitalPaymentMethodIndex = -1;
  int get selectedDigitalPaymentMethodIndex => _selectedDigitalPaymentMethodIndex;

  RegistrationStep currentRegistrationStep = RegistrationStep.providerType;

  /// Show upload/photo errors only after the user tries to continue on that step.
  bool showRegistrationFieldErrors = false;

  /// Set when user completed phone OTP on the login screen before registration.
  bool phoneVerifiedForRegistration = false;
  String? verifiedRegistrationPhone;

  /// Backend session for multi-step save & resume.
  String? registrationToken;
  String? draftContactPhotoUrl;
  String? draftLogoUrl;
  final List<String> draftCompanyIdentityImageUrls = [];

  ProviderType providerType = ProviderType.individual;
  bool get isCompanyProvider => providerType == ProviderType.company;

  BusinessPlanType? selectedBusinessPlan;
  SubscriptionPaymentType? selectedSubscriptionPaymentType;

  SubscriptionPackage? selectedSubscriptionPackage;

  XFile? _identityImageFront;
  XFile? _identityImageBack;
  XFile? get identityImageFront => _identityImageFront;
  XFile? get identityImageBack => _identityImageBack;

  String? draftIdentityFrontUrl;
  String? draftIdentityBackUrl;

  bool get hasIdentityFront =>
      _identityImageFront != null || (draftIdentityFrontUrl != null && draftIdentityFrontUrl!.isNotEmpty);

  bool get hasIdentityBack =>
      _identityImageBack != null || (draftIdentityBackUrl != null && draftIdentityBackUrl!.isNotEmpty);

  List<MultipartBody> get identityImagesForSubmit {
    final files = <MultipartBody>[];
    if (_identityImageFront != null) {
      files.add(MultipartBody('identity_image_front', _identityImageFront!));
    }
    if (_identityImageBack != null) {
      files.add(MultipartBody('identity_image_back', _identityImageBack!));
    }
    return files;
  }

  final List<MultipartBody> _selectedCompanyIdentityImageList = [];
  List<MultipartBody> get selectedCompanyIdentityImageList => _selectedCompanyIdentityImageList;

  var companyNameController = TextEditingController();
  var companyPhoneController = TextEditingController();
  var companyAddressController = TextEditingController();
  var companyEmailController = TextEditingController();
  var streetController = TextEditingController();
  var cityController = TextEditingController();
  var stateController = TextEditingController();
  var pincodeController = TextEditingController();

  var contactPersonNameController = TextEditingController();
  var contactPersonPhoneController = TextEditingController();
  var contactPersonEmailController = TextEditingController();

  var identityNumberController = TextEditingController();
  var companyIdentityNumberController = TextEditingController();

  String selectedIdentityType = '';
  String selectedCompanyIdentityType = '';
  List<String> selectedZoneIds = [];

  List<ZoneData> zoneList = [];
  final Map<String, ZoneTreeNode> _zoneNodesById = {};
  final Map<String, String?> _zoneParentIdById = {};
  List<String> selectedCategoryIds = [];
  List<String> selectedSubCategoryIds = [];
  final Map<String, String> _subCategoryParentCategoryId = {};
  List<ServiceCategoryModel> registrationCategories = [];
  List<ServiceSubCategoryModel> registrationSubCategories = [];
  int registrationCategoryIndex = 0;
  bool isRegistrationCategoriesLoading = false;
  bool isRegistrationSubCategoriesLoading = false;

  var countryDialCode = '+880';

  List<RegistrationStep> get registrationSteps => registrationStepFlow(isCompany: isCompanyProvider);

  List<ZoneData> get selectedZones {
    if (selectedZoneIds.isEmpty) return [];
    final byId = {for (final z in zoneList) z.id: z};
    return selectedZoneIds.map((id) => byId[id]).whereType<ZoneData>().toList();
  }

  /// Top-level picks only (hide children when parent is already selected).
  List<ZoneData> get selectedZonesForDisplay {
    return selectedZones.where((zone) {
      var parentId = _zoneParentIdById[zone.id];
      while (parentId != null && parentId.isNotEmpty) {
        if (selectedZoneIds.contains(parentId)) return false;
        parentId = _zoneParentIdById[parentId];
      }
      return true;
    }).toList();
  }

  int countDescendantZones(String zoneId) {
    final node = _zoneNodesById[zoneId];
    if (node == null || !node.isParent) return 0;
    return node.collectSubtreeZoneIds().length - 1;
  }

  List<ZoneData> filterZonesForDropdown(String pattern) {
    final q = pattern.trim().toLowerCase();
    return zoneList.where((z) {
      if (z.id != null && selectedZoneIds.contains(z.id)) return false;
      if (q.isEmpty) return true;
      final haystack = '${z.name ?? ''} ${z.description ?? ''}'.toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  bool isZoneSelected(String? zoneId) =>
      zoneId != null && zoneId.isNotEmpty && selectedZoneIds.contains(zoneId);

  String get selectedZoneReviewText {
    if (selectedZonesForDisplay.isEmpty) return '';
    return selectedZonesForDisplay
        .map((z) {
          final desc = z.hasDescription ? '\n${z.description!.trim()}' : '';
          final childCount = countDescendantZones(z.id ?? '');
          final suffix = childCount > 0 ? '\n+$childCount sub-areas' : '';
          return '${z.name}$desc$suffix';
        })
        .join('\n\n');
  }

  bool get hasSelectedCategories => selectedCategoryIds.isNotEmpty;

  bool get hasSelectedSubCategories => selectedSubCategoryIds.isNotEmpty;

  List<ServiceCategoryModel> get selectedRegistrationCategories {
    return registrationCategories
        .where((c) => c.id != null && selectedCategoryIds.contains(c.id))
        .toList();
  }

  String get selectedCategoriesReviewText {
    if (selectedCategoryIds.isEmpty) return '';
    final names = registrationCategories
        .where((c) => c.id != null && selectedCategoryIds.contains(c.id))
        .map((c) => c.name ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    return names.isEmpty ? '${selectedCategoryIds.length} ${trLabel('categories')}' : names.join(', ');
  }

  String get selectedSubCategoriesReviewText {
    if (selectedSubCategoryIds.isEmpty) return '';
    final names = <String>[];
    for (final sub in registrationSubCategories) {
      if (sub.id != null && selectedSubCategoryIds.contains(sub.id)) {
        names.add(sub.name ?? '');
      }
    }
    if (names.isEmpty) {
      return '${selectedSubCategoryIds.length} ${trLabel('subscribed_categories')}';
    }
    return names.join(', ');
  }

  int get totalRegistrationSteps => registrationSteps.length;

  int get registrationStepNumber => registrationSteps.indexOf(currentRegistrationStep) + 1;

  bool get isOnReviewStep => currentRegistrationStep == RegistrationStep.review;

  /// Whether the current step has all required fields filled (enables Save and Continue).
  bool get canProceedFromCurrentStep {
    switch (currentRegistrationStep) {
      case RegistrationStep.providerType:
        return true;
      case RegistrationStep.contactInfo:
        if (contactPersonNameController.text.trim().isEmpty) return false;
        if (!hasContactPhotoForSubmit) return false;
        final email = contactPersonEmailController.text.trim();
        if (email.isNotEmpty && FormValidationHelper().isValidEmail(email) != null) {
          return false;
        }
        if (phoneVerifiedForRegistration) return true;
        final phone = contactPersonPhoneController.text.trim();
        if (phone.isEmpty) return false;
        return FormValidationHelper().isValidPhone(countryDialCode + phone) == null;
      case RegistrationStep.identityVerification:
        return selectedIdentityType.isNotEmpty &&
            identityNumberController.text.trim().isNotEmpty &&
            hasIdentityFront &&
            hasIdentityBack;
      case RegistrationStep.companyInformation:
        if (!isCompanyProvider) return true;
        if (companyNameController.text.trim().isEmpty) return false;
        if (companyPhoneController.text.trim().isEmpty) return false;
        if (FormValidationHelper().isValidPhone(
              countryDialCode + companyPhoneController.text,
            ) !=
            null) {
          return false;
        }
        return hasLogoForSubmit;
      case RegistrationStep.companyDocuments:
        if (!isCompanyProvider) return true;
        return selectedCompanyIdentityType.isNotEmpty &&
            companyIdentityNumberController.text.trim().isNotEmpty &&
            hasCompanyIdentityImagesForSubmit;
      case RegistrationStep.serviceAreas:
        return isZoneValid;
      case RegistrationStep.currentAddress:
        return streetController.text.trim().isNotEmpty &&
            cityController.text.trim().isNotEmpty &&
            pincodeController.text.trim().isNotEmpty;
      case RegistrationStep.serviceCategories:
        return hasSelectedCategories;
      case RegistrationStep.serviceSubcategories:
        return hasSelectedSubCategories;
      case RegistrationStep.review:
        return true;
    }
  }

  bool get hasContactPhotoForSubmit =>
      contactPersonPhotoFile != null ||
      (draftContactPhotoUrl != null && draftContactPhotoUrl!.isNotEmpty);

  bool get hasLogoForSubmit =>
      !isCompanyProvider ||
      profileImageFile != null ||
      (draftLogoUrl != null && draftLogoUrl!.isNotEmpty);

  bool get hasCompanyIdentityImagesForSubmit =>
      !isCompanyProvider ||
      _selectedCompanyIdentityImageList.isNotEmpty ||
      draftCompanyIdentityImageUrls.isNotEmpty;

  bool get isReadyForFinalSubmit {
    if (contactPersonNameController.text.trim().isEmpty) return false;
    if (!hasContactPhotoForSubmit) return false;
    if (selectedZoneIds.isEmpty) return false;
    if (!hasSelectedCategories) return false;
    if (!hasSelectedSubCategories) return false;
    if (selectedIdentityType.isEmpty || identityNumberController.text.trim().isEmpty) {
      return false;
    }
    if (!hasIdentityFront || !hasIdentityBack) return false;
    if (buildFormattedAddress().trim().isEmpty) return false;
    if (isCompanyProvider) {
      if (companyNameController.text.trim().isEmpty) return false;
      if (companyPhoneController.text.trim().isEmpty) return false;
      if (selectedCompanyIdentityType.isEmpty ||
          companyIdentityNumberController.text.trim().isEmpty) {
        return false;
      }
      if (_selectedCompanyIdentityImageList.isEmpty &&
          draftCompanyIdentityImageUrls.isEmpty) {
        return false;
      }
      if (!hasLogoForSubmit) return false;
    }
    return true;
  }

  Future<bool> prepareForFinalSubmit() async {
    if (registrationToken != null && registrationToken!.isNotEmpty) {
      final response = await authRepo.fetchRegistrationDraft(registrationToken!);
      if (response?.statusCode == 200 && response?.body['content'] is Map) {
        mergeDraftData(
          ProviderRegistrationDraft.fromJson(
            Map<String, dynamic>.from(response!.body['content']),
          ),
        );
      }
    }
    syncFinalSubmitValidityFlags();
    return isReadyForFinalSubmit;
  }

  void syncFinalSubmitValidityFlags() {
    _isContactPhotoValid = hasContactPhotoForSubmit;
    _isLogoValid = hasLogoForSubmit;
    _isZoneValid = selectedZoneIds.isNotEmpty;
    _isIdentityTypeValid = selectedIdentityType.isNotEmpty;
    _isIdentityImageValid = hasIdentityFront && hasIdentityBack;
    if (isCompanyProvider) {
      _isCompanyIdentityTypeValid = selectedCompanyIdentityType.isNotEmpty;
      _isCompanyIdentityImageValid = _selectedCompanyIdentityImageList.isNotEmpty ||
          draftCompanyIdentityImageUrls.isNotEmpty;
    } else {
      _isCompanyIdentityTypeValid = true;
      _isCompanyIdentityImageValid = true;
    }
  }

  void clearRegistrationFieldErrors() {
    showRegistrationFieldErrors = false;
  }

  bool _registrationListenersBound = false;

  void bindRegistrationFieldListeners() {
    if (_registrationListenersBound) return;
    _registrationListenersBound = true;

    void onFieldChange() {
      _syncProceedFlagsForCurrentStep();
      update();
    }

    for (final controller in [
      contactPersonNameController,
      contactPersonPhoneController,
      contactPersonEmailController,
      identityNumberController,
      companyNameController,
      companyPhoneController,
      companyEmailController,
      companyIdentityNumberController,
      streetController,
      cityController,
      stateController,
      pincodeController,
      companyAddressController,
    ]) {
      controller.addListener(onFieldChange);
    }
  }

  int get registrationProgressPercent {
    final completed = registrationSteps.indexOf(currentRegistrationStep);
    if (completed < 0) return 0;
    return ((completed + 1) / registrationSteps.length * 100).round().clamp(0, 100);
  }

  String buildFormattedAddress() {
    final parts = [
      streetController.text.trim(),
      cityController.text.trim(),
      pincodeController.text.trim(),
    ].where((e) => e.isNotEmpty).toList();
    if (parts.isNotEmpty) return parts.join(', ');
    return companyAddressController.text.trim();
  }

  void syncAddressFromMap(String address) {
    companyAddressController.text = address;
    if (streetController.text.isEmpty && address.isNotEmpty) {
      streetController.text = address;
    }
    update();
  }

  void addSelectedZone(ZoneData zone) {
    final id = zone.id;
    if (id == null || id.isEmpty) return;

    final node = _zoneNodesById[id];
    final idsToAdd = node?.collectSubtreeZoneIds() ?? [id];
    var added = false;
    for (final zoneId in idsToAdd) {
      if (!selectedZoneIds.contains(zoneId)) {
        selectedZoneIds.add(zoneId);
        added = true;
      }
    }
    if (!added) return;
    checkOthersFieldValidity(step2: true);
    update();
  }

  void removeSelectedZone(String zoneId) {
    final node = _zoneNodesById[zoneId];
    final idsToRemove = node?.collectSubtreeZoneIds().toSet() ?? {zoneId};
    selectedZoneIds.removeWhere(idsToRemove.contains);
    checkOthersFieldValidity(step2: true);
    update();
  }

  void clearSelectedZones() {
    selectedZoneIds = [];
    checkOthersFieldValidity(step2: true);
    update();
  }

  void _syncSelectedZonesFromIds() {
    selectedZoneIds = selectedZoneIds.where((id) => zoneList.any((z) => z.id == id)).toList();
  }

  Future<void> loadRegistrationCategories() async {
    if (selectedZoneIds.isEmpty) return;
    isRegistrationCategoriesLoading = true;
    update();
    final response = await authRepo.getRegistrationCategories(selectedZoneIds);
    registrationCategories = [];
    if (response != null && response.statusCode == 200) {
      final list = response.body['content']?['data'];
      if (list is List) {
        for (final item in list) {
          registrationCategories.add(ServiceCategoryModel.fromJson(Map<String, dynamic>.from(item as Map)));
        }
      }
      if (registrationCategories.isNotEmpty) {
        if (registrationCategoryIndex >= registrationCategories.length) {
          registrationCategoryIndex = 0;
        }
        await loadRegistrationSubCategories();
      } else {
        registrationSubCategories = [];
      }
    }
    isRegistrationCategoriesLoading = false;
    update();
  }

  Future<void> loadRegistrationSubCategories() async {
    if (registrationCategories.isEmpty || selectedZoneIds.isEmpty) {
      registrationSubCategories = [];
      update();
      return;
    }
    final categories = selectedRegistrationCategories;
    if (categories.isEmpty || registrationCategoryIndex >= categories.length) {
      registrationSubCategories = [];
      update();
      return;
    }
    final categoryId = categories[registrationCategoryIndex].id?.toString() ?? '';
    if (categoryId.isEmpty) return;

    isRegistrationSubCategoriesLoading = true;
    update();
    final response = await authRepo.getRegistrationSubCategories(
      categoryId: categoryId,
      zoneIds: selectedZoneIds,
    );
    registrationSubCategories = [];
    if (response != null && response.statusCode == 200) {
      final list = response.body['content']?['data'];
      if (list is List) {
        for (final item in list) {
          final sub = ServiceSubCategoryModel.fromJson(Map<String, dynamic>.from(item as Map));
          if ((sub.servicesCount ?? 0) <= 0) {
            continue;
          }
          sub.isSubscribed = selectedSubCategoryIds.contains(sub.id) ? 1 : 0;
          if (sub.id != null) {
            _subCategoryParentCategoryId[sub.id!] = categoryId;
          }
          registrationSubCategories.add(sub);
        }
      }
    }
    isRegistrationSubCategoriesLoading = false;
    update();
  }

  void toggleRegistrationCategory(String categoryId) {
    if (selectedCategoryIds.contains(categoryId)) {
      selectedCategoryIds.remove(categoryId);
      selectedSubCategoryIds.removeWhere(
        (subId) => _subCategoryParentCategoryId[subId] == categoryId,
      );
      if (registrationCategoryIndex >= selectedCategoryIds.length) {
        registrationCategoryIndex = 0;
      }
    } else {
      selectedCategoryIds.add(categoryId);
    }
    _syncProceedFlagsForCurrentStep();
    update();
  }

  void prepareServiceSubcategoriesStep() {
    if (selectedCategoryIds.isEmpty) return;
    if (registrationCategoryIndex >= selectedRegistrationCategories.length) {
      registrationCategoryIndex = 0;
    }
    loadRegistrationSubCategories();
  }

  void selectRegistrationCategory(int index) {
    if (index < 0 || index >= selectedRegistrationCategories.length) return;
    registrationCategoryIndex = index;
    loadRegistrationSubCategories();
  }

  void toggleRegistrationSubCategory(String subCategoryId) {
    if (selectedSubCategoryIds.contains(subCategoryId)) {
      selectedSubCategoryIds.remove(subCategoryId);
    } else {
      selectedSubCategoryIds.add(subCategoryId);
    }
    for (final sub in registrationSubCategories) {
      if (sub.id == subCategoryId) {
        sub.isSubscribed = selectedSubCategoryIds.contains(subCategoryId) ? 1 : 0;
      }
    }
    update();
  }

  void goToRegistrationStep(RegistrationStep step) {
    if (registrationSteps.contains(step)) {
      clearRegistrationFieldErrors();
      currentRegistrationStep = step;
      if (step == RegistrationStep.serviceCategories) {
        loadRegistrationCategories();
      } else if (step == RegistrationStep.serviceSubcategories) {
        prepareServiceSubcategoriesStep();
      }
      update();
    }
  }

  void goToNextRegistrationStep() {
    final index = registrationSteps.indexOf(currentRegistrationStep);
    if (index >= 0 && index < registrationSteps.length - 1) {
      clearRegistrationFieldErrors();
      final next = registrationSteps[index + 1];
      currentRegistrationStep = next;
      if (next == RegistrationStep.serviceCategories &&
          registrationCategories.isEmpty &&
          selectedZoneIds.isNotEmpty) {
        loadRegistrationCategories();
      } else if (next == RegistrationStep.serviceSubcategories) {
        prepareServiceSubcategoriesStep();
      }
      update();
    }
  }

  XFile? _profileImageFile;
  XFile? get profileImageFile => _profileImageFile;

  XFile? _contactPersonPhotoFile;
  XFile? get contactPersonPhotoFile => _contactPersonPhotoFile;

  @override
  void onInit() {
    super.onInit();
    getZoneList();
    resetAllValue(shouldUpdate: false);
    countryDialCode = ConfigHelper.defaultCountryDialCode;
    applyVerifiedPhoneFromRoute();
    applyRegistrationSessionFromRoute();
    applyDraftIfPresent();
    loadDraftFromServerIfNeeded();
    bindRegistrationFieldListeners();
  }

  Future<void> loadDraftFromServerIfNeeded() async {
    if (Get.arguments is Map && (Get.arguments as Map)['draft'] != null) return;
    if (registrationToken == null || registrationToken!.isEmpty) return;

    final response = await authRepo.fetchRegistrationDraft(registrationToken!);
    if (response?.statusCode == 200 && response?.body['content'] is Map) {
      applyDraft(ProviderRegistrationDraft.fromJson(Map<String, dynamic>.from(response!.body['content'])));
    }
  }

  void applyRegistrationSessionFromRoute() {
    final token = Get.parameters['registration_token']?.trim();
    registrationToken = (token != null && token.isNotEmpty) ? token : authRepo.getRegistrationToken();
    if (registrationToken != null && registrationToken!.isNotEmpty) {
      phoneVerifiedForRegistration = true;
      authRepo.persistRegistrationSession(
        token: registrationToken!,
        phone: verifiedRegistrationPhone ?? authRepo.getRegistrationPhone() ?? '',
      );
    }
  }

  void applyDraftIfPresent() {
    final dynamic raw = Get.arguments is Map ? (Get.arguments as Map)['draft'] : null;
    if (raw is! Map) return;
    applyDraft(ProviderRegistrationDraft.fromJson(Map<String, dynamic>.from(raw)));
  }

  void applyDraft(ProviderRegistrationDraft draft) {
    mergeDraftData(draft);
    currentRegistrationStep = _resolveResumeStep(draft);
    update();
  }

  void mergeDraftData(ProviderRegistrationDraft draft) {
    registrationToken = draft.registrationToken.isNotEmpty ? draft.registrationToken : registrationToken;
    if (registrationToken != null && registrationToken!.isNotEmpty) {
      phoneVerifiedForRegistration = true;
      authRepo.persistRegistrationSession(token: registrationToken!, phone: draft.phone);
    }

    final type = draft.providerType.toLowerCase();
    providerType = type == 'company' ? ProviderType.company : ProviderType.individual;

    final data = draft.formData;
    void setText(TextEditingController c, String key) {
      final v = data[key]?.toString();
      if (v != null && v.isNotEmpty) c.text = v;
    }

    setText(contactPersonNameController, 'contact_person_name');
    setText(contactPersonEmailController, 'contact_person_email');
    setText(identityNumberController, 'identity_number');
    setText(companyNameController, 'company_name');
    setText(companyEmailController, 'company_email');
    setText(companyAddressController, 'company_address');
    setText(streetController, 'street');
    setText(cityController, 'city');
    setText(stateController, 'state');
    setText(pincodeController, 'pincode');
    setText(companyIdentityNumberController, 'company_identity_number');

    if (data['contact_person_phone'] != null) {
      final phone = data['contact_person_phone'].toString();
      final local = ValidationHelper.getValidPhone(phone);
      final dial = ValidationHelper.getCountryCode(phone);
      if (dial.isNotEmpty) countryDialCode = dial.startsWith('+') ? dial : '+$dial';
      contactPersonPhoneController.text = local.isNotEmpty ? local : phone;
    }

    if (data['company_phone'] != null) {
      companyPhoneController.text = ValidationHelper.getValidPhone(data['company_phone'].toString());
    }

    selectedIdentityType = data['identity_type']?.toString() ?? selectedIdentityType;
    selectedCompanyIdentityType = data['company_identity_type']?.toString() ?? selectedCompanyIdentityType;

    final zones = data['zone_ids'];
    if (zones is List) {
      selectedZoneIds = zones.map((e) => e.toString()).where((id) => id.isNotEmpty).toList();
    }

    final cats = data['selected_category_ids'];
    if (cats is List) {
      selectedCategoryIds = cats.map((e) => e.toString()).where((id) => id.isNotEmpty).toList();
    }

    final subs = data['subscribed_sub_category_ids'] ?? data['selected_service_keys'];
    if (subs is List) {
      selectedSubCategoryIds = subs.map((e) => e.toString()).where((id) => id.isNotEmpty).toList();
    }

    final lat = data['latitude']?.toString();
    final lon = data['longitude']?.toString();
    if (lat != null && lon != null && lat.isNotEmpty && lon.isNotEmpty) {
      Get.find<LocationController>().setPickedLocation(
        address: ServiceAddress(
          lat: double.tryParse(lat),
          lon: double.tryParse(lon),
          address: data['company_address']?.toString(),
        ),
        shouldUpdate: false,
      );
    }

    draftContactPhotoUrl = draft.files['contact_person_photo']?.toString();
    draftLogoUrl = draft.files['logo']?.toString();
    draftIdentityFrontUrl = draft.files['identity_image_front']?.toString();
    draftIdentityBackUrl = draft.files['identity_image_back']?.toString();
    final identityFiles = draft.files['identity_images'];
    if (identityFiles is List) {
      if ((draftIdentityFrontUrl == null || draftIdentityFrontUrl!.isEmpty) && identityFiles.isNotEmpty) {
        draftIdentityFrontUrl = identityFiles[0].toString();
      }
      if ((draftIdentityBackUrl == null || draftIdentityBackUrl!.isEmpty) && identityFiles.length > 1) {
        draftIdentityBackUrl = identityFiles[1].toString();
      }
    }
    draftCompanyIdentityImageUrls.clear();
    final companyFiles = draft.files['company_identity_images'];
    if (companyFiles is List && companyFiles.isNotEmpty) {
      final first = companyFiles.first.toString();
      if (first.isNotEmpty) {
        draftCompanyIdentityImageUrls.add(first);
      }
    }

    checkOthersFieldValidity(shouldUpdate: false, isInitial: true);
    if (draftContactPhotoUrl != null && draftContactPhotoUrl!.isNotEmpty) {
      _isContactPhotoValid = true;
    }
    if (draftLogoUrl != null && draftLogoUrl!.isNotEmpty) {
      _isLogoValid = true;
    }
    if (hasIdentityFront && hasIdentityBack) {
      _isIdentityImageValid = true;
    }
    if (draftCompanyIdentityImageUrls.isNotEmpty) {
      _isCompanyIdentityImageValid = true;
      _selectedCompanyIdentityImageList.clear();
    }
    _isIdentityTypeValid = selectedIdentityType.isNotEmpty;
    if (isCompanyProvider) {
      _isCompanyIdentityTypeValid = selectedCompanyIdentityType.isNotEmpty;
    }
    _syncSelectedZonesFromIds();
    if (selectedZoneIds.isNotEmpty) {
      loadRegistrationCategories();
    }
  }

  RegistrationStep _resolveResumeStep(ProviderRegistrationDraft draft) {
    final fromApi = registrationStepFromApiKey(draft.currentStep);
    if (fromApi != null && registrationSteps.contains(fromApi)) {
      return fromApi;
    }

    for (final step in registrationSteps) {
      if (step == RegistrationStep.review) {
        return RegistrationStep.review;
      }
      if (!draft.completedSteps.contains(step.apiStepKey)) {
        return step;
      }
    }

    return registrationSteps.last;
  }

  Future<bool> saveRegistrationStepToBackend(RegistrationStep step) async {
    if (step == RegistrationStep.providerType) {
      goToNextRegistrationStep();
      return true;
    }

    if (registrationToken == null || registrationToken!.isEmpty) {
      if (step == RegistrationStep.contactInfo) {
        // Draft is created on first contact_info save.
      } else if (!await _ensureRegistrationDraftToken()) {
        showCustomSnackBar(trLabel('complete_contact_step_first'));
        return false;
      }
    }

    _isLoading = true;
    update();

    try {
      final fields = _buildStepFields(step);
      final files = _buildStepFiles(step);
      final response = await authRepo.saveRegistrationStep(
        registrationToken: registrationToken ?? '',
        step: step.apiStepKey,
        fields: fields,
        files: files,
      );

      if (response != null && _isRegistrationStepSaveSuccess(response)) {
        final content = response.body is Map ? response.body['content'] : null;
        if (content is Map) {
          mergeDraftData(ProviderRegistrationDraft.fromJson(Map<String, dynamic>.from(content)));
        }
        if (step == RegistrationStep.companyDocuments) {
          _finalizeCompanyDocumentsAfterSave();
        }
        goToNextRegistrationStep();
        return true;
      }

      if (response?.statusCode == 1) {
        showCustomSnackBar(trLabel('failed_to_save_step'));
        return false;
      }

      final message = _extractApiErrorMessage(response);
      showCustomSnackBar(localizeMessage(message ?? 'failed_to_save_step'));
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('saveRegistrationStepToBackend error: $e');
      }
      showCustomSnackBar(trLabel('failed_to_save_step'));
      return false;
    } finally {
      _isLoading = false;
      update();
    }
  }

  String? _extractApiErrorMessage(Response? response) {
    if (response?.body is! Map) {
      return null;
    }
    final body = Map<String, dynamic>.from(response!.body as Map);
    final topMessage = body['message']?.toString();
    if (body['errors'] is List && (body['errors'] as List).isNotEmpty) {
      final first = (body['errors'] as List).first;
      if (first is Map) {
        final detail = first['message']?.toString();
        if (detail != null &&
            detail.isNotEmpty &&
            topMessage != null &&
            topMessage.toLowerCase().contains('invalid or missing')) {
          return detail;
        }
        return detail ?? topMessage;
      }
    }
    return topMessage;
  }

  bool _isRegistrationStepSaveSuccess(Response response) {
    if (response.statusCode != 200 || response.body is! Map) {
      return false;
    }
    final body = Map<String, dynamic>.from(response.body as Map);
    final code = body['response_code']?.toString();
    if (code == 'provider_registration_step_saved_200') {
      return true;
    }
    final content = body['content'];
    return content is Map && content['registration_token'] != null;
  }

  Future<bool> _ensureRegistrationDraftToken() async {
    if (registrationToken != null && registrationToken!.isNotEmpty) {
      return true;
    }
    if (contactPersonNameController.text.trim().isEmpty ||
        contactPersonPhoneController.text.trim().isEmpty) {
      return false;
    }

    final response = await authRepo.saveRegistrationStep(
      registrationToken: '',
      step: RegistrationStep.contactInfo.apiStepKey,
      fields: _buildStepFields(RegistrationStep.contactInfo),
      files: _buildStepFiles(RegistrationStep.contactInfo),
    );

    if (response != null && _isRegistrationStepSaveSuccess(response)) {
      final content = response.body is Map ? response.body['content'] : null;
      if (content is Map) {
        mergeDraftData(ProviderRegistrationDraft.fromJson(Map<String, dynamic>.from(content)));
      }
      return registrationToken != null && registrationToken!.isNotEmpty;
    }
    return false;
  }

  void _finalizeCompanyDocumentsAfterSave() {
    if (draftCompanyIdentityImageUrls.isNotEmpty) {
      _selectedCompanyIdentityImageList.clear();
    }
    _isCompanyIdentityImageValid = hasCompanyIdentityImagesForSubmit;
    _isCompanyIdentityTypeValid = selectedCompanyIdentityType.isNotEmpty;
  }

  void _syncProceedFlagsForCurrentStep() {
    switch (currentRegistrationStep) {
      case RegistrationStep.contactInfo:
        _isContactPhotoValid = hasContactPhotoForSubmit;
        break;
      case RegistrationStep.companyInformation:
        _isLogoValid = hasLogoForSubmit;
        break;
      case RegistrationStep.companyDocuments:
        _isCompanyIdentityTypeValid = selectedCompanyIdentityType.isNotEmpty;
        _isCompanyIdentityImageValid = hasCompanyIdentityImagesForSubmit;
        break;
      case RegistrationStep.identityVerification:
        _isIdentityTypeValid = selectedIdentityType.isNotEmpty;
        _isIdentityImageValid = hasIdentityFront && hasIdentityBack;
        break;
      case RegistrationStep.serviceAreas:
        _isZoneValid = selectedZoneIds.isNotEmpty;
        break;
      default:
        break;
    }
  }

  Map<String, String> _buildStepFields(RegistrationStep step) {
    final loc = Get.find<LocationController>();
    final fields = <String, String>{
      'provider_type': isCompanyProvider ? 'company' : 'individual',
    };

    switch (step) {
      case RegistrationStep.providerType:
        break;
      case RegistrationStep.contactInfo:
        fields['contact_person_name'] = contactPersonNameController.text.trim();
        fields['contact_person_phone'] = _fullContactPhone();
        final email = contactPersonEmailController.text.trim();
        if (email.isNotEmpty) fields['contact_person_email'] = email;
        break;
      case RegistrationStep.identityVerification:
        fields['identity_type'] = selectedIdentityType;
        fields['identity_number'] = identityNumberController.text.trim();
        break;
      case RegistrationStep.companyInformation:
        fields['company_name'] = companyNameController.text.trim();
        fields['company_phone'] = _fullCompanyPhone();
        final cEmail = companyEmailController.text.trim();
        if (cEmail.isNotEmpty) fields['company_email'] = cEmail;
        break;
      case RegistrationStep.companyDocuments:
        fields['company_identity_type'] = selectedCompanyIdentityType;
        fields['company_identity_number'] = companyIdentityNumberController.text.trim();
        break;
      case RegistrationStep.serviceAreas:
        for (int i = 0; i < selectedZoneIds.length; i++) {
          fields['zone_ids[$i]'] = selectedZoneIds[i];
        }
        break;
      case RegistrationStep.currentAddress:
        fields['company_address'] = buildFormattedAddress();
        fields['street'] = streetController.text.trim();
        fields['city'] = cityController.text.trim();
        fields['state'] = stateController.text.trim();
        fields['pincode'] = pincodeController.text.trim();
        fields['latitude'] = '${loc.pickPosition.latitude}';
        fields['longitude'] = '${loc.pickPosition.longitude}';
        break;
      case RegistrationStep.serviceCategories:
        for (int i = 0; i < selectedCategoryIds.length; i++) {
          fields['selected_category_ids[$i]'] = selectedCategoryIds[i];
        }
        break;
      case RegistrationStep.serviceSubcategories:
        for (int i = 0; i < selectedSubCategoryIds.length; i++) {
          fields['subscribed_sub_category_ids[$i]'] = selectedSubCategoryIds[i];
        }
        break;
      case RegistrationStep.review:
        break;
    }
    return fields;
  }

  List<MultipartBody> _buildStepFiles(RegistrationStep step) {
    switch (step) {
      case RegistrationStep.contactInfo:
        if (_contactPersonPhotoFile != null) {
          return [MultipartBody('contact_person_photo', _contactPersonPhotoFile!)];
        }
        return [];
      case RegistrationStep.identityVerification:
        return identityImagesForSubmit;
      case RegistrationStep.companyInformation:
        if (_profileImageFile != null) {
          return [MultipartBody('logo', _profileImageFile!)];
        }
        return [];
      case RegistrationStep.companyDocuments:
        return List<MultipartBody>.from(_selectedCompanyIdentityImageList);
      default:
        return [];
    }
  }

  String _fullCompanyPhone() {
    final raw = companyPhoneController.text.trim();
    if (raw.isEmpty) return '';
    final candidate = raw.startsWith('+') ? raw : '$countryDialCode$raw';
    final parsed = ValidationHelper.getValidPhone(candidate, withCountryCode: true);
    if (parsed.isNotEmpty) {
      return parsed.startsWith('+') ? parsed : '+$parsed';
    }
    return candidate;
  }

  String _fullContactPhone() {
    if (verifiedRegistrationPhone != null && verifiedRegistrationPhone!.isNotEmpty) {
      return verifiedRegistrationPhone!;
    }
    return countryDialCode +
        ValidationHelper.getValidPhone('${countryDialCode}${contactPersonPhoneController.text}');
  }

  void applyVerifiedPhoneFromRoute() {
    final String? phone = Get.parameters['verified_phone']?.trim().isNotEmpty == true
        ? Get.parameters['verified_phone']!.trim()
        : (Get.arguments is Map ? (Get.arguments as Map)['verified_phone']?.toString() : null);

    if (phone == null || phone.isEmpty) return;

    phoneVerifiedForRegistration = true;
    verifiedRegistrationPhone = phone;

    final localPhone = ValidationHelper.getValidPhone(phone);
    final dialCode = ValidationHelper.getCountryCode(phone);
    if (dialCode.isNotEmpty) {
      countryDialCode = dialCode.startsWith('+') ? dialCode : '+$dialCode';
    }
    contactPersonPhoneController.text = localPhone.isNotEmpty ? localPhone : phone.replaceAll(countryDialCode, '');
    update();
  }

  void setProviderType(ProviderType type) {
    providerType = type;
    if (type == ProviderType.individual) {
      _clearCompanyFields();
    }
    if (!registrationSteps.contains(currentRegistrationStep)) {
      currentRegistrationStep = RegistrationStep.providerType;
    }
    clearRegistrationFieldErrors();
    checkOthersFieldValidity(shouldUpdate: false);
    update();
  }

  void _clearCompanyFields() {
    companyNameController.clear();
    companyPhoneController.clear();
    companyEmailController.clear();
    companyIdentityNumberController.clear();
    selectedCompanyIdentityType = '';
    _profileImageFile = null;
    _selectedCompanyIdentityImageList.clear();
    _isLogoValid = true;
    _isCompanyIdentityTypeValid = true;
    _isCompanyIdentityImageValid = true;
  }

  void goToPreviousRegistrationStep() {
    final index = registrationSteps.indexOf(currentRegistrationStep);
    if (index > 0) {
      clearRegistrationFieldErrors();
      currentRegistrationStep = registrationSteps[index - 1];
      update();
    } else {
      Get.back();
    }
  }

  bool _needsPostRegistrationVerification(ConfigContent? config, SignUpBody signUpBody) {
    if (config == null) return false;
    final phoneRequired = config.phoneVerification == 1 && !phoneVerifiedForRegistration;
    final emailRequired = config.emailVerification == 1 &&
        (signUpBody.contactPersonEmail?.trim().isNotEmpty ?? false);
    return phoneRequired || emailRequired;
  }

  Future<void> registration(SignUpBody signUpBody) async {
    _isLoading = true;
    update();

    Response? response = await authRepo.registration(
      signUpBody: signUpBody,
      identityImage: identityImagesForSubmit,
      companyIdentityImage: isCompanyProvider ? _selectedCompanyIdentityImageList : [],
      logoImage: isCompanyProvider ? _profileImageFile : null,
      contactPersonPhoto: _contactPersonPhotoFile,
    );

    if (response!.statusCode == 200 && response.body['response_code'] == 'provider_store_200') {
      await authRepo.clearRegistrationSession();
      final phone = signUpBody.contactPersonPhone?.trim() ?? '';
      resetAllValue(shouldUpdate: false);
      _isLoading = false;
      update();

      if (phone.isNotEmpty) {
        await Get.find<AuthController>().login(phone, phone, 'phone');
        return;
      }

      var config = Get.find<SplashController>().configModel.content;
      if (_needsPostRegistrationVerification(config, signUpBody)) {
        final phoneVerificationRequired = config?.phoneVerification == 1 && !phoneVerifiedForRegistration;
        String identity = phoneVerificationRequired
            ? signUpBody.contactPersonPhone!.trim()
            : (signUpBody.contactPersonEmail ?? '').trim();
        String identityType = phoneVerificationRequired ? 'phone' : 'email';
        SendOtpType type = (phoneVerificationRequired && config?.firebaseOtpVerification == 1)
            ? SendOtpType.firebase
            : SendOtpType.verification;

        await Get.find<AuthController>().sendVerificationCode(
          identity: identity,
          identityType: identityType,
          type: type,
          fromPage: 'verification',
        ).then((status) {
          if (status != null) {
            if (status.isSuccess!) {
              Get.toNamed(RouteHelper.getVerificationRoute(
                identity: identity,
                identityType: identityType,
                fromPage: 'verification',
                firebaseSession: type == SendOtpType.firebase ? status.message : null,
                showSignUpDialog: true,
              ));
            } else {
              Get.offNamed(RouteHelper.signIn);
              showCustomSnackBar(trLabel(status.message?.toString()));
            }
            resetAllValue();
            _isLoading = false;
            update();
          }
        });
      } else {
        resetAllValue();
        Get.offNamed(RouteHelper.signIn);
        showCustomBottomSheet(child: const WelcomeBottomSheet(fromSignup: true));
        _isLoading = false;
        update();
      }
    } else if (response.statusCode == 400 && response.body['response_code'] == 'default_400') {
      showCustomSnackBar(localizeMessage(response.body['errors'][0]['message']?.toString()));
      _isLoading = false;
      update();
    } else {
      ApiChecker.checkApi(response);
      _isLoading = false;
      update();
    }
  }

  Future<void> getZoneList() async {
    Response? response = await authRepo.getZoneTree(forRegistration: true);
    zoneList = [];
    _zoneNodesById.clear();
    _zoneParentIdById.clear();
    if (response != null && response.statusCode == 200) {
      final content = response.body['content'];
      final nodes = content is Map ? content['nodes'] : null;
      if (nodes is List) {
        for (final element in nodes) {
          final node = ZoneTreeNode.fromJson(Map<String, dynamic>.from(element as Map));
          _indexZoneTreeNode(node, parentId: null);
          _appendZoneDropdownOptions(node, depth: 0);
        }
      }
      _pruneSelectedZonesToAvailableCatalog();
      _syncSelectedZonesFromIds();
    }
    update();
  }

  void _pruneSelectedZonesToAvailableCatalog() {
    final available = zoneList.map((z) => z.id).whereType<String>().toSet();
    selectedZoneIds = selectedZoneIds.where(available.contains).toList();
    if (selectedZoneIds.isEmpty) {
      registrationCategories = [];
      registrationSubCategories = [];
    }
  }

  void _indexZoneTreeNode(ZoneTreeNode node, {required String? parentId}) {
    if (node.id.isNotEmpty) {
      _zoneNodesById[node.id] = node;
      _zoneParentIdById[node.id] = parentId;
    }
    for (final child in node.children) {
      _indexZoneTreeNode(child, parentId: node.id.isNotEmpty ? node.id : parentId);
    }
  }

  void _appendZoneDropdownOptions(ZoneTreeNode node, {required int depth}) {
    zoneList.add(ZoneData(
      id: node.id,
      name: node.name,
      description: node.description,
      depth: depth,
      isParent: node.isParent,
    ));
    for (final child in node.children) {
      _appendZoneDropdownOptions(child, depth: depth + 1);
    }
  }

  void pickProfileImage(bool isRemove) async {
    if (isRemove) {
      _profileImageFile = null;
    } else {
      _profileImageFile = await ImagePickCropHelper.pickCropAndValidate();
    }
    _syncProceedFlagsForCurrentStep();
    update();
  }

  void pickContactPersonPhoto(bool isRemove) async {
    if (isRemove) {
      _contactPersonPhotoFile = null;
    } else {
      _contactPersonPhotoFile = await ImagePickCropHelper.pickCropAndValidate();
      if (_contactPersonPhotoFile != null) {
        checkOthersFieldValidity(shouldUpdate: false, step1: true);
      }
    }
    update();
  }

  Future<void> pickIdentityImageFront(bool isRemove) async {
    if (isRemove) {
      _identityImageFront = null;
    } else {
      _identityImageFront = await ImagePickCropHelper.pickCropAndValidate(lockAspectRatio: false);
    }
    checkOthersFieldValidity(step2: true);
    update();
  }

  Future<void> pickIdentityImageBack(bool isRemove) async {
    if (isRemove) {
      _identityImageBack = null;
    } else {
      _identityImageBack = await ImagePickCropHelper.pickCropAndValidate(lockAspectRatio: false);
    }
    checkOthersFieldValidity(step2: true);
    update();
  }

  void pickCompanyIdentityImage(bool isRemove, {int? index}) async {
    if (isRemove) {
      _selectedCompanyIdentityImageList.clear();
      if (index != null && index < draftCompanyIdentityImageUrls.length) {
        draftCompanyIdentityImageUrls.removeAt(index);
      } else {
        draftCompanyIdentityImageUrls.clear();
      }
    } else {
      XFile? pickedImage = await ImagePickCropHelper.pickCropAndValidate(
        lockAspectRatio: false,
        maxSizeInBytes: AppConstants.registrationCompanyIdentityMaxBytes,
      );
      if (pickedImage != null) {
        _selectedCompanyIdentityImageList
          ..clear()
          ..add(MultipartBody('company_identity_image', pickedImage));
        draftCompanyIdentityImageUrls.clear();
      }
    }
    _syncProceedFlagsForCurrentStep();
    update();
  }

  void resetAllValue({bool shouldUpdate = true}) {
    companyNameController.clear();
    companyPhoneController.clear();
    companyEmailController.clear();
    contactPersonNameController.clear();
    contactPersonPhoneController.clear();
    contactPersonEmailController.clear();
    identityNumberController.clear();
    companyIdentityNumberController.clear();
    companyAddressController.clear();
    streetController.clear();
    cityController.clear();
    stateController.clear();
    pincodeController.clear();
    selectedCategoryIds = [];
    selectedSubCategoryIds = [];
    _subCategoryParentCategoryId.clear();
    registrationCategories = [];
    registrationSubCategories = [];
    registrationCategoryIndex = 0;
    currentRegistrationStep = RegistrationStep.providerType;
    showRegistrationFieldErrors = false;
    phoneVerifiedForRegistration = false;
    registrationToken = null;
    draftContactPhotoUrl = null;
    draftLogoUrl = null;
    draftIdentityFrontUrl = null;
    draftIdentityBackUrl = null;
    draftCompanyIdentityImageUrls.clear();
    verifiedRegistrationPhone = null;
    providerType = ProviderType.individual;
    _profileImageFile = null;
    _contactPersonPhotoFile = null;
    _identityImageFront = null;
    _identityImageBack = null;
    _selectedCompanyIdentityImageList.clear();
    selectedIdentityType = '';
    selectedCompanyIdentityType = '';
    selectedZoneIds = [];
    selectedBusinessPlan = null;
    selectedSubscriptionPackage = null;
    selectedSubscriptionPaymentType = null;
    _selectedDigitalPaymentMethodIndex = -1;
    if (shouldUpdate) {
      update();
    }
  }

  void updateDigitalPaymentMethodIndex(int index, {bool isUpdate = true}) {
    _selectedDigitalPaymentMethodIndex = index;
    if (isUpdate) {
      update();
    }
  }

  void updateBusinessPlanType(BusinessPlanType type, {bool shouldUpdate = true}) {
    selectedBusinessPlan = type;
    if (shouldUpdate) {
      update();
    }
  }

  void updateSubscriptionPaymentType(SubscriptionPaymentType type, {bool shouldUpdate = true}) {
    selectedSubscriptionPaymentType = type;
    if (shouldUpdate) {
      update();
    }
  }

  void updateSelectedSubscription(SubscriptionPackage? sub, {bool shouldUpdate = true}) {
    selectedSubscriptionPackage = sub;
    if (shouldUpdate) {
      update();
    }
  }

  void setIdentityType(String newIdentityType) {
    selectedIdentityType = newIdentityType;
    _isIdentityTypeValid = newIdentityType.isNotEmpty;
    update();
  }

  void setCompanyIdentityType(String newIdentityType) {
    selectedCompanyIdentityType = newIdentityType;
    _syncProceedFlagsForCurrentStep();
    update();
  }

  void setAddressControllerText(String addressText) {
    companyAddressController.text = addressText;
    update();
  }

  void checkOthersFieldValidity({
    bool shouldUpdate = true,
    bool isInitial = false,
    bool step1 = false,
    bool step2 = false,
  }) {
    if (step1) {
      if (isCompanyProvider) {
        _isLogoValid = profileImageFile != null ||
            isInitial ||
            (draftLogoUrl != null && draftLogoUrl!.isNotEmpty);
      } else {
        _isLogoValid = true;
      }
      _isContactPhotoValid = contactPersonPhotoFile != null ||
          isInitial ||
          (draftContactPhotoUrl != null && draftContactPhotoUrl!.isNotEmpty);
    } else if (step2) {
      _isZoneValid = selectedZoneIds.isNotEmpty || isInitial;
      _isIdentityTypeValid = selectedIdentityType.isNotEmpty || isInitial;
      _isIdentityImageValid = isInitial || (hasIdentityFront && hasIdentityBack);
      if (isCompanyProvider) {
        _isCompanyIdentityTypeValid = selectedCompanyIdentityType.isNotEmpty || isInitial;
        _isCompanyIdentityImageValid = _selectedCompanyIdentityImageList.isNotEmpty ||
            isInitial ||
            draftCompanyIdentityImageUrls.isNotEmpty;
      } else {
        _isCompanyIdentityTypeValid = true;
        _isCompanyIdentityImageValid = true;
      }
      _isContactPhotoValid = isInitial || hasContactPhotoForSubmit;
      _isLogoValid = isInitial || hasLogoForSubmit;
    } else {
      _isLogoValid = true;
      _isContactPhotoValid = true;
      _isZoneValid = true;
      _isIdentityTypeValid = true;
      _isIdentityImageValid = true;
      _isCompanyIdentityTypeValid = true;
      _isCompanyIdentityImageValid = true;
    }

    if (shouldUpdate) {
      update();
    }
  }

  Future<Response> checkUserCredentials(String email, String phone) async {
    _isLoading = true;
    _emailErrorText = null;
    _phoneErrorText = null;
    update();

    try {
      final Response? response = await authRepo.checkUserCredentials(email.trim(), phone.trim());

      if (response == null) {
        showCustomSnackBar('connection_to_api_server_failed'.tr, type: ToasterMessageType.error);
        return Response(statusCode: 0, statusText: 'No response');
      }

      if (response.statusCode == 200) {
        return response;
      }

      if (response.statusCode == 400 && response.body['response_code'] == 'default_400') {
        if (response.body['errors'] != null && response.body['errors'] is List) {
          for (var error in response.body['errors']) {
            final code = error['error_code']?.toString() ?? '';
            if (code == 'email' || code == 'account_email' || code == 'contact_person_email') {
              _emailErrorText = error['message'];
            }
            if (code == 'phone' || code == 'account_phone' || code == 'contact_person_phone') {
              _phoneErrorText = error['message'];
            }
          }
          if (response.body['errors'].isNotEmpty) {
            showCustomSnackBar(localizeMessage(response.body['errors'][0]['message']?.toString()), type: ToasterMessageType.error);
          }
        }
        return response;
      }

      ApiChecker.checkApi(response);
      return response;
    } finally {
      _isLoading = false;
      update();
    }
  }
}
