import 'package:demandium_provider/feature/dashboard/widgets/caash_in_hand_widget.dart';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class TopCardSection extends StatelessWidget {
  final JustTheController? toolTip;
  const TopCardSection({super.key, this.toolTip});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<UserProfileController>(builder: (userProfileController){


      double receivableAmount = double.tryParse(userProfileController.providerModel?.content?.providerInfo?.owner?.account?.accountReceivable ?? "0" ) ?? 0;
      double payableAmount = double.tryParse(userProfileController.providerModel?.content?.providerInfo?.owner?.account?.accountPayable ?? "0") ?? 0 ;

      TransactionType transactionType =  userProfileController.getTransactionType(payableAmount, receivableAmount);


      return GetBuilder<DashboardController>(
        builder: (dashboardController) =>  dashboardController.dashboardTopCards==null?
        const DashboardShimmer():
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: context.customThemeColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Dimensions.paddingSizeDefault),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Text("business_summery".tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.8),
                  ),
                ),
              ),

              Container(
                padding:  const EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeSmall),
                width: Get.width,
                child: Column(
                  children:[
                    Row(
                      spacing: Dimensions.paddingSizeSmall,
                      children:[
                        TopCardItem(
                            height: 100,
                            curveColor: Colors.green,
                            cardColor: Colors.green,
                            amount: PriceConverter.convertPrice(
                              dashboardController.dashboardTopCards!=null?dashboardController.dashboardTopCards!.totalEarning:0,
                              isShowLongPrice: false,
                            ),
                            title: "total_earning".tr,
                            iconData: Images.earning
                        ),

                        TopCardItem(
                          height: 100,
                          curveColor: Theme.of(context).colorScheme.secondary,
                          cardColor: Theme.of(context).colorScheme.secondary,
                          amount: dashboardController.dashboardTopCards!=null && dashboardController.dashboardTopCards!.totalSubscribedServices!=null
                              ? dashboardController.dashboardTopCards!.totalSubscribedServices.toString()
                              :"0",
                          title: "subscribed_services".tr,
                          iconData: Images.topCardService,
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Row(
                      spacing: Dimensions.paddingSizeSmall,
                      children: [
                        // SERVICEMAN_DISABLED
                        if (AppFeatureFlags.servicemanEnabled)
                          TopCardItem(
                            height: 100,
                            cardColor: Theme.of(context).colorScheme.tertiary,
                            amount: dashboardController.dashboardTopCards != null &&
                                    dashboardController.dashboardTopCards!.totalServiceMan != null
                                ? dashboardController.dashboardTopCards!.totalServiceMan.toString()
                                : "0",
                            title: "total_service_men".tr,
                            iconData: Images.serviceMan,
                          ),
                        Expanded(
                          child: TopCardItem(
                            height: 100,
                            cardColor: Theme.of(context).primaryColor,
                            amount: dashboardController.dashboardTopCards != null &&
                                    dashboardController.dashboardTopCards!.totalBookingServed != null
                                ? dashboardController.dashboardTopCards!.totalBookingServed.toString()
                                : "0",
                            title: "total_booking_served".tr,
                            iconData: Images.serviceMan,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),


                    (transactionType == TransactionType.payable || transactionType == TransactionType.adjustAndPayable ) ?
                    TotalCashInHandWidget(toolTip: toolTip,) : const SizedBox(),

                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
