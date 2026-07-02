import 'package:demandium_provider/feature/transaction/widget/withdraw_list_shimmer.dart';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class TransactionScreen extends StatefulWidget {
  final String? fromNotification;
  const TransactionScreen({super.key,  this.fromNotification = ""});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {

  @override
  void initState() {
    super.initState();
    Get.find<TransactionController>().getWithdrawRequestList(1,false, shouldUpdate: widget.fromNotification == "from_notification" ? false: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: "withdraw_list".tr, onBackPressed: () {
        handleNotificationBack(
          fromNotification: widget.fromNotification == 'fromNotification',
          whenFromNotification: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
          context: context,
        );
      }),
      body: GetBuilder<TransactionController>(
        builder: (transactionController){
        List<TransactionData>? transactionsList = transactionController.transactionsList;
        return transactionController.isLoading && transactionsList!.isEmpty ?
        const WithdrawListShimmer() :
        transactionController.transactionsList!.isEmpty ?
        Center(child: const NoDataScreen(text: "no_withdraw_history",type: NoDataType.transaction)):
        RefreshIndicator(
          color: Theme.of(context).primaryColorLight,
          backgroundColor: Theme.of(context).cardColor,
          onRefresh: () async {
            Get.find<TransactionController>().getWithdrawRequestList(1,false);
          },
          child: Column(children: [
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Expanded(child: Column(children: [

                  Expanded(child: ListView.builder(
                      controller: transactionController.scrollController,
                      itemBuilder: (context,index){
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeExtraSmall,
                        ),
                        child: Container(
                          width: Get.width,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            color: Theme.of(context).cardColor.withValues(alpha:Get.isDarkMode ? 0.5 : 1),
                            border: Border.all(
                              color: Theme.of(context).hintColor.withValues(alpha:0.2),
                            )
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: Dimensions.paddingSizeDefault
                            ),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'withdrawn_amount'.tr,
                                        style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeLarge,
                                          color: context.adaptivePrimaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          PriceConverter.convertPrice(
                                            double.tryParse(transactionsList[index].amount ?? '0'),
                                          ),
                                          style: robotoBold.copyWith(
                                            fontSize: Dimensions.fontSizeLarge,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                          textAlign: TextAlign.end,
                                        ),
                                        if (transactionsList[index].requestStatus == 'settled') ...[
                                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                          Text(
                                            "(${ 'settled'.tr })",
                                            style: robotoMedium.copyWith(
                                              fontSize: Dimensions.fontSizeSmall,
                                              color: context.customThemeColors.success,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),


                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [


                                  Text(DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate(
                                      transactionsList[index].createdAt??"")),
                                      style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: Theme.of(context).hintColor
                                      ),
                                      textDirection: TextDirection.ltr
                                  ),


                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeSmall,
                                      vertical: Dimensions.paddingSizeExtraSmall
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                                      color: context.customThemeColors.buttonTextColorMap[transactionsList[index].requestStatus]?.withValues(alpha:0.2)
                                    ),
                                    child: Text("${transactionsList[index].requestStatus}".tr,
                                        style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: context.customThemeColors.buttonTextColorMap[transactionsList[index].requestStatus]
                                        )
                                    ),
                                  ),


                                ]),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall,),


                                if(transactionsList[index].requestUpdater!.userType!='provider-admin')
                                  Row(children: [


                                    Text('${transactionsList[index].requestStatus.toString().tr} ${'by'.tr} : ',
                                      style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: Theme.of(context).hintColor
                                      ),
                                    ),


                                    Text('${transactionsList[index].requestUpdater!.firstName??""} '
                                          '${transactionsList[index].requestUpdater!.lastName??""}',
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.8),
                                      ),
                                    )


                                  ]),
                                  const SizedBox(height: Dimensions.paddingSizeSmall,),


                                transactionsList[index].providerNote !=null || transactionsList[index].adminNote != null || transactionsList[index].transactionId != null?
                                Container(margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                  decoration: BoxDecoration(
                                    color: context.adaptivePrimaryColor.withValues(alpha:0.08),
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    border: Border.all(
                                        color: context.adaptivePrimaryColor.withValues(alpha:0.08)
                                    ),
                                  ),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: Dimensions.paddingSizeExtraSmall
                                      ),
                                      child: CustomBookingDetailsExpansionTile(
                                        tilePadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                        titlePadding: EdgeInsets.zero,
                                        isShowExpandIcon: false,
                                        trailingIconSize: Dimensions.paddingSizeExtraLarge * 1.5,
                                        isShowTrailingExpandIcon: true,
                                        leading: Image(
                                          image: AssetImage(Images.note),
                                          height: Dimensions.paddingSizeExtraLarge,
                                          width: Dimensions.paddingSizeExtraLarge,
                                        ),
                                        bookingTitle: "note".tr,
                                        bookingTitleColor: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.8),
                                        children: [


                                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [


                                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                            Divider(height: 1, thickness: 1,
                                                color: context.adaptivePrimaryColor.withValues(alpha: 0.08)
                                            ),


                                            if( transactionsList[index].providerNote !=null )
                                            Padding(padding: const EdgeInsets.symmetric(
                                              horizontal: Dimensions.paddingSizeSmall,
                                              vertical: 10
                                             ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                  Text(
                                                    "provider_note".tr,
                                                    style: robotoMedium.copyWith(
                                                      fontSize: Dimensions.fontSizeDefault,
                                                      color: Theme.of(context).textTheme.bodyLarge!.color,
                                                    ),
                                                  ),
                                                  Text(
                                                    transactionsList[index].providerNote??"",
                                                    style: robotoRegular.copyWith(
                                                      fontSize: Dimensions.fontSizeDefault,
                                                      color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.6),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            if( transactionsList[index].adminNote !=null )
                                              Padding(padding: const EdgeInsets.symmetric(
                                                horizontal: Dimensions.paddingSizeSmall,
                                              ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "admin_note".tr,
                                                      style: robotoMedium.copyWith(
                                                        fontSize: Dimensions.fontSizeDefault,
                                                        color: Theme.of(context).textTheme.bodyLarge!.color,
                                                      ),
                                                    ),
                                                    Text(
                                                      transactionsList[index].adminNote??"",
                                                      style: robotoRegular.copyWith(
                                                        fontSize: Dimensions.fontSizeDefault,
                                                        color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.6),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            if( transactionsList[index].transactionId != null && transactionsList[index].transactionId!.isNotEmpty )
                                              Padding(padding: const EdgeInsets.symmetric(
                                                horizontal: Dimensions.paddingSizeSmall,
                                                vertical: Dimensions.paddingSizeExtraSmall,
                                              ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "transaction_id".tr,
                                                      style: robotoMedium.copyWith(
                                                        fontSize: Dimensions.fontSizeDefault,
                                                        color: Theme.of(context).textTheme.bodyLarge!.color,
                                                      ),
                                                    ),
                                                    Text(
                                                      transactionsList[index].transactionId ?? "",
                                                      style: robotoRegular.copyWith(
                                                        fontSize: Dimensions.fontSizeDefault,
                                                        color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.6),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            if( transactionsList[index].adminNote !=null || transactionsList[index].transactionId != null)
                                            const SizedBox(height: Dimensions.paddingSizeSmall,)


                                          ]),


                                        ]),
                                       ),

                                  ]),
                                 ): const SizedBox(),


                              ]),
                          ),
                        ),
                      );
                      },
                      itemCount: transactionsList!.length,
                    )),
                  transactionController.paginationLoading!?
                  CircularProgressIndicator(color: Theme.of(context).hoverColor
                  ) : const SizedBox.shrink()
                ],
              ),)
            ],
          ),
        );
      }),

    );
  }
}


