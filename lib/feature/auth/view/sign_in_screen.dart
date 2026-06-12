import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  const SignInScreen({super.key, required this.exitFromApp});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _passwordController = TextEditingController();
  bool _canExit = GetPlatform.isWeb ? true : false;
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();
  bool _loginModeSynced = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _requestNotificationPermission();
    Get.find<SplashController>().getConfigData();
  }

  int _otpLoginFlag(ConfigContent? config) => config?.loginSetup?.loginOption?.otpLogin ?? 0;

  int _manualLoginFlag(ConfigContent? config) {
    final loginOption = config?.loginSetup?.loginOption;
    if (loginOption == null) {
      return 1;
    }
    return loginOption.manualLogin ?? (_otpLoginFlag(config) == 1 ? 0 : 1);
  }

  void _syncLoginModeFromConfig(AuthController authController, ConfigContent? config) {
    final manualLogin = _manualLoginFlag(config);
    final otpLogin = _otpLoginFlag(config);
    final isOtpOnly = manualLogin == 0 && otpLogin == 1;

    final selfRegistration = config?.providerSelfRegistration == 1;
    if (isOtpOnly || selfRegistration) {
      if (authController.selectedLoginMedium != LoginMedium.otp) {
        authController.toggleSelectedLoginMedium(loginMedium: LoginMedium.otp, isUpdate: false);
      }
      if (!authController.isNumberLogin) {
        authController.toggleIsNumberLogin(value: true, isUpdate: false);
      }
      authController.update();
    }
    _loginModeSynced = true;
  }

  Future<void> _requestNotificationPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Future.delayed(const Duration(seconds: 1));
      await FirebaseMessaging.instance.requestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      onPopInvoked: () {
        if (_canExit) {
          SystemNavigator.pop();
        } else {
          showCustomSnackBar('back_press_again_to_exit'.tr, type: ToasterMessageType.info);
          _canExit = true;
          Timer(const Duration(seconds: 2), () {
            _canExit = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: GetBuilder<SplashController>(builder: (splashController) {
                return GetBuilder<AuthController>(builder: (authController) {
                  final config = splashController.configModel.content;
                  final otpLogin = _otpLoginFlag(config);
                  final manualLogin = _manualLoginFlag(config);
                  final isOtpOnly = manualLogin == 0 && otpLogin == 1;
                  final showCredentialFields = manualLogin == 1 || otpLogin == 1;
                  final isPhoneInput = authController.selectedLoginMedium == LoginMedium.otp
                      || isOtpOnly
                      || authController.isNumberLogin;

                  if (!_loginModeSynced && config?.loginSetup?.loginOption != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _syncLoginModeFromConfig(authController, config);
                      }
                    });
                  }

                  return Form(
                    key: signInFormKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        MobileAppIconHelper.loginLogo(width: Dimensions.logoWidth),
                        SizedBox(height: showCredentialFields ? Dimensions.paddingSizeExtraMoreLarge : Dimensions.paddingSizeDefault),

                        if (showCredentialFields)
                          CustomTextField(
                            onCountryChanged: (countryCode) => authController.countryDialCode = countryCode.dialCode!,
                            countryDialCode: isPhoneInput ? authController.countryDialCode : null,
                            isCountryPickerEnabled: false,
                            title: 'email_or_phone'.tr,
                            hintText: authController.selectedLoginMedium == LoginMedium.otp || isOtpOnly
                                ? 'please_enter_phone_number'.tr
                                : 'enter_email_or_password'.tr,
                            controller: _emailController,
                            focusNode: _emailFocus,
                            nextFocus: authController.selectedLoginMedium == LoginMedium.manual && manualLogin == 1 ? _passwordFocus : null,
                            inputType: isPhoneInput ? TextInputType.phone : TextInputType.emailAddress,
                            onChanged: (String text) {
                              if (authController.selectedLoginMedium != LoginMedium.otp) {
                                final numberRegExp = RegExp(r'^[+]?[0-9]+$');
                                if (text.isEmpty && authController.isNumberLogin) {
                                  authController.toggleIsNumberLogin();
                                }
                                if (text.startsWith(numberRegExp) && !authController.isNumberLogin && manualLogin == 1) {
                                  authController.toggleIsNumberLogin();
                                  _emailController.text = text.replaceAll('+', '');
                                }
                                final emailRegExp = RegExp(r'@');
                                if (text.contains(emailRegExp) && authController.isNumberLogin && manualLogin == 1) {
                                  authController.toggleIsNumberLogin();
                                }
                              }
                            },
                            onValidate: (String? value) {
                              if (isOtpOnly && ValidationHelper.getValidPhone(authController.countryDialCode + (value ?? ''), withCountryCode: true) == '') {
                                return 'enter_valid_phone_number'.tr;
                              }
                              if (authController.isNumberLogin && ValidationHelper.getValidPhone(authController.countryDialCode + (value ?? ''), withCountryCode: true) == '') {
                                return 'enter_valid_phone_number'.tr;
                              }
                              if (authController.selectedLoginMedium == LoginMedium.otp || isOtpOnly) {
                                return ValidationHelper.getValidPhone(authController.countryDialCode + (value ?? ''), withCountryCode: true) != ''
                                    ? null
                                    : 'enter_valid_phone_number'.tr;
                              }
                              return (ValidationHelper.getValidPhone(authController.countryDialCode + (value ?? ''), withCountryCode: true) != '' || GetUtils.isEmail(value ?? ''))
                                  ? null
                                  : 'enter_email_address_or_phone_number'.tr;
                            },
                          ),

                        SizedBox(height: manualLogin == 1 && authController.selectedLoginMedium == LoginMedium.manual ? Dimensions.paddingSizeDefault : 0),

                        if (manualLogin == 1 && authController.selectedLoginMedium == LoginMedium.manual)
                          CustomTextField(
                            title: 'password'.tr,
                            hintText: '********'.tr,
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            inputType: TextInputType.visiblePassword,
                            isPassword: true,
                            inputAction: TextInputAction.done,
                            onValidate: (String? value) => FormValidationHelper().isValidPassword(value),
                          ),

                        if (manualLogin == 1 && authController.selectedLoginMedium == LoginMedium.manual)
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                        if (showCredentialFields)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ListTile(
                                  onTap: () => authController.toggleRememberMe(),
                                  title: Row(
                                    children: [
                                      SizedBox(
                                        width: 20.0,
                                        child: Checkbox(
                                          activeColor: Theme.of(context).primaryColor,
                                          value: authController.isActiveRememberMe,
                                          onChanged: (bool? isChecked) => authController.toggleRememberMe(),
                                        ),
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeSmall),
                                      Text('remember_me'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                                    ],
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  horizontalTitleGap: 0,
                                ),
                              ),
                              if (manualLogin == 1 && authController.selectedLoginMedium == LoginMedium.manual)
                                TextButton(
                                  style: TextButton.styleFrom(minimumSize: const Size(1, 40), backgroundColor: Theme.of(context).colorScheme.surface),
                                  onPressed: () {
                                    if (config?.forgetPasswordVerificationMethod?.phone == 0 && config?.forgetPasswordVerificationMethod?.email == 0) {
                                      showCustomSnackBar('no_verification_method_found'.tr);
                                    } else {
                                      Get.toNamed(RouteHelper.getSendOtpScreen());
                                    }
                                  },
                                  child: Text(
                                    'forgot_password?'.tr,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                        if (showCredentialFields) const SizedBox(height: Dimensions.paddingSizeLarge),

                        if (showCredentialFields)
                          CustomButton(
                            btnTxt: (authController.selectedLoginMedium == LoginMedium.otp || isOtpOnly || config?.providerSelfRegistration == 1)
                                ? 'get_otp'.tr
                                : 'sign_in'.tr,
                            onPressed: () {
                              if (signInFormKey.currentState!.validate()) {
                                _login(authController, manualLogin, otpLogin);
                              }
                            },
                            isLoading: authController.isLoading!,
                          ),

                        if (manualLogin == 1 && otpLogin == 1)
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'sign_in_with'.tr,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).textTheme.bodyLarge!.color,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final phoneWithoutCountryCode = ValidationHelper.getValidPhone(Get.find<AuthController>().getUserNumber());
                                    final countryCode = ValidationHelper.getCountryCode(Get.find<AuthController>().getUserNumber());

                                    if (authController.selectedLoginMedium == LoginMedium.otp) {
                                      authController.toggleSelectedLoginMedium(loginMedium: LoginMedium.manual);
                                      _emailController.text = phoneWithoutCountryCode != '' ? phoneWithoutCountryCode : authController.getUserNumber();
                                      if (countryCode != '') {
                                        authController.toggleIsNumberLogin(value: true);
                                      } else {
                                        authController.toggleIsNumberLogin(value: false);
                                      }
                                      authController.initCountryCode(countryCode: countryCode != '' ? countryCode : null);
                                      _passwordController.text = authController.getUserPassword();
                                      if (_passwordController.text.isEmpty) {
                                        _emailController.text = '';
                                        authController.toggleIsNumberLogin(value: false);
                                      }
                                    } else {
                                      authController.toggleSelectedLoginMedium(loginMedium: LoginMedium.otp);
                                      authController.toggleIsNumberLogin(value: true);
                                      _passwordController.clear();
                                      _emailController.text = phoneWithoutCountryCode;
                                      authController.initCountryCode(countryCode: countryCode != '' ? countryCode : null);
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(30, 30),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: Text(
                                      authController.selectedLoginMedium == LoginMedium.manual ? 'OTP'.tr : 'email_or_phone'.tr,
                                      style: robotoRegular.copyWith(
                                        decoration: TextDecoration.underline,
                                        color: Theme.of(context).colorScheme.primary,
                                        fontSize: Dimensions.fontSizeSmall,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (config?.providerSelfRegistration == 1)
                          Padding(
                            padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                            child: Text(
                              trLabel('verify_phone_to_login_or_register'),
                              textAlign: TextAlign.center,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                });
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _initializeController() {
    final authController = Get.find<AuthController>();
    final phoneWithoutCountryCode = ValidationHelper.getValidPhone(Get.find<AuthController>().getUserNumber());
    final countryCode = ValidationHelper.getCountryCode(Get.find<AuthController>().getUserNumber());
    final config = Get.find<SplashController>().configModel.content;
    final otpLogin = config?.loginSetup?.loginOption?.otpLogin ?? 0;
    final manualLogin = config?.loginSetup?.loginOption?.manualLogin ?? (otpLogin == 1 ? 0 : 1);
    final isOtpOnly = manualLogin == 0 && otpLogin == 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (countryCode != '' && phoneWithoutCountryCode != '') {
        authController.toggleIsNumberLogin(value: true);
      } else {
        authController.toggleIsNumberLogin(value: isOtpOnly);
      }
      authController.toggleSelectedLoginMedium(
        loginMedium: isOtpOnly ? LoginMedium.otp : LoginMedium.manual,
      );
      authController.initCountryCode(countryCode: countryCode != '' ? countryCode : null);
      _emailController.text = phoneWithoutCountryCode != '' ? phoneWithoutCountryCode : authController.isNumberLogin ? '' : Get.find<AuthController>().getUserNumber();
      _passwordController.text = Get.find<AuthController>().getUserPassword();
      if (manualLogin == 1 && _passwordController.text.isEmpty) {
        _emailController.text = '';
        authController.initCountryCode();
        authController.toggleIsNumberLogin(value: false);
      }
    });
  }

  void _login(AuthController authController, int manualLogin, int otpLogin) async {
    final isOtpOnly = manualLogin == 0 && otpLogin == 1;
    final selfRegistration = Get.find<SplashController>().configModel.content?.providerSelfRegistration == 1;
    final phone = ValidationHelper.getValidPhone(authController.countryDialCode + _emailController.text.trim(), withCountryCode: true);

    if (authController.selectedLoginMedium == LoginMedium.otp || isOtpOnly || selfRegistration) {
      if (phone.isEmpty) {
        showCustomSnackBar('enter_valid_phone_number'.tr);
        return;
      }

      final firebaseOtp = Get.find<SplashController>().configModel.content?.firebaseOtpVerification == 1;
      SendOtpType type = firebaseOtp ? SendOtpType.firebase : SendOtpType.verification;

      if (type == SendOtpType.firebase) {
        showCustomSnackBar('otp_configuration_is_missing_contact'.tr);
        return;
      }

      final status = await authController.sendProviderLoginOtp(phone);
      if (status.isSuccess!) {
        Get.toNamed(RouteHelper.getVerificationRoute(
          identity: phone,
          identityType: 'phone',
          fromPage: 'provider-otp-login',
          firebaseSession: null,
          showSignUpDialog: false,
        ));
      } else {
        showCustomSnackBar(trLabel(status.message?.toString()));
      }
    } else {
      await authController.login(
        phone != '' ? phone : _emailController.text.trim(),
        _passwordController.text.trim(),
        phone != '' ? 'phone' : 'email',
      );
    }
  }
}
