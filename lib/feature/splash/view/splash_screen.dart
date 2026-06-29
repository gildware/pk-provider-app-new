import 'package:demandium_provider/helper/app_startup.dart';
import 'package:demandium_provider/helper/auth_session_helper.dart';
import 'package:demandium_provider/helper/version.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBody? body;
  const SplashScreen({super.key, required this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    bool firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if(!firstTime) {
        bool isNotConnected = result.first != ConnectivityResult.wifi && result.first != ConnectivityResult.mobile;
        isNotConnected ? const SizedBox() : ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected ? 'no_connection'.tr : 'connected'.tr,
            textAlign: TextAlign.center,
          ),
        ));
        if(!isNotConnected) {
          _route();
        }
      }
      firstTime = false;
    });
    Get.find<SplashController>().initSharedData().then((_) async {
      await Get.find<AuthRepo>().preloadRememberMeCredentials();
      await AuthSessionHelper.syncFromStorage();
      _route();
    });

  }


  @override
  void dispose() {
    super.dispose();
    _onConnectivityChanged?.cancel();
  }
  void _route() {
    Get.find<SplashController>().getConfigData().then((isSuccess) async {
      if (!isSuccess) {
        return;
      }

      await AppStartup.ensureDeferredReady();
      if (!mounted) return;

      try {
        await MobileAppIconHelper.ensureReady(context);
      } catch (_) {
        //
      }

      final notificationBody = widget.body ?? AppStartup.initialNotificationBody;

      if (_checkAvailableUpdate()) {
        Get.offNamed(RouteHelper.getUpdateRoute(true));
      } else if (_checkMaintenanceModeActive() && !AppConstants.avoidMaintenanceMode) {
        Get.offAllNamed(RouteHelper.getMaintenanceRoute());
        Get.find<AuthController>().unsubscribeToken();
      } else {
        PriceConverter.getCurrency();
        if (notificationBody != null) {
          _notificationRoute(notificationBody);
        } else if (Get.find<AuthController>().isLoggedIn()) {
          await Get.find<UserProfileController>().getProviderInfo();
          await Get.find<AuthController>().updateToken();
          if (!mounted) return;
          Get.offNamed(RouteHelper.getInitialRoute());
        } else if (AppConstants.enableLanguageSelection && Get.find<SplashController>().showInitialLanguageScreen()) {
          Get.toNamed(RouteHelper.getLanguageScreenRoute());
        } else {
          Get.offNamed(RouteHelper.getSignInRoute('LogIn'));
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      key: _globalKey,
      body: GetBuilder<SplashController>(builder: (splashController) {
        return Center(
            child: splashController.hasConnection ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MobileAppIconHelper.loginLogo(width: Dimensions.logoWidth),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Text(
                    AppConstants.appUser,
                    style: robotoBold.copyWith(
                      fontSize: 20,
                      color: context.adaptivePrimaryColor,
                    ),
                  ),
                ]
              )
              : NoInternetScreen(child: SplashScreen(body: widget.body)
             )
        );
      }),
    );
  }

  bool _checkAvailableUpdate (){
    ConfigModel? configModel = Get.find<SplashController>().configModel;
    final localVersion = Version.parse(AppConstants.appVersion);
    final serverVersion = Version.parse(GetPlatform.isAndroid
        ? configModel.content?.minimumVersion?.minVersionForAndroid ?? ""
        :  configModel.content?.minimumVersion?.minVersionForIos ?? ""
    );
    return localVersion.compareTo(serverVersion) == -1;
  }

  bool _checkMaintenanceModeActive(){
    final ConfigModel configModel = Get.find<SplashController>().configModel;
    return (configModel.content?.maintenanceMode?.maintenanceStatus == 1 && configModel.content?.maintenanceMode?.selectedMaintenanceSystem?.providerApp == 1);
  }

  void _notificationRoute(NotificationBody notificationBody){
    if (!Get.find<AuthController>().isLoggedIn()) {
      Get.offNamed(RouteHelper.getSignInRoute('LogIn'));
      return;
    }

    Get.find<UserProfileController>().getProviderInfo().then((value) {
      String notificationType = notificationBody.notificationType??"";

      switch(notificationType) {

        case "chatting": {
          Get.offNamed(RouteHelper.getInboxScreenRoute(fromNotification: "fromNotification"));
        } break;

        case "booking": {
          if (notificationBody.bookingId != null && notificationBody.bookingId != "") {
            Get.offNamed(RouteHelper.getInitialRoute());
            Future.delayed(const Duration(milliseconds: 600), () {
              if (notificationBody.bookingType == "repeat" &&
                  notificationBody.repeatBookingType == "single") {
                Get.toNamed(
                  RouteHelper.getBookingDetailsRoute(
                    subBookingId: notificationBody.bookingId,
                    fromPage: "fromNotification",
                  ),
                );
              } else if (notificationBody.bookingType == "repeat" &&
                  notificationBody.repeatBookingType != "single") {
                Get.toNamed(
                  RouteHelper.getRepeatBookingDetailsRoute(
                    bookingId: notificationBody.bookingId,
                    fromPage: "fromNotification",
                  ),
                );
              } else {
                Get.toNamed(
                  RouteHelper.getBookingDetailsRoute(
                    bookingId: notificationBody.bookingId,
                    fromPage: "fromNotification",
                  ),
                );
              }
            });
          } else {
            Get.offNamed(RouteHelper.getInitialRoute());
          }
        } break;

        case "bidding": {
          if( notificationBody.postId!=null && notificationBody.postId!=""){
            Get.offAll(()=>const CustomerRequestListScreen());
          }else{
            Get.offNamed(RouteHelper.getInitialRoute());
          }
        } break;

        case "privacy_policy": {
          Get.toNamed(RouteHelper.getHtmlRoute(HtmlType.privacyPolicy.value));
        } break;

        case "terms_and_conditions": {
          Get.toNamed(RouteHelper.getHtmlRoute(HtmlType.termsAndCondition.value));
        } break;

        case "suspend": {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } break;

        case "withdraw": {
          Get.toNamed(RouteHelper.getTransactionListRoute(fromPage: "fromNotification"));
        } break;

        case "admin_pay": {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } break;
        case "maintenance": {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } break;
        case "advertisement": {
          Get.toNamed(RouteHelper.getAdvertisementDetailsScreen(advertisementId: notificationBody.advertisementId, fromNotification: "fromNotification"));
        } break;

        case "review": {
          Get.offNamed(RouteHelper.getInitialRoute());
          Future.delayed(const Duration(milliseconds: 600), () {
            NotificationHelper.openReviewNotificationTarget();
          });
        } break;

        case "incoming_call":
        case "call_accepted":
        case "call_declined":
        case "call_cancelled":
        case "call_missed":
        case "call_ended": {
          Get.offAllNamed(RouteHelper.getInitialRoute());
          Future.delayed(const Duration(milliseconds: 600), () async {
            if (Get.isRegistered<InAppCallController>()) {
              await Get.find<InAppCallController>().handlePushData(notificationBody.toJson());
            }
          });
        } break;

        default: {
          Get.toNamed(RouteHelper.getNotificationRoute(fromPage: "notification"));
        } break;
      }
    });
  }
}
