import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';


class PaymentInfoView extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const PaymentInfoView({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<BookingDetailsController>(builder: (bookingDetailsController){
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: context.customThemeColors.lightShadow
        ),
        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeDefault,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Text("payment_info".tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha:0.9),
                ),
              ),
            ),
            const SizedBox(height:Dimensions.paddingSizeSmall),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('payment_status'.tr, style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault + 1,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha:0.6))),
                Text(bookingDetails.partialPayments != null && bookingDetails.partialPayments!.isNotEmpty && bookingDetails.isPaid == 0 ? "partially_paid".tr :  bookingDetails.isPaid == 0 ? "unpaid".tr : "paid".tr,
                  style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault + 1,
                  color: bookingDetails.partialPayments != null && bookingDetails.partialPayments!.isNotEmpty && bookingDetails.isPaid == 0 ?
                  Theme.of(context).primaryColor : bookingDetails.isPaid == 0 ?
                  Theme.of(context).colorScheme.error: Colors.green,
                ),),
              ],),
            ),
             CustomBookingDetailsExpansionTile(
               isShowExpandIcon: ( bookingDetails.paymentMethod == 'cash_after_service'
               || bookingDetails.paymentMethod == 'offline_payment' && bookingDetails.bookingOfflinePayment == null ) ? false : true,
              tilePadding: EdgeInsets.zero,
              isShowTrailingExpandIcon: false,
              bookingTitle: 'payment_method'.tr,
              bookingType: '${bookingDetails.paymentMethod}'.tr,
              children: [

                bookingDetails.paymentMethod == 'offline_payment' && bookingDetails.bookingOfflinePayment == null || bookingDetails.paymentMethod == 'cash_after_service' ? SizedBox() :
                Divider(height: 1, thickness: 1, color: Theme.of(context).primaryColor.withValues(alpha:0.2)),

                bookingDetails.paymentMethod == 'offline_payment' && bookingDetails.bookingOfflinePayment != null ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: SizedBox(width: Get.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                      Text("customer_payment_info".tr, style: robotoRegular.copyWith(
                           color: Theme.of(context).primaryColor
                         )),
                         const SizedBox(height: Dimensions.paddingSizeExtraSmall),


                      if(bookingDetails.offlinePaymentMethodName !=null)
                        Row(
                          children: [
                            Text("payment_method".tr,
                                style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Theme.of(context).hintColor,
                            )),

                            Text(" : ${bookingDetails.offlinePaymentMethodName ?? ""}",
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(context).hintColor,
                                )),
                          ],
                        ),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bookingDetails.bookingOfflinePayment?.length,
                        itemBuilder: (context , index){
                          return Padding(
                            padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                            child: Text("${
                                bookingDetails.bookingOfflinePayment?[index].key?.replaceAll("_", " ").capitalizeFirst} "
                                ": ${bookingDetails.bookingOfflinePayment?[index].value}" ,
                                style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: Theme.of(context).hintColor
                                )),
                          );
                          },
                      ),
                    ]),
                  ),
                ): bookingDetails.paymentMethod != "offline_payment" && bookingDetails.paymentMethod != "cash_after_service" ?
                   Padding(
                     padding: const EdgeInsets.symmetric(
                       vertical: Dimensions.paddingSizeSmall,
                         horizontal: Dimensions.paddingSizeDefault),
                     child: Row(children: [


                       Text("Transaction_ID".tr,
                           style: robotoRegular.copyWith(
                           color: Theme.of(context).primaryColor
                       )),
                       const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                       Text(" : ${bookingDetails.transactionId?.replaceAll("_", " ").capitalizeFirst}"),


                     ],),
                   ) : const SizedBox(),

              ],
             ),

          ],
        ),
      );
    });
  }
}

