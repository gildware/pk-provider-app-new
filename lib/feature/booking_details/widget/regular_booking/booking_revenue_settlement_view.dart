import 'package:demandium_provider/feature/booking_details/widget/regular_booking/booking_overview_kv_row.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BookingRevenueSettlementView extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  const BookingRevenueSettlementView({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    final revenue = bookingDetails.revenueSettlement;
    if (revenue == null) {
      return const SizedBox.shrink();
    }

    return BookingOverviewSectionCard(
      title: 'revenue_and_settlement'.tr,
      icon: Icons.account_balance_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (revenue.showBreakdown != true)
            _messageBox(
              context,
              'no_revenue_cancelled_before_service'.tr,
              Theme.of(context).disabledColor.withValues(alpha: 0.15),
            )
          else ...[
            _shareRow(context, revenue),
            BookingOverviewKvRow(
              title: 'earning_report_received_by_company'.tr,
              value: PriceConverter.convertPrice(revenue.amountReceivedByCompany ?? 0, isShowLongPrice: true),
            ),
            BookingOverviewKvRow(
              title: 'earning_report_received_by_provider'.tr,
              value: PriceConverter.convertPrice(revenue.amountReceivedByProvider ?? 0, isShowLongPrice: true),
            ),
            if ((revenue.scaledLossWriteoffAmount ?? 0) > 0)
              BookingOverviewKvRow(
                title: 'write_off_amount'.tr,
                value: PriceConverter.convertPrice(revenue.scaledLossWriteoffAmount ?? 0, isShowLongPrice: true),
              ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            _settlementAlert(context, revenue),
          ],
        ],
      ),
    );
  }

  Widget _shareRow(BuildContext context, RevenueSettlement revenue) {
    final companyShare = revenue.companyShare ?? 0;
    final providerShare = revenue.providerShare ?? 0;
    return Column(
      children: [
        BookingOverviewKvRow(
          title: companyShare < -0.009 ? 'company_loss_net'.tr : 'company_share_commission'.tr,
          value: PriceConverter.convertPrice(companyShare, isShowLongPrice: true),
          valueStyle: robotoBold.copyWith(
            color: companyShare < -0.009 ? Theme.of(context).colorScheme.error : context.tabSelectedColor,
          ),
        ),
        BookingOverviewKvRow(
          title: providerShare < -0.009 ? 'provider_loss_net'.tr : 'provider_share'.tr,
          value: PriceConverter.convertPrice(providerShare, isShowLongPrice: true),
          valueStyle: robotoBold.copyWith(
            color: providerShare < -0.009 ? Theme.of(context).colorScheme.error : null,
          ),
        ),
      ],
    );
  }

  Widget _settlementAlert(BuildContext context, RevenueSettlement revenue) {
    if (revenue.netRevenueZeroedAfterRefund == true) {
      return Column(
        children: [
          _messageBox(context, 'net_settlement_zero_after_full_refund_hint'.tr, Theme.of(context).disabledColor.withValues(alpha: 0.2)),
          if ((revenue.payToProvider ?? 0) > 0)
            _messageBox(
              context,
              '${'pay_to_provider'.tr}: ${PriceConverter.convertPrice(revenue.payToProvider ?? 0, isShowLongPrice: true)}',
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
          if ((revenue.providerOwesCompany ?? 0) > 0)
            _messageBox(
              context,
              '${'earning_report_provider_owes_company'.tr}: ${PriceConverter.convertPrice(revenue.providerOwesCompany ?? 0, isShowLongPrice: true)}',
              Colors.orange.withValues(alpha: 0.15),
            ),
        ],
      );
    }
    if ((revenue.payToProvider ?? 0) > 0) {
      return _messageBox(
        context,
        '${'pay_to_provider'.tr}: ${PriceConverter.convertPrice(revenue.payToProvider ?? 0, isShowLongPrice: true)}',
        Theme.of(context).primaryColor.withValues(alpha: 0.1),
      );
    }
    if ((revenue.providerOwesCompany ?? 0) > 0) {
      return _messageBox(
        context,
        '${'earning_report_provider_owes_company'.tr}: ${PriceConverter.convertPrice(revenue.providerOwesCompany ?? 0, isShowLongPrice: true)}',
        Colors.orange.withValues(alpha: 0.15),
      );
    }
    final key = revenue.settlementMessageKey ?? 'unpaid_or_partially_paid';
    return _messageBox(context, _settlementMessage(key), Theme.of(context).disabledColor.withValues(alpha: 0.15));
  }

  String _settlementMessage(String key) {
    switch (key) {
      case 'net_settlement_zero_after_full_refund':
        return 'net_settlement_zero_after_full_refund_hint'.tr;
      case 'provider_owes_company':
        return 'settlement_provider_owes_company'.tr;
      default:
        return key.tr;
    }
  }

  Widget _messageBox(BuildContext context, String text, Color bg) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Text(text, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
    );
  }
}
