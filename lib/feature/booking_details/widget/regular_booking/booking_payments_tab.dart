import 'package:demandium_provider/feature/booking_details/widget/regular_booking/booking_payment_details_view.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BookingPaymentsTab extends StatefulWidget {
  final String? bookingId;
  final String? subBookingId;
  final bool isSubBooking;

  const BookingPaymentsTab({
    super.key,
    this.bookingId,
    this.subBookingId,
    required this.isSubBooking,
  });

  @override
  State<BookingPaymentsTab> createState() => _BookingPaymentsTabState();
}

class _BookingPaymentsTabState extends State<BookingPaymentsTab> {
  @override
  void initState() {
    super.initState();
    Get.find<BookingDetailsController>().updateServicePageCurrentState(
      BookingDetailsTabControllerState.payments,
      shouldUpdate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      builder: (bookingDetailsController) {
        final bookingDetailsContent = widget.isSubBooking
            ? bookingDetailsController.subBookingDetails
            : bookingDetailsController.bookingDetails;

        if (bookingDetailsContent == null) {
          return const Center(child: BookingDetailsShimmer());
        }
        if (bookingDetailsContent.content == null) {
          return SizedBox(
            height: Get.height * 0.7,
            child: BookingEmptyScreen(bookingId: widget.bookingId ?? ''),
          );
        }

        final bookingDetails = bookingDetailsContent.content!;

        return RefreshIndicator(
          onRefresh: () async {
            if (widget.isSubBooking) {
              await bookingDetailsController.getBookingSubDetails(
                widget.subBookingId ?? '',
                reload: false,
              );
            } else {
              await bookingDetailsController.getBookingDetails(
                widget.bookingId ?? '',
                reload: false,
              );
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: Dimensions.paddingSizeDefault,
            ),
            child: BookingPaymentDetailsView(
              bookingDetails: bookingDetails,
              parentBookingId: widget.bookingId,
              isSubBooking: widget.isSubBooking,
              subBookingId: widget.subBookingId,
            ),
          ),
        );
      },
    );
  }
}
