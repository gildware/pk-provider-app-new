
import 'package:demandium_provider/feature/payments/controller/payments_controller.dart';
import 'package:demandium_provider/feature/payement_information/controller/payment_info_controller.dart';
import 'package:demandium_provider/feature/advertisement/view/advertisement_list_screen.dart';
import 'package:demandium_provider/helper/booking_alert_watcher.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';


class BottomNavScreen extends StatefulWidget {
  final int pageIndex;
  final bool formTutorial;

  static Future<void> loadData({int pageIndex = 0}) async {
    await SilentApiContext.run(() async {
      Get.find<DashboardController>().getDashboardData(reload: true);
      Get.find<DashboardController>().getEarningData();
      Get.find<PaymentsController>().loadOverview();
      Get.find<UserProfileController>().getProviderInfo(reload: true);
      Get.find<ServiceCategoryController>().getCategoryList(shouldUpdate: true, reloadSubcategory: true);
      Get.find<LocalizationController>().filterLanguage(shouldUpdate: false);
      Get.find<ConversationController>().getChannelList(1, type: "customer");
      // SERVICEMAN_DISABLED
      if (AppFeatureFlags.servicemanEnabled) {
        Get.find<ConversationController>().getChannelList(1, type: "serviceman");
        Get.find<ServicemanSetupController>().getAllServicemanList(1, reload: true, status: 'all');
      }
      await Get.find<UserProfileController>().getProviderInfo(reload: true).then((isProviderModelAvailable) {
        Get.find<BusinessSubscriptionController>().getSubscriptionPackageList();
        if (pageIndex != 1) {
          Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet();
        }
        Get.find<UserProfileController>().trialWidgetShow(route: "");
      });
      await Get.find<AuthController>().updateToken();
      Get.find<PaymentInfoController>().getPaymentMethods(isUpdate: false, isReload: false);
    });
  }

  const BottomNavScreen({super.key, required this.pageIndex, this.formTutorial = false});

  @override
  BottomNavScreenState createState() => BottomNavScreenState();
}

class BottomNavScreenState extends State<BottomNavScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  List<Widget>? _screens;
  bool _canExit = GetPlatform.isWeb ? true : false;

  /// Bidding/post system — controlled by admin (Mobile App Management → App Features).
  bool get _isBiddingEnabled =>
      Get.find<SplashController>().configModel.content?.biddingStatus == 1;

  int get _adsTabIndex => _isBiddingEnabled ? 3 : 2;
  int get _moreTabIndex => _isBiddingEnabled ? 4 : 3;

  @override
  void initState() {
    super.initState();

    if(!widget.formTutorial) {
      BottomNavScreen.loadData(pageIndex: widget.pageIndex);
    }
    final initialPage = widget.pageIndex;
    _pageIndex = initialPage;
    _pageController = PageController(initialPage: initialPage);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });

    if (Get.isRegistered<BookingAlertWatcher>()) {
      Get.find<BookingAlertWatcher>().start();
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<BookingAlertWatcher>()) {
      Get.find<BookingAlertWatcher>().stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final int advertisementCount =
        Get.find<DashboardController>().additionalInfoCount?.advertisementCount ?? 0;

    _screens = [
      const DashBoardScreen(),
      const BookingRequestScreen(),
      // Post/bidding tab — hidden unless enabled via admin (Mobile App Management → App Features).
      if (_isBiddingEnabled) const CustomerRequestListScreen(embeddedInBottomNav: true),
      AdvertisementListScreen(
        embeddedInBottomNav: true,
        isDataAvailable: advertisementCount != 0,
      ),
      Text("more".tr),
    ];

    final padding = MediaQuery.of(context).padding;

    return CustomPopScopeWidget(
      onPopInvoked: (){
        if (_pageIndex != 0) {
          _setPage(0);
        } else {
          if(_canExit) {
            SystemNavigator.pop();
          }else {
            showCustomSnackBar('back_press_again_to_exit'.tr,  type: ToasterMessageType.info);
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
          }
        }
      },
      child: Scaffold(
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            top: Dimensions.paddingSizeDefault,
            bottom: padding.bottom > 15 ? 0 : Dimensions.paddingSizeDefault,
          ),
          decoration: BoxDecoration(
              color: Get.isDarkMode?Theme.of(context).colorScheme.surface:Theme.of(context).primaryColor,
              boxShadow:[
                BoxShadow(
                  offset: const Offset(0, 1),
                  blurRadius: 5,
                  color: Theme.of(context).primaryColor.withValues(alpha:0.5),
                )]
          ),
          child: SafeArea(
            child: GetBuilder<SplashController>(builder: (splashController) {
              final bool showPostBadge = splashController.showRedDotIconForCustomBooking;
              return Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                child: Row(children: [
                  _getBottomNavItem(0, iconKey: 'bottom_dashboard', fallbackAsset: Images.dashboard, title: 'dashboard'.tr),
                  _getBottomNavItem(1, iconKey: 'bottom_requests', fallbackAsset: Images.requests, title: 'requests'.tr),
                  // Post/bidding tab — hidden unless enabled via admin (Mobile App Management → App Features).
                  if (_isBiddingEnabled)
                    _getBottomNavItem(
                      2,
                      iconKey: 'post',
                      fallbackAsset: Images.customPostIcon,
                      title: 'post'.tr,
                      showBadge: showPostBadge,
                    ),
                  _getBottomNavItem(
                    _adsTabIndex,
                    iconKey: 'bottom_advertisements',
                    fallbackAsset: Images.menuAdvertisement,
                    title: 'advertisements'.tr,
                  ),
                  _getBottomNavItem(_moreTabIndex, iconKey: 'bottom_more', fallbackAsset: Images.more, title: 'more'.tr),
                ]),
              );
            }),
          ),
        ),
        body: GetBuilder<UserProfileController>(
            builder: (userProfileController) {
              return GetBuilder<SplashController>(
                builder: (splashController) {
                  return PageView.builder(
                    controller: _pageController,
                    itemCount: _screens!.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _screens![index];
                    },
                  );
                },
              );
            }
        ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    if(pageIndex == _moreTabIndex) {
      Get.find<UserProfileController>().trialWidgetShow(route: "show-dialog");
      Get.bottomSheet(
        const MenuScreen(),
        backgroundColor: Colors.transparent, isScrollControlled: true,
        barrierColor: Colors.black.withValues(alpha:Get.isDarkMode ? 0.7 : 0.6 ),
      ).then((_){
        Get.find<UserProfileController>().trialWidgetShow(route: "");
      });
    } else if (_isBiddingEnabled && pageIndex == 2) {
      _openPostTab();
    } else if (pageIndex == _adsTabIndex) {
      _openAdvertisementsTab();
    } else {
      setState(() {
        _pageController?.jumpToPage(pageIndex);
        _pageIndex = pageIndex;
      });
    }
  }

  void _openAdvertisementsTab() {
    Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrial) {
      if (!isTrial) {
        return;
      }
      if (!Get.find<UserProfileController>().checkAvailableFeatureInSubscriptionPlan(featureType: 'advertisement')) {
        return;
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _pageController?.jumpToPage(_adsTabIndex);
        _pageIndex = _adsTabIndex;
      });
    });
  }

  void _openPostTab() {
    if (Get.find<SplashController>().configModel.content?.biddingStatus != 1) {
      showCustomSnackBar('custom_booking_request'.tr, type: ToasterMessageType.info);
      return;
    }

    Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrial) {
      if (!isTrial) {
        return;
      }
      if (!Get.find<UserProfileController>().checkAvailableFeatureInSubscriptionPlan(featureType: 'bidding')) {
        return;
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _pageController?.jumpToPage(2);
        _pageIndex = 2;
      });
    });
  }

  Widget _getBottomNavItem(
    int index, {
    required String iconKey,
    required String fallbackAsset,
    required String title,
    bool applyTint = true,
    bool showBadge = false,
  }) {
    final bool isSelected = _pageIndex == index;
    final Color selectedColor = Get.isDarkMode ? Theme.of(context).primaryColor : Colors.white;
    final Color unselectedColor = Colors.grey.shade400;

    Widget iconWidget = MobileAppIconHelper.icon(
      key: iconKey,
      fallbackAsset: fallbackAsset,
      width: applyTint ? 17 : 20,
      height: applyTint ? 17 : 20,
      color: applyTint ? (isSelected ? selectedColor : unselectedColor) : null,
    );

    if (showBadge) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          iconWidget,
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).cardColor, width: 1),
              ),
            ),
          ),
        ],
      );
    }

    return Expanded(child: InkWell(
      onTap: () => _setPage(index),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        iconWidget,
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(title, style: robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: isSelected ? selectedColor : unselectedColor,
        )),
      ]),
    ));
  }

}
