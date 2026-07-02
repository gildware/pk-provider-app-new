import 'package:demandium_provider/common/repo/provider_cache_repo.dart';
import 'package:demandium_provider/feature/dashboard/helper/dashboard_bundle_helper.dart';
import 'package:demandium_provider/helper/error_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;
  AuthController({required this.authRepo});

  bool? _isLoading = false;
  final bool _notification = true;

  bool _isNumberLogin = false;
  bool get isNumberLogin => _isNumberLogin;

  bool? get isLoading => _isLoading;
  bool? get notification => _notification;

  bool? _isActiveRememberMe =false ;
  bool? get isActiveRememberMe => _isActiveRememberMe;

  String _verificationCode = '';
  String get verificationCode => _verificationCode;

  bool _isWrongOtpSubmitted = false;
  bool get isWrongOtpSubmitted => _isWrongOtpSubmitted;

  LoginMedium _selectedLoginMedium = LoginMedium.manual;
  LoginMedium get selectedLoginMedium => _selectedLoginMedium;

  var countryDialCode= "+880";

  Future<void> login(String emailOrPhone, String password, String type) async {
    _isLoading = true;
    update();
    Response? response = await authRepo.login(emailOrPassword: emailOrPhone, password: password, type: type);
    if (response!.statusCode == 200  && response.body['response_code']=='auth_login_200'){
      if (isActiveRememberMe!) {
        authRepo.saveUserNumberAndPassword(emailOrPhone, password);
      } else {
        authRepo.clearUserNumberAndPassword();
      }
      authRepo.saveUserToken(response.body['content']["token"]);
      _isLoading = false;
      update();
      Get.offAllNamed(RouteHelper.initial);
      _completeProviderLogin();
    }
    else if((response.body['response_code']=='unverified_email_401' || response.body['response_code']=='unverified_phone_401') && response.statusCode==401){

      var config = Get.find<SplashController>().configModel.content;
      SendOtpType sendOtpType = (type == "phone" && config?.firebaseOtpVerification == 1) ? SendOtpType.firebase : SendOtpType.verification;

      if(config?.firebaseOtpVerification == 1 || config?.phoneVerification == 1){
        await Get.find<AuthController>().sendVerificationCode(identity:  emailOrPhone , identityType: type, type: sendOtpType, fromPage: "verification").then((status){
          if(status !=null){
            if(status.isSuccess!){
              Get.toNamed(RouteHelper.getVerificationRoute(
                identity: emailOrPhone,identityType: type,
                fromPage: "verification",
                firebaseSession: sendOtpType == SendOtpType.firebase ? status.message : null,
              ));
            }else{
              showCustomSnackBar(trLabel(status.message?.toString()));
            }
            _isLoading = false;
            update();
          }
        });
      }else{
        showCustomSnackBar(
          'otp_configuration_is_missing_contact'.tr
        );
      }

    }
    else if(response.statusCode == 401 && response.body['response_code'] == "account_disabled_401"){
      showCustomSnackBar(
        icon:Images.userBlock,
        toasterTitle: 'account_blocked_notice'.tr ,
        trLabel(response.body['response_code']?.toString(), fallback: response.body['message']?.toString() ?? response.statusText),
      );
      _isLoading = false;
      update();
    }
    else{
      showCustomSnackBar(
        trLabel(response.body['response_code']?.toString(), fallback: response.body['message']?.toString() ?? response.statusText),
      );
      _isLoading = false;
      update();
    }

  }

  Future<ResponseModel?> sendVerificationCode({required String identity, required String identityType,required  SendOtpType type, required String fromPage , bool resendOtp = false}) async {
    ResponseModel? responseModel;
    if(type == SendOtpType.firebase){
       await _sendOtpForFirebaseVerification(identity: identity, identityType:  identityType, resendOtp: resendOtp, fromPage: fromPage);
    } else if(type == SendOtpType.verification){
      responseModel = await _sendOtpForVerificationScreen(identity, identityType);
    }else{
      responseModel = await _sendOtpForForgetPassword(identity, identityType);
    }
    return responseModel;
  }

  Future<ResponseModel> _sendOtpForVerificationScreen(String identity, String identityType) async {
    _isLoading = true;
    update();
    Response  response = await authRepo.sendOtpForVerificationScreen(identity,identityType);
    if (response.statusCode == 200 && response.body["response_code"]=="default_200") {
      _isLoading = false;
      update();
      return ResponseModel(true, "");
    } else {
      _isLoading = false;
      update();

      return ResponseModel(
        false,
        ApiErrorHelper.extractMessage(response) ?? 'connection_to_api_server_failed'.tr,
      );
    }
  }


  Future<ResponseModel> _sendOtpForForgetPassword(String identity, String identityType) async {
    _isLoading = true;
    update();
    Response response = await authRepo.sendOtpForForgetPassword(identity,identityType);

    if (response.statusCode == 200 && response.body["response_code"]=="default_200") {
      _isLoading = false;
      update();
      return ResponseModel(true, "");
    } else {

      _isLoading = false;
      update();

      return ResponseModel(
        false,
        ApiErrorHelper.extractMessage(response) ?? 'connection_to_api_server_failed'.tr,
      );
    }
  }

  Future<void> _sendOtpForFirebaseVerification({required String identity, required  String identityType,  required String fromPage , required bool resendOtp}) async {
    _isLoading = true;
    update();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: identity,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        _isLoading = false;
        update();

        if(e.code == 'invalid-phone-number') {
         showCustomSnackBar('please_submit_a_valid_phone_number',type : ToasterMessageType.info);

        }else{
          showCustomSnackBar(trLabel(e.message?.toString()));
        }

      },
      codeSent: (String vId, int? resendToken) {
        _isLoading = false;
        update();
        if(!resendOtp) {
          Get.toNamed(RouteHelper.getVerificationRoute(identity:identity, identityType : identityType, fromPage: fromPage, firebaseSession: vId));
        }

      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

  }


  Future<ResponseModel>  verifyOtpForVerificationScreen(String identity,  String identityType, String otp,) async {
    _isLoading = true;
    update();
    Response? response = await authRepo.verifyOtpForVerificationScreen(identity,identityType,otp);
    ResponseModel responseModel;
    if (response!.statusCode == 200 && response.body['response_code']=="default_200") {
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
     responseModel = _checkWrongOtp(response);
    }
    _isLoading = false;
    update();
    return responseModel;
  }


  Future<ResponseModel> verifyOtpForForgetPasswordScreen(String identity, String identityType, String otp) async {
    _isLoading = true;
    update();
    Response response = await authRepo.verifyOtpForForgetPassword(identity, identityType, otp);

    ResponseModel responseModel;
    if (response.statusCode==200 &&  response.body['response_code'] == 'default_200') {
      _isLoading = false;
      update();
      responseModel = ResponseModel(true, "successfully_verified");
    }else{
      responseModel = _checkWrongOtp(response);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> sendProviderLoginOtp(String phone) async {
    _isLoading = true;
    update();
    ResponseModel responseModel;
    try {
      final response = await authRepo.sendProviderLoginOtp(phone);
      final body = response.body;
      if (response.statusCode == 200 && body is Map && body['response_code'] == 'default_200') {
        responseModel = ResponseModel(true, '');
      } else {
        final responseCode = body is Map ? body['response_code']?.toString() : null;
        final message = body is Map ? body['message']?.toString() : null;
        final responseText = ApiErrorHelper.extractMessage(response) ??
            trLabel(responseCode, fallback: message ?? response.statusText);
        responseModel = ResponseModel(false, responseText);
      }
    } catch (e, stack) {
      ErrorLogger.record(e, stack, reason: 'AuthController.sendProviderLoginOtp');
      responseModel = ResponseModel(false, 'connection_to_api_server_failed'.tr);
    } finally {
      _isLoading = false;
      update();
    }
    return responseModel;
  }

  Future<ResponseModel> verifyOtpForProviderLogin({required String phone, required String otp}) async {
    _isLoading = true;
    update();
    ResponseModel responseModel;
    try {
      final response = await authRepo.verifyProviderLoginOtp(phone: phone, otp: otp);
      if (response.statusCode == 200 && response.body['response_code'] == 'auth_login_200') {
        authRepo.saveUserToken(response.body['content']['token']);
        responseModel = ResponseModel(true, 'successfully_logged_in'.tr);
        _isLoading = false;
        update();
        Get.offAllNamed(RouteHelper.initial);
        _completeProviderLogin();
        return responseModel;
      }
      if (response.statusCode == 200 && response.body['response_code'] == 'provider_onboarding_200') {
        final content = response.body['content'];
        final verifiedPhone = content is Map ? (content['phone']?.toString() ?? phone) : phone;
        final token = content is Map ? content['registration_token']?.toString() : null;
        if (token != null && token.isNotEmpty) {
          await authRepo.persistRegistrationSession(token: token, phone: verifiedPhone);
        }
        final draft = content is Map ? content['draft'] : null;
        Get.offAllNamed(
          RouteHelper.signUp,
          parameters: {
            'verified_phone': verifiedPhone,
            if (token != null && token.isNotEmpty) 'registration_token': token,
          },
          arguments: draft is Map ? {'draft': draft, 'verified_phone': verifiedPhone} : {'verified_phone': verifiedPhone},
        );
        responseModel = ResponseModel(true, '');
      } else {
        responseModel = _checkWrongOtp(response);
      }
    } catch (e, stack) {
      ErrorLogger.record(e, stack, reason: 'AuthController.verifyOtpForProviderLogin');
      responseModel = ResponseModel(false, 'verification_failed'.tr);
    } finally {
      _isLoading = false;
      update();
    }
    return responseModel;
  }

  void toggleSelectedLoginMedium({required LoginMedium loginMedium, bool isUpdate = true}) {
    _selectedLoginMedium = loginMedium;
    if (isUpdate) {
      update();
    }
  }

  Future<ResponseModel>  verifyOtpForFirebaseOtp({String? session, String? phone, String? code }) async {
    _isLoading = true;
    update();
    Response response = await authRepo.verifyOtpForFirebaseOtpLogin(session: session, phone: phone, code: code);
    ResponseModel responseModel;
    if (response.statusCode == 200) {

      responseModel =  ResponseModel(true, "successfully_verified");
    } else {
      responseModel = _checkWrongOtp(response);
    }
    _isLoading = false;
    update();
    return responseModel;
  }


  Future<void> resetPassword(String identity,String identityType, String otp, String password, String confirmPassword,  int isFirebaseOtp) async {
    _isLoading = true;
    update();
    Response? response = await authRepo.resetPassword(identity,identityType, otp, password, confirmPassword, isFirebaseOtp);

    if (response!.statusCode == 200 && response.body['response_code']=="default_password_reset_200") {
      Get.offNamed(RouteHelper.signIn);
      showCustomSnackBar('password_changed_successfully'.tr, type: ToasterMessageType.success);
    } else {
      showCustomSnackBar(response.statusText);
    }
    _isLoading = false;
    update();
  }

  Future removeUser() async {
    _isLoading = true;
    update();
    Response response = await authRepo.deleteUser();
    _isLoading = false;
    if(response.statusCode == 200){
      showCustomSnackBar('your_account_remove_successfully'.tr,  type: ToasterMessageType.success);
      await clearSharedData();
      Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
    }else{
      Get.back();
      ApiChecker.checkApi(response);
    }
  }

  void toggleIsNumberLogin ({bool? value, bool isUpdate = true}){
    if(value == null){
      _isNumberLogin = !_isNumberLogin;
    }else{
      _isNumberLogin = value;
    }
    initCountryCode();
    if(isUpdate){
      update();
    }
  }

  ResponseModel _checkWrongOtp (Response response){
    if (verificationCode.length == 6 && response.statusCode == 403){
      _isWrongOtpSubmitted = true;
    }
    return ResponseModel(
      false,
      ApiErrorHelper.extractMessage(response) ?? 'verification_failed'.tr,
    );
  }




  void updateVerificationCode(String query) {
    _verificationCode = query;
    _isWrongOtpSubmitted = false;
    update();
  }

  void updateWrongVerificationCodeStatus({bool value = false, bool shouldUpdate = false}){
    _isWrongOtpSubmitted = value;
    if(shouldUpdate){
      update();
    }
  }

  bool isNotificationActive() {
    return authRepo.isNotificationActive();

  }

  void toggleNotificationSound(){
    authRepo.toggleNotificationSound(!isNotificationActive());
    update();
  }

  bool isLoggedIn() {
    return authRepo.isLoggedIn();
  }

  Future<bool> clearSharedData({bool skipFcmUnregister = false}) async {
    await _resetProviderSessionState();
    return authRepo.clearSharedData(skipFcmUnregister: skipFcmUnregister);
  }

  Future<void> _resetProviderSessionState() async {
    await Get.find<ProviderCacheRepo>().clearProviderApiCache();
    DashboardBundleHelper.reset();
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().resetOnAuthChange();
    }
    if (Get.isRegistered<BookingRequestController>()) {
      Get.find<BookingRequestController>().resetOnAuthChange();
    }
    if (Get.isRegistered<ConversationController>()) {
      Get.find<ConversationController>().resetOnAuthChange();
    }
  }

  Future<void> _completeProviderLogin() async {
    try {
      await _resetProviderSessionState();
      await Get.find<UserProfileController>().getProviderInfo();
      await authRepo.updateToken();
      Get.find<SplashController>().updateLanguage(true);
      showCustomSnackBar('successfully_logged_in'.tr, type: ToasterMessageType.success);
    } catch (e, stack) {
      ErrorLogger.record(e, stack, reason: 'AuthController._completeProviderLogin');
    }
  }

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe!;
    authRepo.setRememberMeValue(_isActiveRememberMe!);
    update();
  }

  bool? getRememberMeValue() {
    return authRepo.getRememberMeValue();
  }

  String getUserNumber() {
    return authRepo.getUserNumber();
  }

  String getUserPassword() {
    return authRepo.getUserPassword();
  }

  Future<void> updateToken() async {
    await authRepo.updateToken();
  }

  void unsubscribeToken() async {
    await authRepo.unsubscribeToken();
  }

  void initCountryCode({String? countryCode}){
    countryDialCode = countryCode ?? ConfigHelper.defaultCountryDialCode;
  }
}