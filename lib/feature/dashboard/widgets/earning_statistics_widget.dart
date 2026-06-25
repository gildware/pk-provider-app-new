import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EarningStatisticsWidget extends StatelessWidget {
  const EarningStatisticsWidget({super.key});


  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardController) {
        final earningData = dashboardController.earningDataModel;

        return Skeletonizer(
          enabled: earningData == null,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: context.customThemeColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeDefault,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'earning_statistics'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.8),
                        ),
                      ),
                      const Spacer(),

                      InkWell(
                        onTap: () {
                          Get.to(() => const BusinessReport());
                        },
                        child: Text(
                          'view_all'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: context.adaptivePrimaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _EarningCard(
                          period: 'this_week'.tr,
                          amount: earningData?.thisWeek?.total ?? 0.0,
                          change: earningData?.thisWeek?.change ?? 0.0,
                          periodLabel: 'from_last_week'.tr,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        _EarningCard(
                          period: 'this_month'.tr,
                          amount: earningData?.thisMonth?.total ?? 0.0,
                          change: earningData?.thisMonth?.change ?? 0.0,
                          periodLabel: 'from_last_month'.tr,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        _EarningCard(
                          period: 'this_year'.tr,
                          amount: earningData?.thisYear?.total ?? 0.0,
                          change: earningData?.thisYear?.change ?? 0.0,
                          periodLabel: 'from_last_year'.tr,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EarningCard extends StatelessWidget {
  final String period;
  final double amount;
  final double change;
  final String periodLabel;

  const _EarningCard({
    required this.period,
    required this.amount,
    required this.change,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changeIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(color: context.customThemeColors.earningStatisticBorderColor!),
        boxShadow: context.customThemeColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text(
            PriceConverter.convertPrice(amount, isShowLongPrice: true),
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: context.adaptivePrimaryColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(children: [
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(
                color: changeColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                changeIcon,
                size: Dimensions.paddingSizeSmall,
                color: changeColor,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            Text(
              '${isPositive ? '+' : ''}$change% $periodLabel',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .color!
                    .withValues(alpha: 0.6),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}