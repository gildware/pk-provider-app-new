import 'package:demandium_provider/feature/payement_information/widgets/payment_info_card.dart';
import 'package:demandium_provider/feature/transaction/controller/transaction_controller.dart';
import 'package:demandium_provider/feature/transaction/model/dropdown_method_method.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

typedef WithdrawMethodFieldCallback = void Function(String id, String name, TransactionController controller);

class WithdrawMethodSelector extends StatelessWidget {
  final TransactionController transactionController;
  final WithdrawMethodFieldCallback? onSelectOtherMethod;

  const WithdrawMethodSelector({
    super.key,
    required this.transactionController,
    this.onSelectOtherMethod,
  });

  @override
  Widget build(BuildContext context) {
    final saved = transactionController.savedMethodList;
    final others = transactionController.othersMethodList;
    final selected = transactionController.selectedMethod;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (saved.isNotEmpty) ...[
          Text(
            'my_methods'.tr,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: context.adaptivePrimaryColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ...saved.map((method) => _MethodTile(
                method: method,
                isSelected: selected?.id == method.id && selected?.type == MethodType.myMethods,
                onTap: () => transactionController.onChangeMethod(method),
              )),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],

        if (others.isNotEmpty) ...[
          Text(
            'others'.tr,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: context.adaptivePrimaryColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ...others.map((method) => _MethodTile(
                method: method,
                isSelected: selected?.id == method.id && selected?.type == MethodType.others,
                onTap: () {
                  if (method.withdrawalMethod != null && onSelectOtherMethod != null) {
                    onSelectOtherMethod!(
                      method.withdrawalMethod!.id.toString(),
                      method.withdrawalMethod!.methodName.toString(),
                      transactionController,
                    );
                  }
                  transactionController.onChangeMethod(method);
                },
              )),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],

        if (saved.isEmpty && others.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Text(
              'no_payment_info_added_yet'.tr,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),

        _AddNewMethodButton(
          onPressed: () async {
            await Get.toNamed(RouteHelper.getAddPaymentInformationRoute());
            await transactionController.loadWithdrawMethodOptions(isReload: true);
          },
        ),

        if (selected?.type == MethodType.myMethods && selected?.paymentMethod != null) ...[
          const SizedBox(height: Dimensions.paddingSizeDefault),
          PaymentInfoCard(paymentMethod: selected!.paymentMethod),
        ],
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  final DropdownMethodModel method;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
                : Theme.of(context).hintColor.withValues(alpha: 0.06),
            border: Border.all(
              color: isSelected
                   ? context.tabSelectedColor
                  : Theme.of(context).hintColor.withValues(alpha: 0.25),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? context.tabSelectedColor : Theme.of(context).hintColor,
                size: 22,
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Text(
                  method.inputName ?? '—',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
              ),
              if (method.isDefault == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Theme.of(context).primaryColorLight),
                  ),
                  child: Text(
                    'default'.tr,
                    style: robotoRegular.copyWith(
                      color: Theme.of(context).primaryColorLight,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddNewMethodButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddNewMethodButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeDefault,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: context.adaptivePrimaryColor.withValues(alpha: 0.5),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: context.adaptivePrimaryColor, size: 22),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text(
              'add_new_withdraw_method'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: context.adaptivePrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
