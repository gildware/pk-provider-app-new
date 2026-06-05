import 'package:demandium_provider/feature/booking_requests/controller/calendar_controller.dart';
import 'package:demandium_provider/feature/booking_requests/widgets/booking_item_card.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class CalenderOrderListDialogWidget extends StatelessWidget {
  final List<CalenderBooking> bookings;

  const CalenderOrderListDialogWidget({
    super.key,
    required this.bookings,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final BookingCalendarController controller = Get.find<BookingCalendarController>();


    return Container(
      constraints: BoxConstraints(
        maxHeight: size.height * 0.8,
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Header Title
          Align(
            alignment: Alignment.center,
            child: Text(
              '${'booking_list'.tr} - ${controller.getFormattedDateRange()}',
              style: robotoBold.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: Dimensions.fontSizeLarge,
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Bookings List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: bookings.length,
              separatorBuilder: (context, index) => 
                const SizedBox(height: Dimensions.paddingSizeSmall),
              itemBuilder: (context, index) {
                return BookingItemCard(
                  booking: bookings[index],
                  controller: controller,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
