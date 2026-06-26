import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  static const Set<String> _hiddenMenuRoutes = {
    RouteHelper.paymentInformation,
    RouteHelper.notificationSetup,
    RouteHelper.businessPlan,
  };

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();


    final List<MenuModel> menuList = [
      MenuModel(iconKey: 'profile', icon: Images.profileIcon, title: 'profile'.tr, route: RouteHelper.getProfileRoute()),
      MenuModel(iconKey: 'subscription', icon: Images.mySubscriptions, title: 'mySubscription'.tr, route: RouteHelper.getMySubscriptionRoute()),
      MenuModel(iconKey: 'services', icon: Images.service, title: 'services'.tr, route: RouteHelper.allServices),
      MenuModel(iconKey: 'chat', icon: Images.chatImage, title: 'chat'.tr, routeValidation: "chat",route: RouteHelper.getInboxScreenRoute()),
      MenuModel(iconKey: 'settings', icon: Images.settings, title: 'settings'.tr, route: RouteHelper.getLanguageBottomSheet('menu')),
      MenuModel(iconKey: 'payment_info', icon: Images.paymentInfoIcon, title: 'payment_information'.tr, route: RouteHelper.getPaymentInformationRoute()),
      MenuModel(iconKey: 'notification_channel', icon: Images.notificationSetup, title: 'notification_channel'.tr, route: RouteHelper.getNotificationScreen()),
      MenuModel(iconKey: 'withdraw_list', icon: Images.transaction, title: 'withdraw_list'.tr, route: RouteHelper.transactions),
      MenuModel(iconKey: 'payment_info', icon: Images.paymentInfoIcon, title: 'payments'.tr, route: RouteHelper.getPaymentsRoute()),
      MenuModel(iconKey: 'reports', icon: Images.reportOverview2, title: 'reports'.tr, routeValidation: "reports_&_analytics", route: RouteHelper.getReportingPageRoute('menu')),
      MenuModel(iconKey: 'business_plan', icon: Images.businessPlanIcon, title: 'business_plan'.tr, route: RouteHelper.getBusinessPlanScreen()),
      MenuModel(iconKey: 'help_support', icon: Images.helpIcon, title: 'help_&_support'.tr, route: RouteHelper.getHelpAndSupportScreen()),

      ...(Get.find<SplashController>()
          .configModel
          .content!
          .businessPages
          ?? [])
          .where((page) => HtmlType.isVisibleBusinessPage(page.pageKey, title: page.title))
          .map((page) => MenuModel(
          iconKey: _pageIconKey(page),
          icon: page.pageKey == HtmlType.aboutUs.value
              ? Images.aboutUs
              : page.pageKey == HtmlType.termsAndCondition.value
              ? Images.termsConditionIcon : page.pageKey == HtmlType.privacyPolicy.value
              ? Images.privacyPolicyIcon : page.pageKey == HtmlType.cancellationPolicy.value
              ? Images.cancellation : page.pageKey == HtmlType.refundPolicy.value
              ? Images.refund
              : Images.othersPageIcon, // Or choose icon based on page
          title: page.pageKey == HtmlType.aboutUs.value
              ? 'about_us'.tr
              : page.pageKey == HtmlType.termsAndCondition.value
              ? 'terms_and_conditions'.tr : page.pageKey == HtmlType.privacyPolicy.value
              ? 'privacy_policy'.tr : page.pageKey == HtmlType.cancellationPolicy.value
              ? 'cancellation_policy'.tr : page.pageKey == HtmlType.refundPolicy.value
              ? 'refund_policy'.tr : page.title ?? '',
          route: RouteHelper.getHtmlRoute(page.pageKey!)
      )),

      MenuModel(iconKey: 'logout', icon: Images.logout, title: isLoggedIn ? 'log_out'.tr : 'sign_in'.tr, route: RouteHelper.getSignInRoute("menu"))
    ].where((menu) => !_hiddenMenuRoutes.contains(menu.route)).toList();


    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.65),
      width: Dimensions.webMaxWidth,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        color: Theme.of(context).cardColor,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Icon(Icons.keyboard_arrow_down_rounded, size: 30, color: context.adaptiveIconColor),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Flexible(
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : ResponsiveHelper.isTab(context) ? 7 : 4,
                    mainAxisExtent: 120,
                    crossAxisSpacing: Dimensions.paddingSizeExtraSmall
                ),
                itemCount: menuList.length,
                itemBuilder: (context, index) {
                  return MenuButton(menu: menuList[index], isLogout: index == menuList.length-1);
                },
              ),
              SizedBox(height: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeSmall : 0),
              SafeArea(
                child: RichText(
                  text: TextSpan(
                      text: "app_version".tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,color: Theme.of(context).primaryColorLight),
                      children: <TextSpan>[
                        TextSpan(
                          text: " ${AppConstants.appVersion} ",
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                        )
                      ]
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault)
            ])
          ),
        )
      ]),
    );
  }

  String _pageIconKey(BusinessPage page) {
    if (page.pageKey == HtmlType.aboutUs.value) return 'about_us';
    if (page.pageKey == HtmlType.termsAndCondition.value) return 'terms';
    if (page.pageKey == HtmlType.privacyPolicy.value) return 'privacy_policy';
    if (page.pageKey == HtmlType.cancellationPolicy.value) return 'cancellation_policy';
    if (page.pageKey == HtmlType.refundPolicy.value) return 'refund_policy';
    return 'other_pages';
  }
}
