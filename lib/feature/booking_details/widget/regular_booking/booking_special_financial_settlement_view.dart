import 'package:demandium_provider/feature/booking_details/widget/regular_booking/booking_overview_kv_row.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BookingSpecialFinancialSettlementView extends StatelessWidget {
  final SpecialFinancialSettlement settlement;

  const BookingSpecialFinancialSettlementView({super.key, required this.settlement});

  @override
  Widget build(BuildContext context) {
    if (settlement.hasSpecialSettlement != true) {
      return const SizedBox.shrink();
    }

    final primaryColor = Theme.of(context).primaryColor;
    final scenarioLabel = _scenarioLabel(settlement.scenarioLabelKey);

    return BookingOverviewSectionCard(
      title: 'special_financial_settlement'.tr,
      icon: Icons.account_balance_outlined,
      trailing: scenarioLabel == null
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Text(
                scenarioLabel,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: primaryColor,
                ),
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _priceRow('final_booking_amount'.tr, settlement.finalBookingAmount, isBold: true),
          _priceRow('final_service_charges'.tr, settlement.finalServiceCharges),
          _priceRow('final_spare_parts_charges'.tr, settlement.finalSparePartsCharges),
          _priceRow(
            'final_admin_commission_net_basis'.tr,
            settlement.finalAdminCommission,
            valueStyle: robotoBold.copyWith(color: primaryColor),
          ),
          _priceRow(
            'final_provider_earning_net_basis'.tr,
            settlement.finalProviderEarning,
            valueStyle: robotoBold.copyWith(color: primaryColor),
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

  String? _scenarioLabel(String? key) {
    if (key == null || key.trim().isEmpty) {
      return null;
    }
    return key.tr;
  }

  Widget _priceRow(
    String title,
    double? amount, {
    bool isBold = false,
    TextStyle? valueStyle,
  }) {
    return BookingOverviewKvRow(
      title: title,
      value: PriceConverter.convertPrice(amount ?? 0, isShowLongPrice: true),
      valueStyle: valueStyle ??
          (isBold ? robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault) : null),
    );
  }
}
