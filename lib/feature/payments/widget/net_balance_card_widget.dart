import 'package:get/get.dart';
import 'package:demandium_provider/feature/payments/model/provider_payments_model.dart';
import 'package:demandium_provider/util/core_export.dart';

class NetBalanceCardWidget extends StatelessWidget {
  final ProviderPaymentsNetBalance? net;
  final bool showActions;

  const NetBalanceCardWidget({
    super.key,
    required this.net,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final direction = net?.direction ?? 'settled';
    Color netColor = Theme.of(context).primaryColor;
    String? netHint;
    if (direction == 'company_pays_provider') {
      netColor = Colors.green;
      netHint = 'company_has_to_pay_to_provider'.tr;
    } else if (direction == 'provider_pays_company') {
      netColor = Theme.of(context).colorScheme.error;
      netHint = 'provider_has_to_pay_to_company'.tr;
    }

    final config = Get.find<SplashController>().configModel.content;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        border: Border.all(color: context.adaptivePrimaryColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'net_balance'.tr,
            textAlign: TextAlign.center,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            PriceConverter.convertPrice(net?.amount ?? 0),
            textAlign: TextAlign.center,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: netColor),
          ),
          if (netHint != null && netHint.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              netHint,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: netColor),
            ),
          ],
          if (showActions && net?.canRequestAmount == true && (net?.requestMaxAmount ?? 0) > 0) ...[
            const SizedBox(height: Dimensions.paddingSizeDefault),
            CustomButton(
              width: 220,
              height: 40,
              btnTxt: 'request_amount'.tr,
              onPressed: () => Get.to(() => WithdrawRequestScreen(amount: net!.requestMaxAmount)),
            ),
          ] else if (showActions && net?.canPay == true && (net?.payMaxAmount ?? 0) > 0) ...[
            const SizedBox(height: Dimensions.paddingSizeDefault),
            CustomButton(
              width: 220,
              height: 40,
              btnTxt: 'pay_now'.tr,
              onPressed: () {
                final payMax = net!.payMaxAmount ?? 0;
                if (config?.digitalPayment == 0) {
                  showCustomSnackBar('no_payment_option_available'.tr);
                  return;
                }
                final minimumPayable = config?.minimumPayableAmount ?? 0;
                if (minimumPayable > payMax) {
                  showCustomSnackBar('${'minimum_payable_amount'.tr} ${PriceConverter.convertPrice(minimumPayable)}');
                  return;
                }
                showModalBottomSheet(
                  context: context,
                  useRootNavigator: true,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (sheetContext) => PaymentMethodDialog(amount: payMax),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
