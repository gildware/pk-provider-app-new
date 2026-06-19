import 'package:demandium_provider/helper/booking_helper.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class RecordPaymentBottomSheet extends StatefulWidget {
  final BookingDetailsContent bookingDetails;
  final String bookingId;
  final bool isSubBooking;
  final String? subBookingId;

  const RecordPaymentBottomSheet({
    super.key,
    required this.bookingDetails,
    required this.bookingId,
    required this.isSubBooking,
    this.subBookingId,
  });

  @override
  State<RecordPaymentBottomSheet> createState() => _RecordPaymentBottomSheetState();
}

class _RecordPaymentBottomSheetState extends State<RecordPaymentBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final due = BookingHelper.resolveBookingDueBalance(widget.bookingDetails);
    _amountController.text = _formatAmountForInput(due);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  String _formatAmountForInput(double amount) {
    if ((amount - amount.roundToDouble()).abs() < 0.001) {
      return amount.round().toString();
    }
    return amount.toStringAsFixed(2);
  }

  double get _dueBalance => BookingHelper.resolveBookingDueBalance(widget.bookingDetails);

  Future<void> _submitPayment(BookingDetailsController controller) async {
    if (_isSubmitting) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      showCustomSnackBar('enter_valid_amount'.tr, type: ToasterMessageType.info);
      return;
    }
    if (amount > _dueBalance + 0.009) {
      showCustomSnackBar('amount_exceeds_due_balance'.tr, type: ToasterMessageType.info);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isSubmitting = true);

    final success = await controller.recordCustomerPayment(
      bookingId: widget.bookingId,
      amount: amount,
      isSubBooking: widget.isSubBooking,
      subBookingId: widget.subBookingId,
      closeModalOnSuccess: true,
    );

    if (!mounted) return;
    if (!success) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _isSubmitting;

    return PopScope(
      canPop: !isLoading,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: GetBuilder<BookingDetailsController>(builder: (controller) {
        final showLoading = isLoading || controller.isRecordPaymentLoading;

        return Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text(
                'record_payment'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                'record_payment_hint'.tr,
                style: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('due_balance'.tr, style: robotoRegular),
                  Text(
                    PriceConverter.convertPrice(_dueBalance, isShowLongPrice: true),
                    style: robotoMedium.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              CustomTextField(
                controller: _amountController,
                focusNode: _amountFocusNode,
                inputType: const TextInputType.numberWithOptions(decimal: true),
                hintText: 'amount'.tr,
                title: 'amount_received_from_customer'.tr,
                isEnabled: !showLoading,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              CustomButton(
                btnTxt: 'submit'.tr,
                isLoading: showLoading,
                onPressed: showLoading ? null : () => _submitPayment(controller),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      }),
      ),
    );
  }
}
