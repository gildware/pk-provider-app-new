import 'dart:convert';

import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class UserRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  UserRepo(this.sharedPreferences, {required this.apiClient});

  Future<Response> getProviderInfo() async {
    return await apiClient.getData(AppConstants.providerProfileUri);
  }

  Future<Response?> getZonesDataList() async {
    return await apiClient.getData('${AppConstants.zoneUrl}?limit=200&offset=1');
  }

  Future<Response?> getZoneTree({bool forRegistration = true}) async {
    final suffix = forRegistration ? '?for_registration=1' : '';
    return await apiClient.getData('${AppConstants.zoneTreeUrl}$suffix');
  }

  Future<Response?> verifyContactForUpdate({
    required String phone,
    String? email,
  }) async {
    return await apiClient.postData(AppConstants.verifyContactUpdateUri, {
      'contact_person_phone': phone,
      if (email != null && email.isNotEmpty) 'contact_person_email': email,
    });
  }

  Future<Response> sendPhoneChangeOtp(String phone) async {
    return await apiClient.postData(AppConstants.sendPhoneChangeOtpUri, {
      'contact_person_phone': phone,
    });
  }

  Future<Response> verifyPhoneChangeOtp({required String phone, required String otp}) async {
    return await apiClient.postData(AppConstants.verifyPhoneChangeOtpUri, {
      'contact_person_phone': phone,
      'otp': otp,
    });
  }

  Future<Response> updateProfile({
    required String companyName,
    required String companyPhone,
    required String companyAddress,
    String? street,
    String? city,
    String? pincode,
    required double lat,
    required double lon,
    required String companyEmail,
    required String contactPersonName,
    required String contactPersonPhone,
    required String contactPersonEmail,
    required List<String> zoneIds,
    XFile? profileImage,
    XFile? coverImages,
    XFile? contactPersonPhoto,
    List<XFile>? identityImages,
    List<String>? deletedIdentityImages,
    String? identityType,
    String? identityNumber,
    String? companyIdentityType,
    String? companyIdentityNumber,
    List<XFile>? companyIdentityImages,
    List<String>? deletedCompanyIdentityImages,
  }) async {
    final List<MultipartBody> multipartImagesImages = [];

    for (final XFile images in identityImages ?? []) {
      multipartImagesImages.add(MultipartBody('uploaded_identity_images[]', images));
    }
    for (final XFile images in companyIdentityImages ?? []) {
      multipartImagesImages.add(MultipartBody('uploaded_company_identity_images[]', images));
    }
    if (coverImages != null) {
      multipartImagesImages.add(MultipartBody('cover_image', coverImages));
    }

    final Map<String, String> data = {
      'company_name': companyName,
      'company_phone': companyPhone,
      'company_address': companyAddress,
      if (street != null) 'street': street,
      if (city != null) 'city': city,
      if (pincode != null) 'pincode': pincode,
      'company_email': companyEmail,
      'contact_person_name': contactPersonName,
      'contact_person_phone': contactPersonPhone,
      if (contactPersonEmail.isNotEmpty) 'contact_person_email': contactPersonEmail,
      'latitude': '$lat',
      'longitude': '$lon',
      if (deletedIdentityImages?.isNotEmpty ?? false)
        'deleted_identity_images': jsonEncode(deletedIdentityImages),
      if (deletedCompanyIdentityImages?.isNotEmpty ?? false)
        'deleted_company_identity_images': jsonEncode(deletedCompanyIdentityImages),
      if (identityType != null) 'identity_type': identityType,
      if (identityNumber != null) 'identity_number': identityNumber,
      if (companyIdentityType != null) 'company_identity_type': companyIdentityType,
      if (companyIdentityNumber != null) 'company_identity_number': companyIdentityNumber,
      '_method': 'put',
    };

    for (int i = 0; i < zoneIds.length; i++) {
      data['zone_ids[$i]'] = zoneIds[i];
    }

    MultipartBody? logoBody;
    if (profileImage != null) {
      logoBody = MultipartBody('logo', profileImage);
    }
    if (contactPersonPhoto != null) {
      multipartImagesImages.add(MultipartBody('contact_person_photo', contactPersonPhoto));
    }

    return await apiClient.postMultipartData(
      AppConstants.providerProfileUpdateUrl,
      data,
      multipartImagesImages,
      logoBody,
    );
  }

  Future<Response> updateBranding({
    XFile? logo,
    XFile? coverImage,
  }) async {
    final List<MultipartBody> files = [];
    MultipartBody? logoBody;

    if (logo != null) {
      logoBody = MultipartBody('logo', logo);
    }
    if (coverImage != null) {
      files.add(MultipartBody('cover_image', coverImage));
    }

    return await apiClient.postMultipartData(
      AppConstants.providerBrandingUpdateUrl,
      {'_method': 'put'},
      files.isEmpty ? null : files,
      logoBody,
    );
  }

  Future<Response> updatePasswordApi({required String password, required String confirmPassword}) async {
    return await apiClient.postData(AppConstants.updatePasswordUrl, {
      'password': password,
      'confirm_password': confirmPassword,
      '_method': 'put',
    });
  }


  Future<Response> getBookingRequestData(String requestType, int offset) async {
    return await apiClient.postData(AppConstants.bookingListUrl,
        {'limit': Get.find<SplashController>().configModel.content?.paginationLimit, 'offset': offset, 'booking_status': requestType});
  }
}
