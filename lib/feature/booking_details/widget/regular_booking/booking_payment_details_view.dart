import 'package:demandium_provider/feature/booking_details/widget/regular_booking/booking_overview_kv_row.dart';
import 'package:demandium_provider/feature/booking_details/widget/regular_booking/payment_info_view.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

/// Payment summary on booking details (no tabs — use Payments screen for Summary/Details).
class BookingPaymentDetailsView extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const BookingPaymentDetailsView({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    final payment = bookingDetails.paymentDetails;
    if (payment == null) {
      return PaymentInfoView(bookingDetails: bookingDetails);
    }

    return BookingOverviewSectionCard(
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
          if (payment.paymentMethodDisplay != null && payment.paymentMethodDisplay!.isNotEmpty)
            BookingOverviewKvRow(
              title: 'payment_method'.tr,
              value: payment.paymentMethodDisplay!,
            ),
          BookingOverviewKvRow(
            title: 'total_amount'.tr,
            value: PriceConverter.convertPrice(payment.total ?? 0, isShowLongPrice: true),
          ),
          BookingOverviewKvRow(
            title: (payment.showAsAmountPaidLabel == true ? 'amount_paid' : 'advance_paid').tr,
            value: PriceConverter.convertPrice(payment.amountPaidDisplay ?? 0, isShowLongPrice: true),
          ),
          if ((payment.dueBalance ?? 0) > 0)
            BookingOverviewKvRow(
              title: 'due_balance'.tr,
              value: PriceConverter.convertPrice(payment.dueBalance ?? 0, isShowLongPrice: true),
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
    );
  }

  Color _paymentStatusColor(BuildContext context, String? label) {
    final lower = (label ?? '').toLowerCase();
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
