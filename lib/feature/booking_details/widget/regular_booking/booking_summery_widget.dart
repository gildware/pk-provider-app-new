import 'package:demandium_provider/feature/booking_details/widget/regular_booking/booking_summary_breakdown.dart';
import 'package:demandium_provider/helper/booking_helper.dart';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class BookingSummeryView extends StatelessWidget{
  final BookingDetailsContent bookingDetails;
  const BookingSummeryView({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context){
    return GetBuilder<BookingDetailsController>(builder:(bookingDetailsController){

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [

          Padding(padding: const EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
            child: Text("booking_summary".tr,
              style:robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha:0.9),
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: context.customThemeColors.lightShadow),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              const SizedBox(height: Dimensions.paddingSizeDefault,),

              Container(
                color: Theme.of(context).primaryColor.withValues(alpha:0.05),
                padding: const EdgeInsets.symmetric(horizontal: 7),
                margin:  const EdgeInsets.symmetric(horizontal: 8),
                height: 40,
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("service_info".tr, style:robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge ,
                        color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.8), decoration: TextDecoration.none)
                    ),
                    Text("price".tr,style:robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.8),decoration: TextDecoration.none)
                    ),
                  ],
                ),
              ),

               const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(children: [
                  ListView.builder(
                    itemCount: bookingDetails.details?.length,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemBuilder: (context,index){
                      return ServiceInfoItem(
                        bookingService : bookingDetails.details?[index],
                        bookingDetailsController: bookingDetailsController,
                        index: index,
                      );},
                  ),

                  ...extraServiceInfoItems(context, bookingDetails.extraServiceLines),

                  const Padding(
                    padding: EdgeInsets.symmetric( vertical: Dimensions.paddingSizeDefault),
                    child: Divider(height: 2, color: Colors.grey,),
                  ),

                  if(bookingDetails.isRepeatBooking == 1 )Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text("${"sub_total".tr} x ${bookingDetails.totalCount ?? ""} ${'days'.tr}",style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha:0.9)
                          ),overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault,),
                        Text(PriceConverter.convertPrice(
                          BookingHelper.getDiscountedSubTotal(bookingDetails) * (bookingDetails.totalCount ?? 1),
                          isShowLongPrice:true,
                        ),
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha:0.9)
                          ),
                        ),
                      ],
                    ),
                  ),

                  BookingSummaryBreakdown(bookingDetails: bookingDetails),
                  BookingSummaryGrandTotal(bookingDetails: bookingDetails),

                  const SizedBox(height: Dimensions.paddingSizeSmall,),
                ]),
              )
             ]),
          ),
        ],
      );
       },
    );
  }
}

class ServiceInfoItem extends StatelessWidget {
  final int index;
  final BookingDetailsController bookingDetailsController;
  final ItemService? bookingService;
  const ServiceInfoItem({
    super.key,required this.bookingService,
    required this.bookingDetailsController,
    required this.index});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        const SizedBox(height:Dimensions.paddingSizeSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Text(bookingService?.serviceName??"",
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha:0.9)
                ),
                overflow: TextOverflow.ellipsis,
              )
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault,),
            BookingServicePriceColumn(bookingService: bookingService),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall-2,),

        if(bookingService?.variantKey!=null)
          Padding(padding: const EdgeInsets.only( bottom: Dimensions.paddingSizeExtraSmall),
            child: Row(children: [

              Text(bookingService?.variantKey?.replaceAll("-", " ").capitalizeFirst ?? "",
                style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha:0.7)
                ),
              ),

              Container(
                height: 10, width: 0.5,
                color: Theme.of(context).hintColor,
                margin : const EdgeInsets.only(left : Dimensions.paddingSizeSmall, right:  Dimensions.paddingSizeSmall, top: 5),
              ),

              Row(children: [
                Text("${"qty".tr} : ${bookingService?.quantity}",
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha:0.7),
                  ),
                ),
              ]),

            ]),
          ),


        priceText("unit_price".tr, bookingService?.serviceCost??"0", context),

        if ((bookingService?.discountAmount ?? 0) > 0)
          priceText("discount".tr, bookingService!.discountAmount!, context, prefix: '(-) '),
        if ((bookingService?.campaignDiscountAmount ?? 0) > 0)
          priceText("campaign".tr, bookingService!.campaignDiscountAmount!, context, prefix: '(-) '),
        if ((bookingService?.overallCouponDiscountAmount ?? 0) > 0)
          priceText("coupon".tr, bookingService!.overallCouponDiscountAmount!, context, prefix: '(-) '),
      ],
    );
  }

}


Widget priceText(String title, var amount, context, {String prefix = ''}) {
  return Column(children: [
    Row(
      children: [
        Text("$title : ",
          style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha:0.7)
          ),
        ),
        Text('$prefix${PriceConverter.convertPrice(amount,isShowLongPrice:true)}',
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha:0.7)),
        ),
      ],
    ),
    const SizedBox(height:Dimensions.paddingSizeExtraSmall),
    ],
  );
}

List<Widget> extraServiceInfoItems(BuildContext context, List<ProviderExtraServiceLine>? lines) {
  if (lines == null || lines.isEmpty) {
    return [];
  }
  return lines
      .where((line) => (line.total ?? line.amount ?? 0) > 0)
      .map((line) {
        final bool isSpare = line.isSparePart;
        final Color tagColor = isSpare ? Colors.blue : Theme.of(context).primaryColor;
        final double qty = BookingHelper.getExtraServiceLineQuantity(line);
        final double unitPrice = (line.price != null && line.price! > 0)
            ? line.price!
            : (BookingHelper.getExtraServiceLineSubtotal(line) / qty);
        return Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Text(line.name ?? "",
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.9)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              BookingExtraServicePriceColumn(line: line),
            ]),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 1),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Text((isSpare ? 'spare_part' : 'service').tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: tagColor),
                ),
              ),
            ),
            if (line.details != null && line.details!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                child: Text(line.details!,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7))),
              ),
            Padding(
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
              child: Row(children: [
                Text("${"unit_price".tr} : ",
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7))),
                Text(PriceConverter.convertPrice(unitPrice, isShowLongPrice: true),
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7))),
                Container(
                  height: 10, width: 0.5,
                  color: Theme.of(context).hintColor,
                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                ),
                Text("${"qty".tr} : ${qty.toInt()}",
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7))),
              ]),
            ),
            if ((line.discount ?? 0) > 0)
              priceText("discount".tr, line.discount!, context, prefix: '(-) '),
          ]),
        );
      })
      .toList();
}

