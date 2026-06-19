import 'package:demandium_provider/feature/booking_details/widget/regular_booking/booking_disputed_settlement_view.dart';
import 'package:demandium_provider/feature/booking_details/widget/regular_booking/booking_loss_making_settlement_view.dart';
import 'package:demandium_provider/feature/booking_details/widget/regular_booking/booking_revenue_settlement_view.dart';
import 'package:demandium_provider/feature/booking_details/widget/regular_booking/booking_special_financial_settlement_view.dart';
import 'package:demandium_provider/helper/booking_helper.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BookingRevenueTab extends StatefulWidget {
  final String? bookingId;
  final String? subBookingId;
  final bool isSubBooking;

  const BookingRevenueTab({
    super.key,
    this.bookingId,
    this.subBookingId,
    required this.isSubBooking,
  });

  @override
  State<BookingRevenueTab> createState() => _BookingRevenueTabState();
}

class _BookingRevenueTabState extends State<BookingRevenueTab> {
  @override
  void initState() {
    super.initState();
    Get.find<BookingDetailsController>().updateServicePageCurrentState(
      BookingDetailsTabControllerState.revenue,
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
            child: Column(
              children: [
                if (BookingHelper.hasDisputedSettlement(bookingDetails))
                  BookingDisputedSettlementView(
                    settlement: bookingDetails.disputedSettlement ??
                        DisputedSettlement(
                          hasDisputedSettlement: true,
                          customerPaidTotal: BookingHelper.resolveDisputedCustomerPaidTotal(bookingDetails),
                          refundTotal: BookingHelper.resolveDisputedRefundTotal(bookingDetails),
                          finalBookingAmount: BookingHelper.resolveDisputedFinalBookingAmount(bookingDetails),
                          retainedFromCustomer: BookingHelper.resolveDisputedFinalBookingAmount(bookingDetails),
                        ),
                  )
                else if (bookingDetails.specialFinancialSettlement?.hasSpecialSettlement == true)
                  BookingSpecialFinancialSettlementView(
                    settlement: bookingDetails.specialFinancialSettlement!,
                  ),
                if ((BookingHelper.hasDisputedSettlement(bookingDetails)
                        || bookingDetails.specialFinancialSettlement?.hasSpecialSettlement == true)
                    && bookingDetails.lossMakingSettlement?.isLossMaking == true)
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                if (bookingDetails.lossMakingSettlement?.isLossMaking == true
                    && !BookingHelper.hasDisputedSettlement(bookingDetails))
                  BookingLossMakingSettlementView(settlement: bookingDetails.lossMakingSettlement!),
                if (bookingDetails.revenueSettlement != null
                    && !BookingHelper.hasDisputedSettlement(bookingDetails))
                  Padding(
                    padding: EdgeInsets.only(
                      top: (BookingHelper.hasDisputedSettlement(bookingDetails)
                              || bookingDetails.specialFinancialSettlement?.hasSpecialSettlement == true
                              || bookingDetails.lossMakingSettlement?.isLossMaking == true)
                          ? Dimensions.paddingSizeDefault
                          : 0,
                    ),
                    child: BookingRevenueSettlementView(bookingDetails: bookingDetails),
                  )
                else if (bookingDetails.lossMakingSettlement?.isLossMaking != true
                    && bookingDetails.specialFinancialSettlement?.hasSpecialSettlement != true
                    && !BookingHelper.hasDisputedSettlement(bookingDetails))
                  SizedBox(
                    height: Get.height * 0.5,
                    child: Center(
                      child: Text(
                        'no_data_found'.tr,
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
