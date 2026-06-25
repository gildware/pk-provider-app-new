import 'package:demandium_provider/feature/booking_details/widget/regular_booking/booking_overview_kv_row.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BookingLossMakingSettlementView extends StatelessWidget {
  final LossMakingSettlement settlement;

  const BookingLossMakingSettlementView({super.key, required this.settlement});

  @override
  Widget build(BuildContext context) {
    if (settlement.isLossMaking != true) {
      return const SizedBox.shrink();
    }

    final errorColor = Theme.of(context).colorScheme.error;

    return BookingOverviewSectionCard(
      title: 'special_financial_settlement'.tr,
      icon: Icons.account_balance_outlined,
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: errorColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: Text(
          'bfs_list_badge_loss_making'.tr,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: errorColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _priceRow('total_booking_amount'.tr, settlement.totalBookingAmount),
          _priceRow('amount_paid_by_customer'.tr, settlement.amountPaidByCustomer),
          _priceRow('loss_amount'.tr, settlement.lossAmount, valueColor: errorColor),
          _priceRow('loss_to_company'.tr, settlement.lossToCompany, valueColor: errorColor),
          _priceRow('loss_to_provider'.tr, settlement.lossToProvider, valueColor: errorColor),
          _priceRow('company_commission_full_booking'.tr, settlement.companyCommissionFullBooking),
          _priceRow('provider_share_before_loss_full_booking'.tr, settlement.providerShareBeforeLossFullBooking),
          _priceRow(
            'net_company_share_after_loss'.tr,
            settlement.netCompanyShareAfterLoss,
            valueStyle: robotoBold.copyWith(color: context.adaptivePrimaryColor),
          ),
          _priceRow(
            'net_provider_share_after_loss'.tr,
            settlement.netProviderShareAfterLoss,
            valueStyle: robotoBold.copyWith(color: context.adaptivePrimaryColor),
          ),
          if (settlement.notes != null && settlement.notes!.trim().isNotEmpty)
            BookingOverviewKvRow(
              title: 'notes'.tr,
              value: settlement.notes!.trim(),
            ),
        ],
      ),
    );
  }

  Widget _priceRow(
    String title,
    double? amount, {
    Color? valueColor,
    TextStyle? valueStyle,
  }) {
    return BookingOverviewKvRow(
      title: title,
      value: PriceConverter.convertPrice(amount ?? 0, isShowLongPrice: true),
      valueStyle: valueStyle ??
          (valueColor != null
              ? robotoMedium.copyWith(color: valueColor)
              : null),
    );
  }
}
