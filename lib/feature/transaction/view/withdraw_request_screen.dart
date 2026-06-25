import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/feature/payments/controller/payments_controller.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class WithdrawRequestScreen extends StatefulWidget {
  final double? amount;

  const WithdrawRequestScreen({super.key, this.amount = 0.0});

  @override
  State<WithdrawRequestScreen> createState() => _WithdrawRequestScreenState();
}

class _WithdrawRequestScreenState extends State<WithdrawRequestScreen> {
  final TextEditingController _inputAmountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _inputAmountFocusNode = FocusNode();
  double? _availableAmount;

  @override
  void initState() {
    super.initState();
    _availableAmount = widget.amount;
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshAvailableAmount());
  }

  Future<void> _refreshAvailableAmount() async {
    if (!Get.isRegistered<PaymentsController>()) {
      return;
    }
    await Get.find<PaymentsController>().loadOverview();
    final max = Get.find<PaymentsController>().overview?.netBalance?.requestMaxAmount;
    if (!mounted || max == null) {
      return;
    }
    setState(() => _availableAmount = max);
  }

  double get _maxWithdrawAmount => _availableAmount ?? widget.amount ?? 0;

  @override
  void dispose() {
    _inputAmountController.dispose();
    _noteController.dispose();
    _inputAmountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'withdraw_request'.tr),
      body: GetBuilder<TransactionController>(
        builder: (transactionMoneyController) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: context.customThemeColors.lightShadow,
                    color: Theme.of(context).cardColor,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeLarge,
                  ),
                  margin: const EdgeInsets.fromLTRB(
                    Dimensions.paddingSizeSmall,
                    Dimensions.paddingSizeSmall,
                    Dimensions.paddingSizeSmall,
                    3,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputBoxView(
                        inputAmountController: _inputAmountController,
                        focusNode: _inputAmountFocusNode,
                        amount: _maxWithdrawAmount,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      CustomTextFormField(
                        inputType: TextInputType.text,
                        controller: _noteController,
                        hintText: 'write_note_your_here'.tr,
                        capitalization: TextCapitalization.sentences,
                        maxLines: 3,
                        maxLength: 255,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge * 4),
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GetBuilder<TransactionController>(
        builder: (transactionMoneyController) {
          final labelColor = Theme.of(context).textTheme.bodyLarge?.color ?? Theme.of(context).primaryColor;
          const sliderHeight = 52.0;
          const sliderButtonSize = 44.0;

          return Container(
            height: 72,
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeSmall,
              vertical: Dimensions.paddingSizeExtraSmall,
            ),
            child: Center(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SliderButton(
                  height: sliderHeight,
                  buttonSize: sliderButtonSize,
                  width: Get.width - Dimensions.paddingSizeDefault * 2,
                  dismissible: false,
                  shimmer: false,
                  action: _handleWithdrawRequest,
                  label: Padding(
                    padding: const EdgeInsets.only(left: sliderButtonSize),
                    child: Text(
                      'send_withdraw_request'.tr,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: labelColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  alignLabel: Alignment.center,
                  dismissThresholds: 0.5,
                  icon: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(Images.arrowButton),
                  ),
                  radius: Dimensions.radiusDefault,
                  boxShadow: const BoxShadow(blurRadius: 0.0),
                  buttonColor: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).hintColor.withValues(alpha: 0.12),
                  baseColor: labelColor,
                  highlightedColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleWithdrawRequest() async {
    final splashController = Get.find<SplashController>();
    final transactionController = Get.find<TransactionController>();

    final minimumWithdrawAmount = splashController.configModel.content?.minimumWithdrawAmount ?? 0;
    final maximumWithdrawAmount = splashController.configModel.content?.maximumWithdrawAmount ?? 0;

    if (_inputAmountController.text.isEmpty) {
      showCustomSnackBar('please_input_amount'.tr, type: ToasterMessageType.info);
      return;
    }

    final amount = PriceConverter.getAmountFromInputFormatter(_inputAmountController.text);

    if (amount < minimumWithdrawAmount) {
      showCustomSnackBar(
        '${'withdraw_amount_grater_than'.tr} ${PriceConverter.convertPrice(minimumWithdrawAmount)}',
        type: ToasterMessageType.info,
      );
      return;
    }

    if (amount > maximumWithdrawAmount) {
      showCustomSnackBar(
        "${'maximum_withdraw_amount_is'.tr} ${PriceConverter.convertPrice(maximumWithdrawAmount)}",
        type: ToasterMessageType.info,
      );
      return;
    }

    if (amount < maximumWithdrawAmount && amount > _maxWithdrawAmount) {
      showCustomSnackBar('insufficient_balance'.tr, type: ToasterMessageType.info);
      return;
    }

    showCustomDialog(child: const CustomLoader());

    final withdrawRequestBody = {
      'amount': '$amount',
      'note': _noteController.text.trim(),
    };

    await transactionController.withDrawRequest(placeBody: withdrawRequestBody);
  }
}
