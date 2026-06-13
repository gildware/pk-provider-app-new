import 'package:demandium_provider/feature/dashboard/widgets/advertisement_section.dart';
import 'package:demandium_provider/feature/dashboard/widgets/dashboard_net_balance_widget.dart';
import 'package:demandium_provider/feature/dashboard/widgets/earning_statistics_widget.dart';
import 'package:demandium_provider/feature/payments/controller/payments_controller.dart';
import 'package:demandium_provider/feature/nav/widgets/subscription_trail_end_widget.dart';
import 'package:demandium_provider/feature/dashboard/helper/dashboard_bundle_helper.dart';
import 'package:demandium_provider/helper/error_logger.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});
  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}
class _DashBoardScreenState extends State<DashBoardScreen>{
  final toolTip = JustTheController();

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData({bool reload = false}) async {
    if (reload) {
      DashboardBundleHelper.reset();
    }

    var bundleLoaded = false;
    try {
      bundleLoaded = await DashboardBundleHelper.loadAndApply(reload: reload);
    } catch (error, stack) {
      ErrorLogger.record(error, stack, reason: 'DashBoardScreen._loadDashboardData');
    }

    if (bundleLoaded) {
      final businessSettings = Get.find<BusinessSettingController>();
      await Future.wait([
        Get.find<PaymentsController>().loadOverview(),
        businessSettings.getBookingSettingsDataFromServer(),
        businessSettings.getServiceAvailabilitySettingsFromServer(),
      ]);
      return;
    }

    final businessSettings = Get.find<BusinessSettingController>();
    await Future.wait([
      Get.find<DashboardController>().getEarningData(),
      Get.find<PaymentsController>().loadOverview(),
      businessSettings.getBookingSettingsDataFromServer(),
      businessSettings.getServiceAvailabilitySettingsFromServer(),
      Get.find<DashboardController>().getDashboardData(reload: reload),
    ]);
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<UserProfileController>(builder: (userProfileController){

      bool canShow = userProfileController.providerModel != null && userProfileController.providerModel!.content !=null && userProfileController.providerModel!.content!.subscriptionInfo !=null
          && userProfileController.providerModel!.content!.subscriptionInfo!.subscribedPackageDetails !=null && userProfileController.providerModel!.content!.subscriptionInfo!.subscribedPackageDetails!.trialDuration !=0
          && DateConverter.countDays(endDate: DateTime.parse(userProfileController.providerModel!.content!.subscriptionInfo!.subscribedPackageDetails!.packageEndDate!)) > 0;

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar:  MainAppBar(
          color: Theme.of(context).primaryColor,
          title: AppConstants.appName,
          titleFontSize: Dimensions.fontSizeExtraLarge + 4,
        ),
        body: RefreshIndicator(
          color: Theme.of(context).primaryColorLight,
          backgroundColor: Theme.of(context).cardColor,
          onRefresh: () async {
            await _loadDashboardData(reload: true);
            Get.find<DashboardController>().changeRecentActivityView(status: true, shouldUpdate: true);
            Get.find<DashboardController>().changeTypeOfShowBookingStatus(status: true, shouldUpdate: true);
            await Get.find<UserProfileController>().getProviderInfo(reload: true);
            Get.find<NotificationController>().getNotifications(1, saveNotificationCount: false);
            Get.find<SplashController>().getConfigData();
          },
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                const ProviderPendingApprovalBanner(),
                SizedBox(height: Dimensions.paddingSizeSmall),

                TopCardSection(toolTip: toolTip),
                SizedBox(height: Dimensions.paddingSizeSmall),

                const DashboardNetBalanceWidget(),
                SizedBox(height: Dimensions.paddingSizeSmall),

                const AdvertisementSection(),
                SizedBox(height: Dimensions.paddingSizeSmall),

                const EarningStatisticsWidget(),
                SizedBox(height: Dimensions.paddingSizeSmall),

                const RecentActivitySection(),
                const MySubscriptionSection(),
                const ServiceManSection(),
              ],
            ),
          ),
        ),
        //floatingActionButton: Container(height: 20, color: Colors.red,),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: canShow && !userProfileController.trialWidgetNotShow ? const SubscriptionTrailEndWidget() : const SizedBox(),
      );
    });
  }
}
