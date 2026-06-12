import 'package:demandium_provider/feature/settings/business/controller/company_identity_controller.dart';
import 'package:demandium_provider/feature/settings/business/controller/identity_controller.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:demandium_provider/feature/profile/model/provider_model.dart';



class UserProfileController extends GetxController implements GetxService{
  final UserRepo userRepo;
  UserProfileController({required this.userRepo});

  final GlobalKey<FormState> profileInformationFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> contactPersonFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> companyInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();

  Future<void>? _zoneTreeLoadFuture;

  TextEditingController? companyNameController,companyPhoneController,companyEmailController,
      personalNameController,personalPhoneController,personalEmailController,
      companyIdentityNumberController,
      streetController, cityController, pincodeController,
      emailController, passwordController,confirmPasswordController;

  bool keepPersonalInfoAsCompanyInfo = false;

  bool _showOverflowDialog = false;
  bool get showOverflowDialog => _showOverflowDialog;

  bool _trialWidgetNotShow = false;
  bool get trialWidgetNotShow => _trialWidgetNotShow;

  String _providerId = '';
  String get providerId =>_providerId;

  var countryDialCode = "+880";

  String _selectedZoneID ='';
  String get selectedZoneID => _selectedZoneID;

  String _selectedZoneName ="";
  String get selectedZoneName => _selectedZoneName;

  String myZone='';
  String? myZoneId;
  double latitude = 0;
  double longitude= 0;

  List<ZoneData> zoneList=[];
  List<String> selectedZoneIds = [];
  final Map<String, ZoneTreeNode> _zoneNodesById = {};
  final Map<String, String?> _zoneParentIdById = {};
  bool _isZoneTreeLoading = false;
  bool get isZoneTreeLoading => _isZoneTreeLoading;

  bool _isZoneValid = true;
  bool get isZoneValid => _isZoneValid;

  bool get isCompanyProvider =>
      _providerModel?.content?.providerInfo?.isCompanyProvider ?? false;

  String _savedContactPhoneDigits = '';
  bool _contactPhoneOtpVerified = true;
  String? _phoneErrorText;
  String? get phoneErrorText => _phoneErrorText;

  String get fullContactPhone {
    final local = personalPhoneController?.text.trim() ?? '';
    if (local.isEmpty) return '';
    final withCode = ValidationHelper.getValidPhone(
      '$countryDialCode$local',
      withCountryCode: true,
    );
    return withCode.isNotEmpty ? withCode : '$countryDialCode$local';
  }

  bool get hasContactPhoneChanged {
    if (_savedContactPhoneDigits.isEmpty) return false;
    final digits = _phoneDigits(fullContactPhone);
    return digits.isNotEmpty && digits != _savedContactPhoneDigits;
  }

  bool get isContactPhoneVerified => !hasContactPhoneChanged || _contactPhoneOtpVerified;

  String _phoneDigits(String phone) => phone.replaceAll(RegExp(r'\D'), '');

  void _syncSavedContactPhoneFromProvider() {
    final raw = _providerModel?.content?.providerInfo?.contactPersonPhone ?? '';
    final normalized = ValidationHelper.getValidPhone(raw, withCountryCode: true);
    _savedContactPhoneDigits = _phoneDigits(normalized.isNotEmpty ? normalized : raw);
    _contactPhoneOtpVerified = true;
    _phoneErrorText = null;
  }

  void onContactPhoneChanged() {
    if (!hasContactPhoneChanged) {
      _contactPhoneOtpVerified = true;
    } else {
      _contactPhoneOtpVerified = false;
    }
    _phoneErrorText = null;
    update();
  }

  void markContactPhoneVerified(String phone) {
    _contactPhoneOtpVerified = true;
    _savedContactPhoneDigits = _phoneDigits(phone);
    _phoneErrorText = null;
    update();
  }

  Future<ResponseModel> startContactPhoneVerification() async {
    final phone = fullContactPhone;
    if (phone.isEmpty || FormValidationHelper().isValidPhone(phone) != null) {
      return ResponseModel(false, trLabel('phone_number_hint'));
    }

    _isLoading = true;
    _phoneErrorText = null;
    update();

    try {
      final email = personalEmailController?.text.trim() ?? '';
      final cred = await userRepo.verifyContactForUpdate(phone: phone, email: email);
      if (cred == null || cred.statusCode != 200) {
        _applyContactVerifyErrors(cred);
        return ResponseModel(false, _phoneErrorText ?? trLabel('phone_number_hint'));
      }

      final otpResponse = await userRepo.sendPhoneChangeOtp(phone);
      if (otpResponse.statusCode == 200 && otpResponse.body['response_code'] == 'default_200') {
        return ResponseModel(true, phone);
      }

      final message = _extractApiErrorMessage(otpResponse) ??
          otpResponse.body['message']?.toString() ??
          trLabel('internal_server_error');
      return ResponseModel(false, message);
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<ResponseModel> verifyContactPhoneOtp(String phone, String otp) async {
    _isLoading = true;
    update();
    try {
      final response = await userRepo.verifyPhoneChangeOtp(phone: phone, otp: otp);
      if (response.statusCode == 200 && response.body['response_code'] == 'default_200') {
        markContactPhoneVerified(phone);
        return ResponseModel(true, trLabel('phone_number_verified'));
      }
      return ResponseModel(
        false,
        _extractApiErrorMessage(response) ?? response.statusText ?? trLabel('wrong_otp'),
      );
    } finally {
      _isLoading = false;
      update();
    }
  }

  void _applyContactVerifyErrors(Response? response) {
    _phoneErrorText = null;
    if (response?.body is! Map) return;
    final errors = response!.body['errors'];
    if (errors is! List) return;
    for (final error in errors) {
      if (error is! Map) continue;
      final code = error['error_code']?.toString() ?? '';
      if (code == 'phone' ||
          code == 'account_phone' ||
          code == 'contact_person_phone') {
        _phoneErrorText = error['message']?.toString();
      }
    }
    if (_phoneErrorText != null) {
      showCustomSnackBar(_phoneErrorText!);
    }
  }

  String? _extractApiErrorMessage(dynamic response) {
    if (response is! Response || response.body is! Map) return null;
    final body = Map<String, dynamic>.from(response.body as Map);
    if (body['errors'] is List && (body['errors'] as List).isNotEmpty) {
      final first = (body['errors'] as List).first;
      if (first is Map && first['message'] != null) {
        return first['message'].toString();
      }
    }
    return body['message']?.toString();
  }

  int _totalCompleteRequest= 0;
  int _totalCanceledRequest= 0;
  int _totalOngoingRequest= 0;
  int _totalAcceptedRequest= 0;

  int get totalCompletedRequest=> _totalCompleteRequest;
  int get totalCanceledRequest=> _totalCanceledRequest;
  int get totalOngoingRequest=> _totalOngoingRequest;
  int get totalAcceptedRequest=> _totalAcceptedRequest;






  @override
  void onInit() {
    super.onInit();
    //getProviderInfo();
    companyNameController = TextEditingController();
    companyPhoneController = TextEditingController();
    companyEmailController = TextEditingController();
    companyIdentityNumberController = TextEditingController();

    personalNameController = TextEditingController();
    personalPhoneController = TextEditingController();
    personalEmailController = TextEditingController();
    streetController = TextEditingController();
    cityController = TextEditingController();
    pincodeController = TextEditingController();

    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel.content?.countryCode??"BD").dialCode!;
  }

  @override
  void onClose() {
    companyNameController!.dispose();
    companyPhoneController!.dispose();
    companyEmailController!.dispose();
    personalNameController!.dispose();
    personalPhoneController!.dispose();
    personalEmailController!.dispose();
    streetController?.dispose();
    cityController?.dispose();
    pincodeController?.dispose();

    emailController!.dispose();
    passwordController!.dispose();
    confirmPasswordController!.dispose();
  }


  void togglePersonalInfoAsCompanyInfo(){
    keepPersonalInfoAsCompanyInfo =! keepPersonalInfoAsCompanyInfo;

    if(keepPersonalInfoAsCompanyInfo){
      personalNameController!.text = companyNameController!.text;
      personalPhoneController!.text = companyPhoneController!.text;
      personalEmailController!.text = companyEmailController!.text;
    }
    else{

        personalNameController!.text = _providerModel?.content?.providerInfo?.contactPersonName??"";
        personalPhoneController!.text = ValidationHelper.getValidPhone(_providerModel?.content?.providerInfo?.contactPersonPhone ?? "");
        personalEmailController!.text= _providerModel?.content?.providerInfo?.contactPersonEmail??"";
    }
    update();
  }

   ProviderModel? _providerModel;
   XFile? _pickedFile ;
   XFile? _coverImageFile ;
   XFile? _contactPersonPhotoFile;
   String? _pendingBrandingLogoLocalPath;
   String? _pendingBrandingCoverLocalPath;
   String? _pendingBrandingLogoUrl;
   String? _pendingBrandingCoverUrl;
   bool _isLoading = false;

  ProviderModel? get providerModel => _providerModel;
  XFile? get pickedFile => _pickedFile;
  XFile? get coverImageFile => _coverImageFile;
  XFile? get contactPersonPhotoFile => _contactPersonPhotoFile;
  bool get isLoading => _isLoading;

  bool get hasContactPhotoForSubmit =>
      _contactPersonPhotoFile != null ||
      (_providerModel?.content?.providerInfo?.contactPersonPhotoFullPath?.isNotEmpty ?? false);

  List<ZoneData> get selectedZones {
    if (selectedZoneIds.isEmpty) return [];
    final byId = {for (final z in zoneList) z.id: z};
    return selectedZoneIds.map((id) => byId[id]).whereType<ZoneData>().toList();
  }

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

  bool _hasPendingProfileChanges = false;
  bool _hasPendingBrandingChanges = false;

  /// Profile/business/service updates awaiting admin approval.
  bool get hasPendingProfileChanges =>
      _hasPendingProfileChanges ||
      (_providerModel?.content?.hasPendingProfileChanges == true);

  /// Logo/cover change awaiting admin approval.
  bool get hasPendingBrandingChanges =>
      _hasPendingBrandingChanges ||
      (_providerModel?.content?.hasPendingBrandingChanges == true);

  bool get hasUnsavedBrandingChanges =>
      _pickedFile != null || _coverImageFile != null;

  bool get canSaveBranding => hasUnsavedBrandingChanges && !_isLoading;

  /// Show after submit until user picks a new logo or cover.
  bool get showBrandingSubmittedMessage =>
      hasPendingBrandingChanges && !hasUnsavedBrandingChanges;

  bool get hasBrandingLogoLocalPreview =>
      _pickedFile != null ||
      (_pendingBrandingLogoLocalPath != null &&
          _pendingBrandingLogoLocalPath!.isNotEmpty);

  bool get hasBrandingCoverLocalPreview =>
      _coverImageFile != null ||
      (_pendingBrandingCoverLocalPath != null &&
          _pendingBrandingCoverLocalPath!.isNotEmpty);

  String? get brandingLogoLocalPath =>
      _pickedFile?.path ?? _pendingBrandingLogoLocalPath;

  String? get brandingCoverLocalPath =>
      _coverImageFile?.path ?? _pendingBrandingCoverLocalPath;

  String? get brandingLogoDisplayUrl {
    if (hasBrandingLogoLocalPreview) return null;
    final pending = _resolvePendingBrandingUrl(
      _pendingBrandingLogoUrl ?? _providerModel?.content?.pendingBrandingLogoUrl,
    );
    if (hasPendingBrandingChanges && pending != null) return pending;
    return _providerModel?.content?.providerInfo?.displayLogoUrl;
  }

  String? get brandingCoverDisplayUrl {
    if (hasBrandingCoverLocalPreview) return null;
    final pending = _resolvePendingBrandingUrl(
      _pendingBrandingCoverUrl ?? _providerModel?.content?.pendingBrandingCoverUrl,
    );
    if (hasPendingBrandingChanges && pending != null) return pending;
    return _providerModel?.content?.providerInfo?.displayCoverUrl;
  }

  bool get showBrandingLogoPendingBadge =>
      hasPendingBrandingChanges &&
      ((brandingLogoLocalPath?.isNotEmpty ?? false) ||
          (brandingLogoDisplayUrl?.isNotEmpty ?? false));

  bool get showBrandingCoverPendingBadge =>
      hasPendingBrandingChanges &&
      ((brandingCoverLocalPath?.isNotEmpty ?? false) ||
          (brandingCoverDisplayUrl?.isNotEmpty ?? false));

  /// Admin review pending after self-registration (is_approved = 2).
  bool get isPendingAdminVerification =>
      _providerModel?.content?.providerInfo?.isApproved == 2;

  Future<bool> confirmProfileReviewSubmission() async {
    final result = await Get.dialog<bool>(
      ConfirmationDialog(
        icon: Images.warning,
        title: 'profile_review_warning_title',
        description: 'profile_review_warning_message',
        yesButtonText: 'yes',
        noButtonText: 'no',
        onYesPressed: () => Get.back(result: true),
      ),
      barrierDismissible: false,
    );
    return result == true;
  }

  bool get isApprovedForWork {
    final info = _providerModel?.content?.providerInfo;
    if (info == null) return false;
    return info.isApproved == 1 && (info.isActive ?? 0) == 1;
  }

  /// Blocks accepting bookings until admin approves the provider account.
  bool ensureApprovedForWork() {
    if (!isPendingAdminVerification) return true;
    showCustomSnackBar(
      trLabel('provider_pending_verification_work_blocked'),
      type: ToasterMessageType.info,
    );
    return false;
  }





  Future<bool> getProviderInfo({bool reload = false}) async {
    _isLoading = true;
    _scheduleUpdate();

    Get.find<LocationController>().setPickedLocation();


    if(_providerModel==null || reload){
      Response response = await userRepo.getProviderInfo();
      if (response.statusCode == 200) {
        _providerModel = ProviderModel.fromJson(response.body);
        _hasPendingProfileChanges = _providerModel?.content?.hasPendingProfileChanges == true;
        _hasPendingBrandingChanges = _providerModel?.content?.hasPendingBrandingChanges == true;
        _syncPendingBrandingPreviewsFromModel();
        _clearPendingBrandingPreviewsIfNotPending();

         double payablePercentage = getOverflowPercent(
           double.tryParse(_providerModel?.content?.providerInfo?.owner?.account?.accountPayable??"0")??0,
           double.tryParse(_providerModel?.content?.providerInfo?.owner?.account?.accountReceivable??"0")??0,
             Get.find<SplashController>().configModel.content?.maxCashInHandLimit ?? 0,
         );

         hideOverflowDialog(payablePercentage: payablePercentage, hideDialog: false);

        companyNameController!.text = _providerModel?.content?.providerInfo?.companyName??'';

        countryDialCode = ValidationHelper.getValidCountryCode(_providerModel?.content?.providerInfo?.companyPhone ?? "" ) != ""
            ? ValidationHelper.getValidCountryCode(_providerModel?.content?.providerInfo?.companyPhone ?? "")
            : ConfigHelper.defaultCountryDialCode;

        companyPhoneController!.text = ValidationHelper.getDisplayPhone(_providerModel?.content?.providerInfo?.companyPhone ?? "");

        companyEmailController!.text = _providerModel?.content?.providerInfo?.companyEmail??"";
        personalNameController!.text = _providerModel?.content?.providerInfo?.contactPersonName??"";
        personalPhoneController!.text = ValidationHelper.getDisplayPhone(_providerModel?.content?.providerInfo?.contactPersonPhone ?? "");
        personalEmailController!.text = _providerModel?.content?.providerInfo?.contactPersonEmail ?? '';
        emailController!.text = _providerModel?.content?.providerInfo?.owner?.email??"";
        _syncSavedContactPhoneFromProvider();
        latitude = _providerModel?.content?.providerInfo?.coordinates?.latitude?? 0;
        longitude = _providerModel?.content?.providerInfo?.coordinates?.longitude?? 0;
        _totalCompleteRequest= 0;
        _totalCanceledRequest= 0;
        _totalOngoingRequest= 0;
        _totalAcceptedRequest= 0;

        _providerId = _providerModel!.content!.providerInfo!.id!;
        myZoneId = _providerModel!.content!.providerInfo!.zoneId!;
        _selectedZoneID = myZoneId ?? '';
        _selectedZoneName = '';
        _syncSelectedZoneIdsFromProvider();
        companyIdentityNumberController!.text =
            _providerModel?.content?.providerInfo?.companyIdentityNumber ?? '';
        syncAddressFieldsFromProvider();

        syncProfileImagesFromProvider();

        await loadZoneTree(force: true);

        if(companyNameController!.text==personalNameController!.text
            && companyPhoneController!.text==personalPhoneController!.text
            &&companyEmailController!.text==personalEmailController!.text){
          keepPersonalInfoAsCompanyInfo = true;
        }else{
          keepPersonalInfoAsCompanyInfo = false;
        }

        if(_providerModel!.content!.bookingOverview!=[] && _providerModel!.content!.bookingOverview!=null){
          for (var element in _providerModel!.content!.bookingOverview!) {
            if(element.bookingStatus=='accepted'){
              _totalAcceptedRequest = element.total!;
            }else if(element.bookingStatus=="canceled"){
              _totalCanceledRequest = element.total!;
            }else if(element.bookingStatus=="completed"){
              _totalCompleteRequest = element.total!;
            }else if(element.bookingStatus=="ongoing"){
              _totalOngoingRequest = element.total!;
            }
          }
        }else{
          _totalCompleteRequest= 0;
          _totalCanceledRequest= 0;
          _totalOngoingRequest= 0;
          _totalAcceptedRequest= 0;
        }
        _isLoading= false;
        _scheduleUpdate();
      } else {
        ApiChecker.checkApi(response);
      }
    }
    _isLoading = false;
    _scheduleUpdate();

    return _providerModel != null;

  }

  Future<ResponseModel> updateProfile({
    required String address,
    required String identityNumber,
    bool validateContactIdentity = true,
    bool validateCompanyIdentity = false,
    bool requireContactPhoto = true,
  }) async {
    _isLoading = true;
    _scheduleUpdate();

    if (Get.find<LocationController>().pickAddress.address != '') {
      latitude = Get.find<LocationController>().pickPosition.latitude;
      longitude = Get.find<LocationController>().pickPosition.longitude;
    }

    final zoneIds = selectedZoneIds.isNotEmpty
        ? selectedZoneIds
        : (_selectedZoneID.isNotEmpty ? [_selectedZoneID] : <String>[]);

    if (zoneIds.isEmpty) {
      _isZoneValid = false;
      _isLoading = false;
      update();
      return ResponseModel(false, trLabel('select_at_least_one_zone'));
    }

    if (validateContactIdentity && Get.find<IdentityController>().isUploadEmpty()) {
      _isLoading = false;
      update();
      return ResponseModel(false, trLabel('please_update_identity_images'));
    }

    if (validateCompanyIdentity && isCompanyProvider) {
      final companyCtrl = Get.find<CompanyIdentityController>();
      if (companyCtrl.selectedCompanyIdentityType == null ||
          companyCtrl.selectedCompanyIdentityType!.isEmpty) {
        _isLoading = false;
        update();
        return ResponseModel(false, trLabel('select_identity_type'));
      }
      if (companyIdentityNumberController!.text.trim().isEmpty) {
        _isLoading = false;
        update();
        return ResponseModel(false, trLabel('enter_identity_number'));
      }
      if (companyCtrl.isUploadEmpty()) {
        _isLoading = false;
        update();
        return ResponseModel(false, trLabel('provide_company_identity_image'));
      }
    }

    if (requireContactPhoto && !hasContactPhotoForSubmit) {
      _isLoading = false;
      update();
      return ResponseModel(false, trLabel('provide_contact_person_photo'));
    }

    if (hasContactPhoneChanged && !_contactPhoneOtpVerified) {
      _isLoading = false;
      update();
      return ResponseModel(false, trLabel('phone_verification_required'));
    }

    final confirmed = await confirmProfileReviewSubmission();
    if (!confirmed) {
      _isLoading = false;
      update();
      return ResponseModel(false, '');
    }

    final companyIdentityCtrl = Get.isRegistered<CompanyIdentityController>()
        ? Get.find<CompanyIdentityController>()
        : null;

    var effectiveLat = latitude;
    var effectiveLon = longitude;
    if (effectiveLat == 0 && effectiveLon == 0) {
      effectiveLat = _providerModel?.content?.providerInfo?.coordinates?.latitude ?? 0;
      effectiveLon = _providerModel?.content?.providerInfo?.coordinates?.longitude ?? 0;
    }

    Response response = await userRepo.updateProfile(
      companyName: companyNameController!.text.toString(),
      companyPhone: '$countryDialCode${companyPhoneController!.text.toString()}',
      companyAddress: address,
      street: streetController?.text.trim(),
      city: cityController?.text.trim(),
      pincode: pincodeController?.text.trim(),
      lat: effectiveLat,
      lon: effectiveLon,
      companyEmail: companyEmailController!.text.toString(),
      contactPersonName: personalNameController!.text.toString(),
      contactPersonPhone: '$countryDialCode${personalPhoneController!.text.toString()}',
      contactPersonEmail: personalEmailController!.text.trim(),
      zoneIds: zoneIds,
      profileImage: null,
      contactPersonPhoto: _contactPersonPhotoFile,
      deletedIdentityImages: Get.find<IdentityController>().getDeletedImageUrls(),
      identityImages: Get.find<IdentityController>().getUploadedImageFiles(),
      coverImages: null,
      identityNumber: identityNumber,
      identityType: Get.find<IdentityController>().selectedIdentityType,
      companyIdentityType: isCompanyProvider
          ? companyIdentityCtrl?.selectedCompanyIdentityType
          : null,
      companyIdentityNumber: isCompanyProvider
          ? companyIdentityNumberController!.text.trim()
          : null,
      companyIdentityImages: isCompanyProvider
          ? companyIdentityCtrl?.getUploadedImageFiles()
          : null,
      deletedCompanyIdentityImages: isCompanyProvider
          ? companyIdentityCtrl?.getDeletedImageUrls()
          : null,
    );

    if(response.statusCode == 200){
      final content = response.body['content'];
      final submittedForReview = content is Map && content['submitted_for_review'] == true;
      if (submittedForReview) {
        _hasPendingProfileChanges = true;
      }
      await getProviderInfo(reload: true);
      _syncSavedContactPhoneFromProvider();


      if(companyNameController!.text == personalNameController!.text
          && companyPhoneController!.text == personalPhoneController!.text
          && companyEmailController!.text == personalEmailController!.text){
        keepPersonalInfoAsCompanyInfo = true;
      }else{
        keepPersonalInfoAsCompanyInfo = false;
      }
      _isLoading=false;
      update();

      final msg = submittedForReview
          ? (content['message']?.toString() ?? 'profile_changes_submitted_for_review'.tr)
          : (response.body['message']?.toString() ?? 'successfully_updated'.tr);
      return ResponseModel(true, msg);
    }
    else{
      _isLoading = false;
      update();
      try{
        return  ResponseModel(false, response.body['errors'][0]['message']);

      }catch(e){
        return ResponseModel(false, response.statusText ?? "Something went wrong");

      }
    }
  }

  Future<void> updatePassword() async {
    _isLoading = true;
    update();

    Response response = await userRepo.updatePasswordApi(password: passwordController!.text, confirmPassword: confirmPasswordController!.text);

    if(response.statusCode == 200){
      showCustomSnackBar(response.body['message'], type: ToasterMessageType.success);

    } else{
      showCustomSnackBar(response.body['errors'][0]['message']);
    }
    _isLoading = false;
    update();
  }


  Future<void> getZoneList() async {
    _selectedZoneName ='';

    if(zoneList.isEmpty){
      Response? response = await userRepo.getZonesDataList();
      if (response!.statusCode == 200)
      {
        zoneList=[];

        List<dynamic>? list = response.body['content']['data'];

        if(zoneList.isEmpty){
          for (var element in list!) {
            zoneList.add(ZoneData.fromJson(element));
          }
        }

        if(zoneList.isNotEmpty && _providerModel!=null){

          for (var element in zoneList) {
            if(element.id==_providerModel!.content!.providerInfo!.zoneId!){
              myZone = element.name!;
            }
          }
        }
      }
      else {
      }
    }else{
      if(_providerModel!=null){
        for (var element in zoneList) {
          if(element.id==_providerModel!.content!.providerInfo!.zoneId!){
            myZone = element.name!;
          }
        }
      }
    }

      update();
  }

  void setNewZoneValue(String zoneName,zoneId){
    _selectedZoneName =zoneName;
    _selectedZoneID = zoneId;
    update();
  }

  void _syncSelectedZoneIdsFromProvider() {
    final ids = _providerModel?.content?.providerInfo?.zoneIds;
    if (ids != null && ids.isNotEmpty) {
      selectedZoneIds = List<String>.from(ids);
    } else if (myZoneId != null && myZoneId!.isNotEmpty) {
      selectedZoneIds = [myZoneId!];
    }
    _isZoneValid = selectedZoneIds.isNotEmpty;
  }

  String buildFormattedAddress() {
    final parts = [
      streetController?.text.trim() ?? '',
      cityController?.text.trim() ?? '',
      pincodeController?.text.trim() ?? '',
    ].where((e) => e.isNotEmpty).toList();
    if (parts.isNotEmpty) return parts.join(', ');
    return _providerModel?.content?.providerInfo?.companyAddress?.trim() ?? '';
  }

  void syncProfileImagesFromProvider() {
    final info = _providerModel?.content?.providerInfo;
    if (info == null) return;

    if (Get.isRegistered<IdentityController>()) {
      Get.find<IdentityController>().loadFromProvider(info);
    }
    if (Get.isRegistered<CompanyIdentityController>()) {
      Get.find<CompanyIdentityController>().loadFromProvider(info);
    }
  }

  void syncAddressFieldsFromProvider() {
    final info = _providerModel?.content?.providerInfo;
    if (info == null) return;

    streetController!.text = info.street?.trim() ?? '';
    cityController!.text = info.city?.trim() ?? '';
    pincodeController!.text = info.pincode?.trim() ?? '';

    if (streetController!.text.isEmpty &&
        cityController!.text.isEmpty &&
        pincodeController!.text.isEmpty &&
        (info.companyAddress?.trim().isNotEmpty ?? false)) {
      _parseAddressPartsFromCompanyAddress(info.companyAddress!.trim());
    }
  }

  void _parseAddressPartsFromCompanyAddress(String address) {
    final parts = address.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return;
    if (parts.length >= 3) {
      pincodeController!.text = parts.last;
      cityController!.text = parts[parts.length - 2];
      streetController!.text = parts.sublist(0, parts.length - 2).join(', ');
    } else if (parts.length == 2) {
      streetController!.text = parts[0];
      cityController!.text = parts[1];
    } else {
      streetController!.text = parts[0];
    }
  }

  void syncAddressFromMap(String address) {
    if ((streetController?.text.trim().isEmpty ?? true) && address.isNotEmpty) {
      streetController?.text = address;
    }
    _scheduleUpdate();
  }

  void _resolveMyZoneNameFromTree() {
    if (myZoneId == null || myZoneId!.isEmpty) return;
    for (final zone in zoneList) {
      if (zone.id == myZoneId) {
        myZone = zone.name ?? '';
        _selectedZoneName = myZone;
        break;
      }
    }
  }

  Future<void> loadZoneTree({bool force = false}) {
    if (!force && _zoneTreeLoadFuture != null) {
      return _zoneTreeLoadFuture!;
    }
    if (!force && _zoneNodesById.isNotEmpty && zoneList.isNotEmpty) {
      _isZoneTreeLoading = false;
      return Future.value();
    }

    _zoneTreeLoadFuture = _fetchZoneTree();
    return _zoneTreeLoadFuture!.whenComplete(() => _zoneTreeLoadFuture = null);
  }

  Future<void> _fetchZoneTree() async {
    _isZoneTreeLoading = true;
    _scheduleUpdate();
    try {
      final response = await userRepo.getZoneTree(forRegistration: true);
      if (response?.statusCode == 200) {
        zoneList = [];
        _zoneNodesById.clear();
        _zoneParentIdById.clear();
        final content = response?.body['content'];
        final nodes = content is Map ? content['nodes'] : (content is List ? content : null);
        if (nodes is List) {
          for (final element in nodes) {
            if (element is! Map) continue;
            final node = ZoneTreeNode.fromJson(Map<String, dynamic>.from(element));
            _indexZoneTreeNode(node, parentId: null);
            _appendZoneDropdownOptions(node, depth: 0);
          }
        }
        _syncSelectedZoneIdsFromProvider();
        _resolveMyZoneNameFromTree();
      }
    } finally {
      _isZoneTreeLoading = false;
      _scheduleUpdate();
    }
  }

  void _scheduleUpdate() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle || phase == SchedulerPhase.postFrameCallbacks) {
      update();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (isClosed) return;
        update();
      });
    }
  }

  static void scheduleProfileDataLoad({bool reloadProvider = true}) {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final c = Get.find<UserProfileController>();
      if (reloadProvider) {
        await c.getProviderInfo(reload: true);
      } else if (c.zoneList.isEmpty) {
        await c.loadZoneTree(force: true);
      }
    });
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
    _isZoneValid = selectedZoneIds.isNotEmpty;
    update();
  }

  void removeSelectedZone(String zoneId) {
    final node = _zoneNodesById[zoneId];
    final idsToRemove = node?.collectSubtreeZoneIds().toSet() ?? {zoneId};
    selectedZoneIds.removeWhere(idsToRemove.contains);
    _isZoneValid = selectedZoneIds.isNotEmpty;
    update();
  }

  void clearSelectedZones() {
    selectedZoneIds = [];
    _isZoneValid = false;
    update();
  }

  Future<void> pickContactPersonPhoto() async {
    final file = await ImagePickCropHelper.pickCropAndValidate(
      source: ImageSource.gallery,
      lockAspectRatio: true,
      ratioX: 1,
      ratioY: 1,
    );
    if (file != null) {
      _contactPersonPhotoFile = file;
      update();
    }
  }

  Future<void> pickImage() async {
    final file = await ImagePickCropHelper.pickCropAndValidate(
      source: ImageSource.gallery,
      lockAspectRatio: true,
      ratioX: 1,
      ratioY: 1,
    );
    if (file != null) {
      _pickedFile = file;
      _pendingBrandingLogoLocalPath = null;
      _pendingBrandingLogoUrl = null;
      update();
    }
  }

  Future<void> pickCoverImage() async {
    final file = await ImagePickCropHelper.pickCropAndValidate(
      source: ImageSource.gallery,
      lockAspectRatio: true,
      ratioX: 3,
      ratioY: 1,
    );
    if (file != null) {
      _coverImageFile = file;
      _pendingBrandingCoverLocalPath = null;
      _pendingBrandingCoverUrl = null;
      update();
    }
  }

  String? _resolvePendingBrandingUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    return MobileAppIconHelper.resolveMediaUrl(raw) ?? raw;
  }

  void _syncPendingBrandingPreviewsFromModel() {
    final content = _providerModel?.content;
    if (content == null) return;
    if (content.pendingBrandingLogoUrl != null) {
      _pendingBrandingLogoUrl =
          _resolvePendingBrandingUrl(content.pendingBrandingLogoUrl);
    }
    if (content.pendingBrandingCoverUrl != null) {
      _pendingBrandingCoverUrl =
          _resolvePendingBrandingUrl(content.pendingBrandingCoverUrl);
    }
  }

  void _clearPendingBrandingPreviewsIfNotPending() {
    if (hasPendingBrandingChanges) return;
    _pendingBrandingLogoLocalPath = null;
    _pendingBrandingCoverLocalPath = null;
    _pendingBrandingLogoUrl = null;
    _pendingBrandingCoverUrl = null;
  }

  void _stashPendingBrandingPreviewsFromPicks() {
    if (_pickedFile != null) {
      _pendingBrandingLogoLocalPath = _pickedFile!.path;
    }
    if (_coverImageFile != null) {
      _pendingBrandingCoverLocalPath = _coverImageFile!.path;
    }
  }

  void _applyPendingBrandingPreviewsFromContent(Map<dynamic, dynamic> content) {
    final preview = content['pending_branding_preview'];
    if (preview is! Map) return;
    final logo = preview['logo_url']?.toString().trim() ?? '';
    final cover = preview['cover_url']?.toString().trim() ?? '';
    if (logo.isNotEmpty) {
      _pendingBrandingLogoUrl = _resolvePendingBrandingUrl(logo);
      _pendingBrandingLogoLocalPath = null;
    }
    if (cover.isNotEmpty) {
      _pendingBrandingCoverUrl = _resolvePendingBrandingUrl(cover);
      _pendingBrandingCoverLocalPath = null;
    }
  }

  Future<bool> confirmBrandingReviewSubmission() async {
    final result = await Get.dialog<bool>(
      ConfirmationDialog(
        icon: Images.warning,
        title: 'branding_review_warning_title',
        description: 'branding_review_warning_message',
        yesButtonText: 'yes',
        noButtonText: 'no',
        onYesPressed: () => Get.back(result: true),
      ),
      barrierDismissible: false,
    );
    return result == true;
  }

  Future<ResponseModel> updateBrandingImages() async {
    if (_pickedFile == null && _coverImageFile == null) {
      return ResponseModel(false, trLabel('please_update_logo_or_cover'));
    }

    final confirmed = await confirmBrandingReviewSubmission();
    if (!confirmed) {
      return ResponseModel(false, '');
    }

    _isLoading = true;
    update();

    final response = await userRepo.updateBranding(
      logo: _pickedFile,
      coverImage: _coverImageFile,
    );

    _isLoading = false;

    final responseCode = response.body?['response_code']?.toString() ?? '';
    final isSuccess = response.statusCode == 200 && responseCode == 'default_200';

    if (isSuccess) {
      final content = response.body['content'];
      final submittedForReview =
          content is Map && content['submitted_for_review'] == true;
      if (submittedForReview) {
        _hasPendingProfileChanges = true;
        _hasPendingBrandingChanges = content['has_pending_branding_changes'] == true;
      }
      _stashPendingBrandingPreviewsFromPicks();
      if (content is Map) {
        _applyPendingBrandingPreviewsFromContent(content);
      }
      _pickedFile = null;
      _coverImageFile = null;
      await getProviderInfo(reload: true);
      update();
      final msg = submittedForReview
          ? trLabel('branding_change_sent_for_approval')
          : (response.body['message']?.toString() ??
              trLabel('profile_updated_successfully'));
      return ResponseModel(true, msg);
    }

    update();
    String? errorMessage;
    try {
      final body = response.body;
      if (body is Map) {
        final errors = body['errors'];
        if (errors is List && errors.isNotEmpty) {
          final first = errors.first;
          if (first is Map && first['message'] != null) {
            errorMessage = first['message'].toString();
          }
        }
        errorMessage ??= body['message']?.toString();
      }
    } catch (_) {
      //
    }
    errorMessage ??= response.statusText ?? trLabel('something_went_wrong');
    if (errorMessage.isNotEmpty) {
      showCustomSnackBar(errorMessage, type: ToasterMessageType.error);
    }
    ApiChecker.checkApi(response);
    return ResponseModel(false, errorMessage);
  }

  void resetImage() {
    _contactPersonPhotoFile = null;
  }

  void resetBrandingPicks() {
    _pickedFile = null;
    _coverImageFile = null;
  }


  double getOverflowPercent(double payable, double receivable, double maxAmount) {
     double amount = getTransactionAmountAmount(payable, receivable);

     double percentage = (amount / maxAmount) * 100;
     return percentage;
   }

  double getTransactionAmountAmount(double payable, double receivable) {
    double amount = 0;
    if(payable > receivable){
      amount = payable - receivable;
    }else{
      amount = receivable - payable;
    }
    return amount;
  }

  TransactionType getTransactionType (double payable, double receivable){
    TransactionType type =  TransactionType.none;

    if(payable == receivable){
      if(payable == 0 || receivable == 0){
        type  = TransactionType.none;
      }else{
        type = TransactionType.adjust;
      }
    } else if(payable > receivable ){
      if(receivable > 0.0){
        type = TransactionType.adjustAndPayable;
      }else{
        type = TransactionType.payable;
      }
    }else if(receivable > payable){
      if( payable> 0.0){
        type = TransactionType.adjustWithdrawAble;
      }else{
        type = TransactionType.withdrawAble;
      }
    } else{
      type  = TransactionType.none;
    }

    return type;
  }

  int numberOfShowDialog = 0;

  void hideOverflowDialog({double? payablePercentage, bool hideDialog = true}){

    if(!hideDialog ){

      if(payablePercentage != null){
        if( !_showOverflowDialog && payablePercentage >= 80 && payablePercentage < 100 && numberOfShowDialog < 1){
          numberOfShowDialog ++;
          _showOverflowDialog = true;

        } else if(payablePercentage >= 100){
          numberOfShowDialog = 0;
          _showOverflowDialog = true;
        } else{
          // //numberOfShowDialog = 0;
          // _showOverflowDialog = false;
        }
      }

    }else{
      _showOverflowDialog = false;
      update();
    }
  }

  void updateNumberOfTimeShowingDialog(){
    numberOfShowDialog = 0;
    _showOverflowDialog = false;
  }

  bool haveAnyAcceptedAndOngoingBooking(){
    return  (_totalAcceptedRequest + _totalOngoingRequest) > 0;
  }


  void onProfileChangeValidationCheck({bool shouldUpdate = true}){
    _isZoneValid = selectedZoneIds.isNotEmpty;
    if(shouldUpdate){
      update();
    }
  }

  void clearUserProfileData(){
    _providerModel  = null;
    update();
  }


  Future<bool> trialWidgetShow({required String route}) async {
    const Set<String> routesToHideWidget = {
      '/business-plan', 'show-dialog', '/success', '/payment',
    };
    _trialWidgetNotShow = routesToHideWidget.contains(route);

    Future.delayed(const Duration(milliseconds: 500), () {
      update();
    });
    return _trialWidgetNotShow;
  }


  bool checkAvailableFeatureInSubscriptionPlan({required String featureType}){

    bool status = _providerModel?.content?.subscriptionInfo?.status == "subscription_base"
        && !_providerModel!.content!.subscriptionInfo!.subscribedPackageDetails!.featureList!.contains(featureType) ? false : true;

    if(!status){
      showCustomSnackBar('this_feature_is_not_included_in_your_current_subscription_plan'.tr);
    }
    return status;
  }



}