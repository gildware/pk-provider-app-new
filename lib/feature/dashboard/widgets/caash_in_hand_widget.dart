import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class TotalCashInHandWidget extends StatelessWidget {
  final JustTheController? toolTip;
  const TotalCashInHandWidget({super.key, this.toolTip});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {

        if(userProfileController.providerModel !=null){

          double receivableAmount = double.tryParse(userProfileController.providerModel?.content?.providerInfo?.owner?.account?.accountReceivable ?? "0" ) ?? 0;
          double payableAmount = double.tryParse(userProfileController.providerModel?.content?.providerInfo?.owner?.account?.accountPayable ?? "0") ?? 0 ;

          double transactionAmount =  userProfileController.getTransactionAmountAmount(payableAmount, receivableAmount);

          double payablePercent =  userProfileController.getOverflowPercent(payableAmount, receivableAmount, Get.find<SplashController>().configModel.content?.maxCashInHandLimit ?? 0);

          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: payablePercent >= 80 ? Theme.of(context).colorScheme.error.withValues(alpha:0.20) : Theme.of(context).primaryColor.withValues(alpha:0.15)),
                color: Get.isDarkMode? Colors.grey.withValues(alpha:0.2) :  payablePercent >= 80 ? Theme.of(context).colorScheme.error.withValues(alpha:0.05) : Theme.of(context).primaryColor.withValues(alpha:0.03)
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(PriceConverter.convertPrice(transactionAmount),
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge - 3, color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    payablePercent >= 80 ?
                    JustTheTooltip(
                      preferredDirection: AxisDirection.down, tailLength: 14, tailBaseWidth: 20,
                      controller: toolTip,backgroundColor: Colors.black87,
                      content: Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                        child: Text('${'maximum_cash_in_hand_amount'.tr} ${PriceConverter.convertPrice(Get.find<SplashController>().configModel.content?.maxCashInHandLimit??0)}',style: robotoRegular.copyWith(color: Colors.white70),),
                      ),
                      child: InkWell(
                        onTap: ()=> toolTip?.showTooltip(),
                        child: Image.asset(Images.alertIcon, height: 15, width: 15),),)
                        : const SizedBox(),
                  ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),


                  RichText(
                    text: TextSpan(
                      text: '${'payable_balance'.tr} ',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault -1, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.8)),
                      children: payablePercent >= 100 ? <TextSpan>[
                        TextSpan(
                          text: 'limit_exceed'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.error),
                        ) ,
                      ] : [],
                    ),
                  ),


                ]),
              ),

              CustomButton(
                height: 35, width: 120, radius: Dimensions.radiusDefault,
                btnTxt: "view_details".tr,
                fontSize: Dimensions.fontSizeSmall+1,
                onPressed:  () {
                 Get.to(const AccountInformation());
                },
              ),

            ]),

          );
        }else{
          return const SizedBox();
        }
      }
    );
  }
}

