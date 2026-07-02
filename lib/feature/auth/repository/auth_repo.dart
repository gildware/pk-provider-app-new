import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class AuthRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  String _cachedPassword = '';

  AuthRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response?> registration({
    required SignUpBody signUpBody,
    required List<MultipartBody> identityImage,
    required List<MultipartBody> companyIdentityImage,
    XFile? logoImage,
    XFile? contactPersonPhoto,
  }) async {
    final List<MultipartBody> imageList = [
      ...identityImage,
      ...companyIdentityImage,
    ];
    if (contactPersonPhoto != null) {
      imageList.add(MultipartBody('contact_person_photo', contactPersonPhoto));
    }

    return await apiClient.postMultipartData(
      AppConstants.registerUri,
      signUpBody.toJson(),
      imageList.isEmpty ? null : imageList,
      logoImage != null ? MultipartBody('logo', logoImage) : null,
    );
  }

  Future<Response?> saveRegistrationStep({
    required String registrationToken,
    required String step,
    required Map<String, String> fields,
    List<MultipartBody> files = const [],
    XFile? logoImage,
  }) async {
    final body = <String, String>{
      'step': step,
      ...fields,
    };
    if (registrationToken.isNotEmpty) {
      body['registration_token'] = registrationToken;
    }
    return await apiClient.postMultipartData(
      AppConstants.registrationSaveStepUri,
      body,
      files.isEmpty ? null : files,
      logoImage != null ? MultipartBody('logo', logoImage) : null,
    );
  }

  Future<void> persistRegistrationSession({required String token, required String phone}) async {
    await sharedPreferences.setString(AppConstants.registrationTokenKey, token);
    await sharedPreferences.setString(AppConstants.registrationPhoneKey, phone);
  }

  String? getRegistrationToken() => sharedPreferences.getString(AppConstants.registrationTokenKey);

  String? getRegistrationPhone() => sharedPreferences.getString(AppConstants.registrationPhoneKey);

  Future<void> clearRegistrationSession() async {
    await sharedPreferences.remove(AppConstants.registrationTokenKey);
    await sharedPreferences.remove(AppConstants.registrationPhoneKey);
  }

  Future<Response?> fetchRegistrationDraft(String registrationToken) async {
    return await apiClient.getData('${AppConstants.registrationDraftUri}?registration_token=$registrationToken');
  }

  Future<Response?> login({required String emailOrPassword, required String password, required String type}) async {
    return await apiClient.postData(AppConstants.loginUri, {"email_or_phone": emailOrPassword, "password": password, "type": type});
  }

  Future<Response> sendProviderLoginOtp(String phone) async {
    return await apiClient.postData(AppConstants.providerSendLoginOtpUri, {"phone": phone});
  }

  Future<Response> verifyProviderLoginOtp({required String phone, required String otp}) async {
    return await apiClient.postData(AppConstants.providerLoginOtpVerifyUri, {"phone": phone, "otp": otp});
  }

  Future<Response?> checkUserCredentials(String email, String phone) async {
    return await apiClient.postData(AppConstants.checkAuthCredentials, {
      "account_email": email,
      "account_phone": phone,
    });
  }

  Future<Response> deleteUser() async {
    return await apiClient.deleteData(AppConstants.providerRemove);
  }


  Future<Response> sendOtpForVerificationScreen(String identity, String type) async {
    return await apiClient.postData(AppConstants.sendOtpForVerification, {
      "identity": identity,
      "identity_type": type,
      "check_user": "1"
    });
  }

  Future<Response> verifyOtpForFirebaseOtpLogin({String? session, String? phone, String? code }) async {
    return await apiClient.postData(AppConstants.firebaseOtpVerify,
      {
        "sessionInfo": session,
        'phoneNumber': phone,
        'code': code,
        "user_type" : "provider-admin"
      },
    );
  }

  Future<Response> sendOtpForForgetPassword(String identity, String identityType) async {
    return await apiClient.postData(AppConstants.sendOtpForForgetPassword,
      {
        "identity": identity,
        "identity_type": identityType
      },

    );
  }

  Future<Response?> verifyOtpForVerificationScreen(String? identity,String identityType, String otp) async {
    return await apiClient.postData(AppConstants.verifyOtpForVerificationScreen,
        {
          "identity": identity,
          'otp':otp,
          "identity_type": identityType,
        },
    );
  }

  Future<Response> verifyOtpForForgetPassword(String identity, String identityType, String otp) async {
    return await apiClient.postData(AppConstants.verifyOtpForForgetPasswordScreen,
      {
        "identity": identity,
        'otp':otp,
        "identity_type": identityType
      },
    );
  }

  Future<Response?> resetPassword(String identity, String identityType, String otp, String password, String confirmPassword,  int isFirebaseOtp) async {
    return await apiClient.putData(
      AppConstants.resetPasswordUri,
      {
        "_method": "put",
        "identity": identity,
        "identity_type": identityType,
        "otp": otp,
        "password": password,
        "confirm_password": confirmPassword,
        "is_firebase_otp": isFirebaseOtp
      },
    );
  }

  String? _providerZoneId() {
    if (!Get.isRegistered<UserProfileController>()) return null;
    final zoneId = Get.find<UserProfileController>().myZoneId?.trim();
    if (zoneId == null || zoneId.isEmpty) return null;
    return zoneId;
  }

  void _subscribeProviderTopics() {
    FirebaseMessaging.instance.subscribeToTopic(AppConstants.topic);
    final zoneId = _providerZoneId();
    if (zoneId != null) {
      FirebaseMessaging.instance.subscribeToTopic('${AppConstants.topic}-$zoneId');
    }
  }

  void _unsubscribeProviderTopics() {
    FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.topic);
    final zoneId = _providerZoneId();
    if (zoneId != null) {
      FirebaseMessaging.instance.unsubscribeFromTopic('${AppConstants.topic}-$zoneId');
    }
  }

  String _pushPlatform() {
    if (GetPlatform.isWeb) return 'web';
    if (GetPlatform.isIOS) return 'ios';
    return 'android';
  }

  Future<Response?> _sendFcmTokenPayload({
    required String? fcmToken,
    bool unregister = false,
  }) async {
    final deviceId = await DeviceIdStorage.getOrCreate(sharedPreferences);
    final deviceMeta = unregister ? <String, String?>{} : await PushDeviceInfo.collect();

    return await apiClient.postData(AppConstants.tokenUrl, {
      "_method": "put",
      "fcm_token": fcmToken,
      "device_id": deviceId,
      "platform": deviceMeta['platform'] ?? _pushPlatform(),
      if (!unregister && deviceMeta['device_model'] != null) "device_model": deviceMeta['device_model'],
      if (!unregister && deviceMeta['device_manufacturer'] != null) "device_manufacturer": deviceMeta['device_manufacturer'],
      if (!unregister && deviceMeta['os_version'] != null) "os_version": deviceMeta['os_version'],
      if (unregister) "unregister": true,
    });
  }

  Future<Response?> updateToken() async {

    String? deviceToken;
    if (GetPlatform.isIOS) {
      await NotificationHelper.setIosForegroundBannerEnabled(true);
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true, announcement: false, badge: true, carPlay: false,
        criticalAlert: false, provisional: false, sound: true,
      );
      if(settings.authorizationStatus == AuthorizationStatus.authorized) {
        deviceToken = await _saveDeviceToken();
      }
    }else {
      deviceToken = await _saveDeviceToken();
    }

    if (!GetPlatform.isWeb) {
      _subscribeProviderTopics();
    }
    return await _sendFcmTokenPayload(fcmToken: deviceToken);
  }

  Future<String?> _saveDeviceToken() async {
    String? deviceToken = '@';
    if(!GetPlatform.isWeb) {
      try {
        deviceToken = await FirebaseMessaging.instance.getToken();
      }catch(e) {
        if (kDebugMode) {
          print('token error : $e');
        }
      }
    }
    if (deviceToken != null) {
      if (kDebugMode) {
        print('--------Device Token---------- $deviceToken');
      }
    }
    return deviceToken;
  }

  Future<void> unsubscribeToken() async {
    if (!GetPlatform.isWeb) {
      _unsubscribeProviderTopics();
    }
    await _sendFcmTokenPayload(fcmToken: '@', unregister: true);
  }


  Future<bool?> saveUserToken(String token) async {
    apiClient.token = token;
    apiClient.updateHeader(token, sharedPreferences.getString(AppConstants.languageCode));
    await SecureTokenStorage.writeToken(token);
    return true;
  }

  String getUserToken() {
    return SecureTokenStorage.cachedToken();
  }

  bool isLoggedIn() {
    return SecureTokenStorage.cachedToken().isNotEmpty;
  }

  Future<bool> clearSharedData({bool skipFcmUnregister = false}) async {
    if (!skipFcmUnregister && isLoggedIn()) {
      await unsubscribeToken();
    } else if (!skipFcmUnregister && !GetPlatform.isWeb) {
      _unsubscribeProviderTopics();
    }
    SecureTokenStorage.evictToken();
    sharedPreferences.remove(AppConstants.token);
    sharedPreferences.remove(AppConstants.userAddress);
    apiClient.token = null;
    apiClient.updateHeader(null, null);
    return true;
  }
  Future<void> preloadRememberMeCredentials() async {
    await _migrateLegacyPassword();
    _cachedPassword = await SecureCredentialStorage.readPassword();
  }

  Future<void> _migrateLegacyPassword() async {
    final legacy = sharedPreferences.getString(AppConstants.userPassword);
    if (legacy != null && legacy.isNotEmpty) {
      await SecureCredentialStorage.writePassword(legacy);
      await sharedPreferences.remove(AppConstants.userPassword);
    }
  }

  Future<void> saveUserNumberAndPassword(String number, String password) async {
    try {
      await sharedPreferences.setString(AppConstants.userNumber, number);
      if (password.isNotEmpty) {
        await SecureCredentialStorage.writePassword(password);
        _cachedPassword = password;
      } else {
        await SecureCredentialStorage.deletePassword();
        _cachedPassword = '';
      }
    } catch (e) {
      rethrow;
    }
  }

  void toggleNotificationSound(bool isNotification){
    sharedPreferences.setBool(AppConstants.notification, isNotification);
  }

  bool isNotificationActive() {
    return sharedPreferences.getBool(AppConstants.notification) ?? true;
  }

  Future<bool> clearUserNumberAndPassword() async {
    await SecureCredentialStorage.deletePassword();
    _cachedPassword = '';
    return await sharedPreferences.remove(AppConstants.userNumber);
  }

  Future<Response?> getZonesDataList() async {
    return await apiClient.getData('${AppConstants.zoneUrl}?limit=200&offset=1');
  }

  Future<Response?> getZoneTree({bool forRegistration = false}) async {
    final suffix = forRegistration ? '?for_registration=1' : '';
    return await apiClient.getData('${AppConstants.zoneTreeUrl}$suffix');
  }

  String _zoneIdsQuery(List<String> zoneIds) {
    if (zoneIds.isEmpty) return '';
    return zoneIds.map((id) => 'zone_ids[]=${Uri.encodeComponent(id)}').join('&');
  }

  Future<Response?> getRegistrationCategories(List<String> zoneIds) async {
    final zones = _zoneIdsQuery(zoneIds);
    final query = zones.isEmpty ? '' : '&$zones';
    return await apiClient.getData('${AppConstants.registrationCategoriesUrl}?limit=100&offset=1$query');
  }

  Future<Response?> getRegistrationSubCategories({
    required String categoryId,
    required List<String> zoneIds,
    int offset = 1,
  }) async {
    final zones = _zoneIdsQuery(zoneIds);
    final query = zones.isEmpty ? '' : '&$zones';
    return await apiClient.getData(
      '${AppConstants.registrationSubCategoriesUrl}?limit=50&offset=$offset&category_id=$categoryId$query',
    );
  }

  String getUserNumber() {
    return sharedPreferences.getString(AppConstants.userNumber) ?? "";
  }

  String getUserPassword() {
    return _cachedPassword;
  }

  void setRememberMeValue(bool rememberMeValue) {
    sharedPreferences.setBool(AppConstants.isRememberActive, rememberMeValue);
  }
  bool? getRememberMeValue() {
    return sharedPreferences.getBool(AppConstants.isRememberActive);
  }
}
