import 'package:get/get.dart';
import 'package:demandium_provider/feature/payments/model/provider_payments_model.dart';
import 'package:demandium_provider/feature/payments/widget/net_balance_card_widget.dart';
import 'package:demandium_provider/util/core_export.dart';

class PaymentsSummarySection extends StatelessWidget {
  final ProviderPaymentsOverview? overview;
  const PaymentsSummarySection({super.key, required this.overview});

  @override
  Widget build(BuildContext context) {
    if (overview == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NetBalanceCardWidget(net: overview!.netBalance),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(children: [
            Expanded(child: _miniStat(context, 'total_revenue'.tr, overview!.totalRevenue)),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: _miniStat(context, 'provider_earning'.tr, overview!.providerNetEarning)),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(children: [
            Expanded(child: _miniStat(context, 'total_company_commission'.tr, overview!.totalCompanyCommission)),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: _miniStat(context, 'provider_loss_absorbed_total'.tr, overview!.providerLossAbsorbedTotal, valueColor: Theme.of(context).colorScheme.error)),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _miniStat(context, 'company_loss_absorbed_total'.tr, overview!.companyLossAbsorbedTotal, valueColor: Theme.of(context).colorScheme.error),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          _sectionTitle('compensation'.tr),
          Row(children: [
            Expanded(child: _miniStat(context, 'provider_compensated_to_customers'.tr, overview!.compensation?.providerCompensatedToCustomers, valueColor: Theme.of(context).colorScheme.error)),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: _miniStat(context, 'company_compensated_to_provider'.tr, overview!.compensation?.companyCompensatedToProvider)),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          _sectionTitle('provider_payment_receipts_section'.tr),
          Row(children: [
            Expanded(child: _miniStat(context, 'provider_payment_total_from_company'.tr, overview!.receipts?.fromCompany)),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: _miniStat(context, 'provider_payment_total_from_customer'.tr, overview!.receipts?.fromCustomer)),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _statCard(
            context,
            title: 'provider_payment_total_received'.tr,
            amount: PriceConverter.convertPrice(overview!.receipts?.total ?? 0),
            amountColor: context.tabSelectedColor,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeExtraSmall),
      child: Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
    );
  }

  Widget _statCard(BuildContext context, {
    required String title,
    required String amount,
    required Color amountColor,
    String? subtitle,
    bool highlight = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: highlight
              ? Theme.of(context).primaryColor.withValues(alpha: 0.35)
              : Theme.of(context).hintColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(amount, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: amountColor)),
          if (subtitle != null && subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: amountColor)),
          ],
        ],
      ),
    );
  }

  Widget _miniStat(BuildContext context, String title, double? value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text(
            PriceConverter.convertPrice(value ?? 0),
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: valueColor ?? Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
