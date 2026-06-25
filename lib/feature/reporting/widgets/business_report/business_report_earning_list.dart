import 'package:demandium_provider/feature/reporting/model/business_report_earning_model.dart';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class BusinessReportEarningListView extends StatelessWidget {
  final List<BusinessReportEarningFilterData> filterData;
  const BusinessReportEarningListView({super.key, required this.filterData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        filterData.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: Dimensions.paddingSizeDefault,
                  bottom: Dimensions.paddingSizeDefault,
                ),
                itemBuilder: (context, index) {
                  return _EarningBookingCard(item: filterData[index]);
                },
                itemCount: filterData.length,
              )
            : SizedBox(
                height: Get.height * 0.33,
                child: const Center(
                  child: NoDataScreen(text: "", type: NoDataType.others),
                ),
              ),
        if (Get.find<BusinessReportController>().loading)
          const Padding(
            padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Center(child: CircularProgressIndicator()),
          )
      ],
    );
  }
}

class _EarningBookingCard extends StatelessWidget {
  final BusinessReportEarningFilterData item;

  const _EarningBookingCard({required this.item});

  static bool _hasAmount(double? value) => (value ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    final amounts = item.bookingDetailsAmounts;
    final netProfit = amounts?.providerEarning ?? 0;

    final discountRows = <Widget?>[
      _amountRow(
        context,
        label: 'total_service_discount'.tr,
        amount: item.totalDiscountAmount,
      ),
      _amountRow(
        context,
        label: 'provider_paid_service_discount'.tr,
        amount: amounts?.discountByProvider,
      ),
      _amountRow(
        context,
        label: 'total_coupon_discount'.tr,
        amount: item.totalCouponDiscountAmount,
      ),
      _amountRow(
        context,
        label: 'provider_paid_coupon_discount'.tr,
        amount: amounts?.couponDiscountByProvider,
      ),
      _amountRow(
        context,
        label: 'total_campaign_discount'.tr,
        amount: item.totalCampaignDiscountAmount,
      ),
      _amountRow(
        context,
        label: 'provider_paid_campaign_discount'.tr,
        amount: amounts?.campaignDiscountByProvider,
      ),
    ].whereType<Widget>().toList();

    final summaryRows = <Widget?>[
      if (_hasAmount(item.totalBookingAmount))
        _amountRow(
          context,
          label: 'sub_total'.tr,
          amount: item.totalBookingAmount,
          labelStyle: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.8),
          ),
          valueStyle: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.8),
          ),
        ),
      _amountRow(
        context,
        label: 'admin_commission'.tr,
        amount: amounts?.adminCommission,
      ),
      _amountRow(
        context,
        label: '${'vat/tax'.tr} : ',
        amount: item.totalTaxAmount,
      ),
    ].whereType<Widget>().toList();

    final detailChildren = <Widget>[];
    if (discountRows.isNotEmpty) {
      detailChildren.addAll(discountRows);
      detailChildren.add(const SizedBox(height: Dimensions.paddingSizeSmall));
      detailChildren.add(
        CustomDivider(color: Theme.of(context).hintColor.withValues(alpha: 0.2), width: 3.0),
      );
      detailChildren.add(const SizedBox(height: Dimensions.paddingSizeSmall));
    }
    if (summaryRows.isNotEmpty) {
      detailChildren.addAll(summaryRows);
      detailChildren.add(const SizedBox(height: Dimensions.paddingSizeSmall));
      detailChildren.add(
        CustomDivider(color: Theme.of(context).hintColor.withValues(alpha: 0.2), width: 3.0),
      );
      detailChildren.add(const SizedBox(height: Dimensions.paddingSizeSmall));
    }

    detailChildren.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'provider_net_income'.tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.8),
            ),
          ),
          Text(
            PriceConverter.convertPrice(netProfit),
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: context.adaptivePrimaryColor,
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeExtraSmall,
        horizontal: Dimensions.paddingSizeDefault,
      ),
      child: Container(
        width: Get.width,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor.withValues(alpha: Get.isDarkMode ? 0.5 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: context.adaptivePrimaryColor.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radiusSmall),
                  topRight: Radius.circular(Dimensions.radiusSmall),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              'booking_id'.tr,
                              style: robotoMedium.copyWith(
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                ' #${item.readableId.toString()}',
                                style: robotoMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.bookingStatus != null &&
                          item.bookingStatus!.isNotEmpty)
                        _BookingStatusChip(status: item.bookingStatus!),
                    ],
                  ),
                  if (_hasAmount(item.totalBookingAmount)) ...[
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'booking_amount'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.8),
                          ),
                        ),
                        Text(
                          PriceConverter.convertPrice(item.totalBookingAmount),
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: context.adaptivePrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: detailChildren,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget? _amountRow(
    BuildContext context, {
    required String label,
    required double? amount,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    if (!_hasAmount(amount)) {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: labelStyle ??
                robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).hintColor,
                ),
          ),
          Text(
            PriceConverter.convertPrice(amount),
            style: valueStyle ??
                robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }
}

class _BookingStatusChip extends StatelessWidget {
  final String status;

  const _BookingStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = context.customThemeColors.buttonBackgroundColorMap[status]
        ?.withValues(alpha: 0.12);
    final textColor = context.customThemeColors.buttonTextColorMap[status] ??
        Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Text(
        status.tr,
        style: robotoMedium.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: textColor,
        ),
      ),
    );
  }
}
