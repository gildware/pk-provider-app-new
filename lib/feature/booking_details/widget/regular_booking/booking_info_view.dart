import 'package:demandium_provider/common/widgets/booking_status_tags_widget.dart';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class BookingInformationView extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final bool isSubBooking;
  const BookingInformationView({super.key, required this.bookingDetails, required this.isSubBooking});

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<BookingDetailsController>(builder: (bookingDetailsController){
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: context.customThemeColors.lightShadow
        ),
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Expanded(
                  child: Text(
                    '${'booking'.tr} # ${bookingDetails.readableId}',
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.9),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                if (isSubBooking)
                  Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                    padding: const EdgeInsets.all(2),
                    margin: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                    child: const Icon(Icons.repeat, color: Colors.white, size: 12),
                  ),
              ],
            ),

            if (bookingDetails.bookingStatus != null ||
                (bookingDetails.statusUi?.tags.isNotEmpty ?? false) ||
                (bookingDetails.statusUi?.displayKey?.isNotEmpty ?? false)) ...[
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              BookingStatusAndTagsRow(
                rawStatus: bookingDetails.bookingStatus,
                ui: bookingDetails.statusUi,
                alignment: MainAxisAlignment.start,
              ),
            ],

            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            BookingItem(
              img: Images.iconCalendar,
              title: '${'booking_date'.tr} : ',
              subTitle: DateConverter.dateMonthYearTime(
                  DateConverter.isoUtcStringToLocalDate(bookingDetails.createdAt!)),
            ),
            if(bookingDetails.serviceSchedule!=null) const SizedBox(height:Dimensions.paddingSizeExtraSmall),

            if(bookingDetails.serviceSchedule!=null) BookingItem(
              img: Images.iconCalendar,
              title: '${'scheduled_date'.tr} : ',
              subTitle: ' ${DateConverter.dateMonthYearTime(DateTime.tryParse(bookingDetails.serviceSchedule!))}',
            ),
            // const SizedBox(height:Dimensions.paddingSizeExtraSmall),
            // BookingItem(
            //   img: Images.iconLocation,
            //   title: '${'service_address'.tr} : ${bookingDetails.serviceAddress?.address ?? bookingDetails.subBooking?.serviceAddress?.address ?? 'address_not_found'.tr}',
            //   subTitle: '',
            // ),

          ],
        ),
      );
    });
  }
}

