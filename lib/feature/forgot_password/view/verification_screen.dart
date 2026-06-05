import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class VerificationScreen extends StatefulWidget {
   final String? identity;
   final String fromPage;
   final String identityType;
   final String? firebaseSession;
   final bool  showSignUpDialog;
  const VerificationScreen({super.key, this.identity, required this.fromPage, required this.identityType, required this.showSignUpDialog, this.firebaseSession});

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  String? _identity;
  Timer? _timer;
  int? _seconds = 0;

  @override
  void initState() {
    super.initState();

    Get.find<AuthController>().updateWrongVerificationCodeStatus();

    if(widget.identityType == "phone" && !widget.identity!.startsWith('+')){
      _identity = '+${widget.identity!.substring(1, widget.identity!.length)}';
    } else{
      _identity = widget.identity;
    }

    _startTimer();
  }

  void _startTimer() {
    _seconds = Get.find<SplashController>().configModel.content?.sendOtpTimer??60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds! - 1;
      if(_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {

   double width = MediaQuery.of(context).size.width;


    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'otp_verification'.tr),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: GetBuilder<AuthController>(builder: (authController) {
            return Column(children: [

              Image.asset(Images.otp, width: 140),
              const SizedBox(height: Dimensions.paddingSizeDefault,),

              Get.find<SplashController>().configModel.content?.appEnvironment == "demo" ? Text(
                'for_demo_purpose'.tr, style: robotoRegular,
              ) : RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(text: 'we_have_sent_a_verification_code_to'.tr, style: robotoRegular.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha:0.5),

                    )),
                    const TextSpan(text: "\n"),
                    TextSpan(text: StringParser.obfuscateMiddle(_identity??""), style: robotoMedium.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge!.color,)
                    ),
                    // const TextSpan(text: "\n"),
                    // TextSpan(text: 'otp_will_be_expire'.tr, style: ubuntuRegular.copyWith(
                    //   color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha:0.5),
                    //   height: 2,
                    // )),

                  ],
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge,),

              PinCodeTextField(
                length: 6,
                appContext: context,
                keyboardType: TextInputType.number,
                animationType: AnimationType.slide,
                mainAxisAlignment: MainAxisAlignment.center,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  fieldHeight: ResponsiveHelper.isMobile(context) ? width/9 : 60,
                  fieldWidth: ResponsiveHelper.isMobile(context) ? width/9 : 60,
                  borderWidth: 0.5,
                  activeBorderWidth: 0.5,
                  inactiveBorderWidth: 0.5,
                  errorBorderWidth: 0.5,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  selectedColor:  authController.isWrongOtpSubmitted ? Theme.of(context).colorScheme.error.withValues(alpha:0.5) : Theme.of(context).primaryColor.withValues(alpha:0.2),
                  selectedFillColor: Get.isDarkMode?Colors.grey.withValues(alpha:0.6):Colors.white,
                  inactiveFillColor: Theme.of(context).disabledColor.withValues(alpha:0.2),
                  inactiveColor: Theme.of(context).primaryColor.withValues(alpha:0.2),
                  activeColor: authController.isWrongOtpSubmitted ? Theme.of(context).colorScheme.error : Theme.of(context).primaryColor.withValues(alpha:0.4),
                  activeFillColor: Theme.of(context).disabledColor.withValues(alpha:0.2),
                ),
                animationDuration: const Duration(milliseconds: 300),
                backgroundColor: Colors.transparent,
                enableActiveFill: true,
                onChanged: authController.updateVerificationCode,
                beforeTextPaste: (text) => true,
                pastedTextStyle: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                separatorBuilder: (context, index){
                  return const SizedBox(width: Dimensions.paddingSizeDefault,);
                },
              ),

              authController.isWrongOtpSubmitted ? Text('incorrect_otp'.tr,
                style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ) : const Text(" "),

              const SizedBox(height: Dimensions.paddingSizeSmall,),


              CustomButton(
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                btnTxt: "verify".tr, isLoading: authController.isLoading!,
                onPressed: authController.verificationCode.length == 6 ? (){
                _otpVerify(_identity!,widget.identityType, authController.verificationCode,authController);
                } : null,
              ),

              (widget.identity != null && widget.identity!.isNotEmpty) ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  'did_not_receive_the_code'.tr,
                  style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.5)),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(1, 40),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    textStyle: TextStyle(color: Theme.of(context).primaryColor)
                  ),
                  onPressed: _seconds! < 1 ? () async {
                    if (widget.fromPage == 'profile-phone-change') {
                      final response = await Get.find<UserProfileController>()
                          .userRepo
                          .sendPhoneChangeOtp(_identity ?? '');
                      if (response.statusCode == 200 &&
                          response.body['response_code'] == 'default_200') {
                        _startTimer();
                        showCustomSnackBar('resend_code_successful'.tr, type: ToasterMessageType.success);
                      } else {
                        showCustomSnackBar(response.statusText);
                      }
                      return;
                    }

                    if (widget.fromPage == 'provider-otp-login') {
                      final status = await authController.sendProviderLoginOtp(_identity!);
                      if (status.isSuccess!) {
                        _startTimer();
                        showCustomSnackBar('resend_code_successful'.tr, type: ToasterMessageType.success);
                      } else {
                        showCustomSnackBar(status.message);
                      }
                      return;
                    }

                    var config = Get.find<SplashController>().configModel.content;
                    SendOtpType  type = config?.firebaseOtpVerification == 1 && widget.identityType == "phone"
                        ? SendOtpType.firebase : widget.fromPage == "verification" ? SendOtpType.verification : SendOtpType.forgetPassword;

                    authController.sendVerificationCode(identity: _identity!, identityType: widget.identityType, type: type, resendOtp: true, fromPage: widget.fromPage).then((status){
                      if(status !=null){
                        if (status.isSuccess!) {
                          _startTimer();
                          showCustomSnackBar('resend_code_successful'.tr,  type: ToasterMessageType.success);
                        } else {
                          showCustomSnackBar(status.message);
                        }
                      }
                    });

                  } : null,
                  child: Text('${'resend'.tr}${_seconds! > 0 ? ' ($_seconds)' : ''}',style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor,)),
                ),
              ]) : const SizedBox(),

              SizedBox(height: Get.height*0.1,)
            ]);
          }),
        ),
      ),
    );
  }

  void _otpVerify(String identity,String identityType,String otp, AuthController authController) async {

    var config = Get.find<SplashController>().configModel.content;
    var firebaseOtp = (config?.firebaseOtpVerification == 1) && identityType == "phone";

    if(widget.fromPage == "provider-otp-login"){
      authController.verifyOtpForProviderLogin(phone: identity, otp: otp).then((status){
        if(!status.isSuccess!){
          showCustomSnackBar(status.message);
        }
      });
    } else if (widget.fromPage == 'profile-phone-change') {
      Get.find<UserProfileController>().verifyContactPhoneOtp(identity, otp).then((status) {
        if (status.isSuccess!) {
          Get.back();
          showCustomSnackBar(status.message, type: ToasterMessageType.success);
        } else {
          showCustomSnackBar(status.message);
        }
      });
    } else if(widget.fromPage == "verification"){
      if(firebaseOtp){
        authController.verifyOtpForFirebaseOtp(session: widget.firebaseSession, phone: identity, code: otp).then((status){
          if(status.isSuccess!){
            Get.toNamed(RouteHelper.getSignInRoute(""));
            if(widget.showSignUpDialog){
              showCustomBottomSheet(child: const WelcomeBottomSheet(fromSignup: true,));
            }else{
              showCustomSnackBar(status.message, type: ToasterMessageType.success);
            }
          }else{
            showCustomSnackBar(status.message);
          }
        });
      }else {
        authController.verifyOtpForVerificationScreen(identity,identityType,otp).then((status){
          if(status.isSuccess!){
            Get.toNamed(RouteHelper.getSignInRoute(""));
            if(widget.showSignUpDialog){
              showCustomBottomSheet(child: const WelcomeBottomSheet(fromSignup: true,));
            }else{
              showCustomSnackBar(status.message, type: ToasterMessageType.success);
            }
          }else{
            showCustomSnackBar(status.message);
          }
        });
      }
    } else{
      if(firebaseOtp){
        authController.verifyOtpForFirebaseOtp(session: widget.firebaseSession, phone: identity, code: otp).then((status){
          if (status.isSuccess!) {
            Get.offNamed(RouteHelper.getChangePasswordRoute(identity,identityType,otp,1));
          }else {
            showCustomSnackBar(status.message);
          }
        });
      }else{
        authController.verifyOtpForForgetPasswordScreen(identity,identityType,otp).then((status) async {
          if (status.isSuccess!) {
            Get.offNamed(RouteHelper.getChangePasswordRoute(identity,identityType,otp,0));
          }else {
            showCustomSnackBar(status.message);
          }
        });
      }
    }
  }
}
