import 'package:demandium_provider/feature/nav/widgets/cash_overflow_dialog.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

/// Cash-in-hand overflow banner; isolated from [GetMaterialApp] so profile
/// updates do not rebuild the main navigation tree.
class CashOverflowOverlay extends StatelessWidget {
  const CashOverflowOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(builder: (userProfileController) {
      final receivableAmount = double.tryParse(
            userProfileController.providerModel?.content?.providerInfo?.owner?.account?.accountReceivable ?? '0',
          ) ??
          0;
      final payableAmount = double.tryParse(
            userProfileController.providerModel?.content?.providerInfo?.owner?.account?.accountPayable ?? '0',
          ) ??
          0;

      final transactionType = userProfileController.getTransactionType(payableAmount, receivableAmount);
      final transactionAmount = userProfileController.getTransactionAmountAmount(payableAmount, receivableAmount);
      final maxCashLimit = Get.find<SplashController>().configModel.content?.maxCashInHandLimit ?? 0;
      final payablePercent = userProfileController.providerModel != null
          ? userProfileController.getOverflowPercent(payableAmount, receivableAmount, maxCashLimit)
          : 0.0;

      final config = Get.find<SplashController>().configModel.content;
      final overFlowDialogStatus = userProfileController.showOverflowDialog &&
          userProfileController.providerModel != null &&
          config?.suspendOnCashInHandLimit == 1 &&
          config?.digitalPayment == 1;

      final shouldShow = (transactionType == TransactionType.payable ||
              transactionType == TransactionType.adjustAndPayable ||
              transactionType == TransactionType.adjust) &&
          payablePercent >= 80 &&
          overFlowDialogStatus &&
          !userProfileController.trialWidgetNotShow;

      if (!shouldShow) {
        return const SizedBox.shrink();
      }

      return SafeArea(
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 90),
            child: CashOverflowDialog(
              payablePercent: payablePercent,
              amount: transactionAmount,
            ),
          ),
        ),
      );
    });
  }
}
