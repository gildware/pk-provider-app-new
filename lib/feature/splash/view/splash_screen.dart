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
  double opacity = 0.5;

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
    Get.find<SplashController>().initSharedData();

    _route();

  }


  @override
  void dispose() {
    super.dispose();
    _onConnectivityChanged?.cancel();
  }
  void _route() {

    Future.delayed(const Duration(milliseconds: 500),(){
      setState(() {
        opacity = 1;
      });
    });

    Get.find<SplashController>().getConfigData().then((isSuccess) {
      if(isSuccess) {
        Timer(const Duration(seconds: 1), () async {

          if(_checkAvailableUpdate()) {
            Get.offNamed(RouteHelper.getUpdateRoute(true));
          }
          else if(_checkMaintenanceModeActive() && !AppConstants.avoidMaintenanceMode){
            Get.offAllNamed(RouteHelper.getMaintenanceRoute());
            Get.find<AuthController>().unsubscribeToken();
          }
          else {
            PriceConverter.getCurrency();
            if(widget.body != null) {
              _notificationRoute();
            }
            else{
              if (Get.find<AuthController>().isLoggedIn()) {
                Get.find<AuthController>().updateToken();
                Get.find<UserProfileController>().getProviderInfo()
                    .then((value) => Get.offNamed(RouteHelper.getInitialRoute())
                );
              } else {
                if( Get.find<SplashController>().showInitialLanguageScreen()){
                  Get.toNamed(RouteHelper.getLanguageScreenRoute());
                }else{
                  Get.offNamed(RouteHelper.getSignInRoute("LogIn"));
                }
              }
            }
            }
        });
      }else{

      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      key: _globalKey,
      body: GetBuilder<SplashController>(builder: (splashController) {
        return AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 500),
          child: Center(
              child: splashController.hasConnection ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MobileAppIconHelper.loginLogo(width: Dimensions.logoWidth),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Text(
                    AppConstants.appUser,
                    style: robotoBold.copyWith(
                      fontSize: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ]
              )
              : NoInternetScreen(child: SplashScreen(body: widget.body)
             )
          ),
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

  void _notificationRoute(){

    Get.find<UserProfileController>().getProviderInfo().then((value) {
      String notificationType = widget.body?.notificationType??"";

      switch(notificationType) {

        case "chatting": {
          Get.offNamed(RouteHelper.getInboxScreenRoute(fromNotification: "fromNotification"));
        } break;

        case "booking": {
          if( widget.body!.bookingId != null && widget.body!.bookingId != ""){
            if(widget.body!.bookingType == "repeat" && widget.body!.repeatBookingType == "single"){
              Get.toNamed(RouteHelper.getBookingDetailsRoute( subBookingId : widget.body!.bookingId, fromPage : "fromNotification"));
            }else if(widget.body!.bookingType == "repeat" && widget.body!.repeatBookingType != "single"){
              Get.toNamed(RouteHelper.getRepeatBookingDetailsRoute( bookingId : widget.body!.bookingId, fromPage : "fromNotification"));
            }else{
              Get.toNamed(RouteHelper.getBookingDetailsRoute( bookingId : widget.body!.bookingId, fromPage : "fromNotification"));
            }
          }else{
            Get.offNamed(RouteHelper.getInitialRoute());
          }
        } break;

        case "bidding": {
          if( widget.body!.postId!=null && widget.body!.postId!=""){
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
          Get.toNamed(RouteHelper.getAdvertisementDetailsScreen(advertisementId: widget.body?.advertisementId, fromNotification: "fromNotification"));
        } break;

        default: {
          Get.toNamed(RouteHelper.getNotificationRoute(fromPage: "notification"));
        } break;
      }
    });
  }
}
