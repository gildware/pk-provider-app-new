import 'package:demandium_provider/feature/payments/controller/payments_controller.dart';
import 'package:demandium_provider/feature/payments/widget/net_balance_card_widget.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class DashboardNetBalanceWidget extends StatelessWidget {
  const DashboardNetBalanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaymentsController>(builder: (paymentsController) {
      if (paymentsController.overviewLoading && paymentsController.overview == null) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            interval: const Duration(seconds: 1),
            color: Theme.of(context).hintColor.withValues(alpha: 0.2),
            colorOpacity: 0.3,
            enabled: true,
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).cardColor,
              ),
            ),
          ),
        );
      }

      final net = paymentsController.overview?.netBalance;
      if (net == null) {
        return const SizedBox();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: NetBalanceCardWidget(net: net),
      );
    });
  }
}
