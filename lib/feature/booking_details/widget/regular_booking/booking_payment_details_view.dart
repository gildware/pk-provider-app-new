import 'package:demandium_provider/feature/booking_details/widget/regular_booking/booking_overview_kv_row.dart';
import 'package:demandium_provider/feature/booking_details/widget/regular_booking/booking_payment_history_view.dart';
import 'package:demandium_provider/feature/booking_details/widget/regular_booking/record_payment_bottom_sheet.dart';
import 'package:demandium_provider/helper/booking_helper.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

/// Payment summary for the Payments tab on booking details.
class BookingPaymentDetailsView extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final String? parentBookingId;
  final bool isSubBooking;
  final String? subBookingId;

  const BookingPaymentDetailsView({
    super.key,
    required this.bookingDetails,
    this.parentBookingId,
    this.isSubBooking = false,
    this.subBookingId,
  });

  @override
  Widget build(BuildContext context) {
    final payment = bookingDetails.paymentDetails;
    final isWriteoffSettled = BookingHelper.isWriteoffSettledBooking(bookingDetails);
    final isDisputed = BookingHelper.hasDisputedSettlement(bookingDetails);
    final dueBalance = BookingHelper.resolveBookingDueBalance(bookingDetails);
    final settlementAmount = BookingHelper.getWriteoffSettlementAmount(bookingDetails);
    final customerPaid = isDisputed
        ? (BookingHelper.resolveDisputedCustomerPaidTotal(bookingDetails) ?? payment?.amountPaidDisplay ?? 0)
        : (payment?.amountPaidDisplay ?? 0);
    final finalAmount = isDisputed
        ? (BookingHelper.resolveDisputedFinalBookingAmount(bookingDetails) ?? payment?.total ?? 0)
        : (payment?.total ?? 0);
    final refundedAmount = BookingHelper.resolveRefundedAmount(bookingDetails);
    final pendingRefund = BookingHelper.resolvePendingRefundAmount(bookingDetails);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (payment == null)
          PaymentInfoView(bookingDetails: bookingDetails)
        else
          BookingOverviewSectionCard(
            title: 'payment_info'.tr,
            icon: Icons.payments_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookingOverviewKvRow(
                  title: 'payment_status'.tr,
                  value: payment.statusLabel ?? '',
                  valueStyle: robotoMedium.copyWith(
                    color: _paymentStatusColor(context, payment.statusLabel),
                  ),
                ),
                if (isDisputed) ...[
                  BookingOverviewKvRow(
                    title: 'customer_paid_total'.tr,
                    value: PriceConverter.convertPrice(customerPaid, isShowLongPrice: true),
                  ),
                  if (refundedAmount != null && refundedAmount > 0.009)
                    BookingOverviewKvRow(
                      title: 'refunded_amount'.tr,
                      value: '-${PriceConverter.convertPrice(refundedAmount, isShowLongPrice: true)}',
                      valueStyle: robotoMedium.copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                  if (pendingRefund != null && pendingRefund > 0.009)
                    BookingOverviewKvRow(
                      title: 'pending_refund'.tr,
                      value: PriceConverter.convertPrice(pendingRefund, isShowLongPrice: true),
                      valueStyle: robotoMedium.copyWith(color: Colors.orange.shade800),
                    ),
                  BookingOverviewKvRow(
                    title: 'final_booking_amount'.tr,
                    value: PriceConverter.convertPrice(finalAmount, isShowLongPrice: true),
                    valueStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  BookingOverviewKvRow(
                    title: 'due_balance'.tr,
                    value: PriceConverter.convertPrice(dueBalance, isShowLongPrice: true),
                    valueStyle: robotoMedium.copyWith(
                      color: dueBalance > 0.009
                          ? Theme.of(context).colorScheme.error
                          : Colors.green.shade700,
                    ),
                  ),
                ] else ...[
                  BookingOverviewKvRow(
                    title: 'total_amount'.tr,
                    value: PriceConverter.convertPrice(payment.total ?? 0, isShowLongPrice: true),
                  ),
                  BookingOverviewKvRow(
                    title: (payment.showAsAmountPaidLabel == true ? 'amount_paid' : 'advance_paid').tr,
                    value: PriceConverter.convertPrice(payment.amountPaidDisplay ?? 0, isShowLongPrice: true),
                  ),
                  if (refundedAmount != null && refundedAmount > 0.009)
                    BookingOverviewKvRow(
                      title: 'refunded_amount'.tr,
                      value: PriceConverter.convertPrice(refundedAmount, isShowLongPrice: true),
                      valueStyle: robotoMedium.copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                  if (pendingRefund != null && pendingRefund > 0.009)
                    BookingOverviewKvRow(
                      title: 'pending_refund'.tr,
                      value: PriceConverter.convertPrice(pendingRefund, isShowLongPrice: true),
                      valueStyle: robotoMedium.copyWith(color: Colors.orange.shade800),
                    ),
                  BookingOverviewKvRow(
                    title: 'due_balance'.tr,
                    value: PriceConverter.convertPrice(
                      dueBalance,
                      isShowLongPrice: true,
                    ),
                    valueStyle: robotoMedium.copyWith(
                      color: dueBalance > 0.009
                          ? Theme.of(context).colorScheme.error
                          : Colors.green.shade700,
                    ),
                  ),
                ],
                if (isWriteoffSettled && !isDisputed)
                  BookingOverviewKvRow(
                    title: 'settlement_amount'.tr,
                    value: PriceConverter.convertPrice(settlementAmount, isShowLongPrice: true),
                    valueStyle: robotoMedium.copyWith(color: Colors.green.shade700),
                  ),
                if (payment.offlineVerifyStatus != null && payment.offlineVerifyStatus!.isNotEmpty)
                  BookingOverviewKvRow(
                    title: 'request_verify_status'.tr,
                    value: payment.offlineVerifyStatus!.tr,
                  ),
                if ((payment.scaledBadDebtBalanceNotDue ?? 0) > 0)
                  BookingOverviewKvRow(
                    title: 'bfs_bad_debt_balance_not_due'.tr,
                    value: PriceConverter.convertPrice(payment.scaledBadDebtBalanceNotDue ?? 0, isShowLongPrice: true),
                  ),
                if ((payment.scaledLossCompanyShare ?? 0) > 0)
                  BookingOverviewKvRow(
                    title: 'loss_to_company'.tr,
                    value: PriceConverter.convertPrice(payment.scaledLossCompanyShare ?? 0, isShowLongPrice: true),
                  ),
                if ((payment.scaledLossProviderShare ?? 0) > 0)
                  BookingOverviewKvRow(
                    title: 'loss_to_provider'.tr,
                    value: PriceConverter.convertPrice(payment.scaledLossProviderShare ?? 0, isShowLongPrice: true),
                  ),
              ],
            ),
          ),
        if (BookingHelper.canRecordCustomerPayment(bookingDetails))
          Padding(
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
            child: BookingOverviewSectionCard(
            title: 'record_payment'.tr,
            icon: Icons.add_card_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'record_payment_hint'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                CustomButton(
                  btnTxt: 'record_payment'.tr,
                  icon: Icons.payments_outlined,
                  onPressed: () {
                    final bookingId = BookingHelper.resolveRecordPaymentBookingId(
                      bookingDetails,
                      fallbackBookingId: parentBookingId,
                    );
                    if (bookingId.isEmpty) {
                      return;
                    }
                    showCustomBottomSheet(
                      child: RecordPaymentBottomSheet(
                        bookingDetails: bookingDetails,
                        bookingId: bookingId,
                        isSubBooking: isSubBooking,
                        subBookingId: subBookingId,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ),
        BookingPaymentHistoryView(bookingDetails: bookingDetails),
      ],
    );
  }

  Color _paymentStatusColor(BuildContext context, String? label) {
    final lower = (label ?? '').toLowerCase();
    if (lower.contains('settled')) {
      return Colors.green.shade700;
    }
    if (lower.contains('paid') && !lower.contains('un')) {
      return Colors.green;
    }
    if (lower.contains('partial')) {
      return Theme.of(context).primaryColor;
    }
    if (lower.contains('unpaid') || lower.contains('refund')) {
      return Theme.of(context).colorScheme.error;
    }
    return Theme.of(context).textTheme.bodyLarge!.color!;
  }
}
