import 'package:demandium_provider/feature/booking_details/widget/regular_booking/booking_overview_kv_row.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BookingDisputedSettlementView extends StatelessWidget {
  final DisputedSettlement settlement;

  const BookingDisputedSettlementView({super.key, required this.settlement});

  @override
  Widget build(BuildContext context) {
    if (settlement.hasDisputedSettlement != true) {
      return const SizedBox.shrink();
    }

    final customerPaid = settlement.customerPaidTotal ?? 0;
    final refundTotal = settlement.refundTotal ?? 0;
    final finalAmount = settlement.finalBookingAmount ?? settlement.retainedFromCustomer ?? 0;

    return BookingOverviewSectionCard(
      title: 'disputed_settlement'.tr,
      icon: Icons.gavel_outlined,
      trailing: settlement.isFullRefund == true
          ? _badge(context, 'booking_tag_refund_full'.tr, Colors.red.shade700)
          : settlement.isPartialRefund == true
              ? _badge(context, 'booking_tag_refund_partial'.tr, Colors.orange.shade800)
              : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookingOverviewKvRow(
            title: 'customer_paid_total'.tr,
            value: PriceConverter.convertPrice(customerPaid, isShowLongPrice: true),
          ),
          if (refundTotal > 0.009)
            BookingOverviewKvRow(
              title: 'refunded_amount'.tr,
              value: '-${PriceConverter.convertPrice(refundTotal, isShowLongPrice: true)}',
              valueStyle: robotoMedium.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          if ((settlement.pendingRefund ?? 0) > 0.009)
            BookingOverviewKvRow(
              title: 'pending_refund'.tr,
              value: PriceConverter.convertPrice(settlement.pendingRefund ?? 0, isShowLongPrice: true),
              valueStyle: robotoMedium.copyWith(color: Colors.orange.shade800),
            ),
          BookingOverviewKvRow(
            title: 'final_booking_amount'.tr,
            value: PriceConverter.convertPrice(finalAmount, isShowLongPrice: true),
            valueStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
          ),
          if ((settlement.finalAdminCommission ?? 0) > 0.009)
            BookingOverviewKvRow(
              title: 'final_admin_commission_net_basis'.tr,
              value: PriceConverter.convertPrice(settlement.finalAdminCommission ?? 0, isShowLongPrice: true),
            ),
          if ((settlement.finalProviderEarning ?? 0) > 0.009)
            BookingOverviewKvRow(
              title: 'final_provider_earning_net_basis'.tr,
              value: PriceConverter.convertPrice(settlement.finalProviderEarning ?? 0, isShowLongPrice: true),
            ),
        ],
      ),
    );
  }

  Widget _badge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Text(
        label,
        style: robotoMedium.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall,
          color: color,
        ),
      ),
    );
  }
}
