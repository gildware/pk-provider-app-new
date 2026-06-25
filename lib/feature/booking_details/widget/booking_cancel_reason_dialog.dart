import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BookingCancelReasonDialog extends StatefulWidget {
  final String bookingId;
  final bool isSubBooking;
  final String currentBookingStatus;

  const BookingCancelReasonDialog({
    super.key,
    required this.bookingId,
    required this.isSubBooking,
    required this.currentBookingStatus,
  });

  @override
  State<BookingCancelReasonDialog> createState() => _BookingCancelReasonDialogState();
}

class _BookingCancelReasonDialogState extends State<BookingCancelReasonDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _noteController = TextEditingController();
  int? _selectedReasonId;

  @override
  void initState() {
    super.initState();
    Get.find<BookingDetailsController>().getProviderCancellationReasons();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      backgroundColor: Theme.of(context).cardColor,
      child: SizedBox(
        width: 420,
        child: GetBuilder<BookingDetailsController>(
          builder: (controller) {
            final reasons = controller.providerCancellationReasons;

            return Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Image.asset(Images.warning, width: 50, height: 50),
                    ),
                    Text(
                      'are_you_sure_to_cancel_this_booking'.tr,
                      textAlign: TextAlign.center,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      'select_cancellation_reason_hint'.tr,
                      textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    if (controller.isLoadingCancellationReasons)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (reasons.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                        child: Text(
                          'no_cancellation_reasons_configured'.tr,
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error),
                        ),
                      )
                    else ...[
                      Text(
                        'cancellation_reason'.tr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      DropdownButtonFormField<int>(
                        value: _selectedReasonId,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeSmall,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                        ),
                        hint: Text('select_cancellation_reason'.tr),
                        items: reasons.map((reason) {
                          return DropdownMenuItem<int>(
                            value: reason.id,
                            child: Text(reason.name ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedReasonId = value),
                        validator: (value) => value == null ? 'select_cancellation_reason'.tr : null,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text(
                        'additional_note_optional'.tr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      CustomTextFormField(
                        controller: _noteController,
                        hintText: 'cancellation_note_optional_hint'.tr,
                        inputType: TextInputType.multiline,
                        maxLines: 3,
                        capitalization: TextCapitalization.sentences,
                      ),
                    ],
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: controller.isStatusUpdateLoading ? null : () => Get.back(),
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context).hintColor.withValues(alpha: 0.3),
                              minimumSize: const Size(Dimensions.webMaxWidth, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                            ),
                            child: Text(
                              'cancel'.tr,
                              style: robotoBold.copyWith(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Expanded(
                          child: CustomButton(
                            btnTxt: 'yes_cancel'.tr,
                            height: 40,
                            radius: Dimensions.radiusSmall,
                            color: Theme.of(context).colorScheme.error,
                            isLoading: controller.isStatusUpdateLoading,
                            onPressed: reasons.isEmpty || controller.isLoadingCancellationReasons
                                ? null
                                : () => _submitCancel(controller),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submitCancel(BookingDetailsController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    controller.changeBookingStatusDropDownValue('canceled', widget.isSubBooking);
    final isSuccess = await controller.changeBookingStatus(
      widget.bookingId,
      bookingStatus: widget.currentBookingStatus,
      isSubBooking: widget.isSubBooking,
      providerCancellationReasonId: _selectedReasonId,
      statusChangeRemarks: _noteController.text.trim(),
    );

    if (isSuccess && mounted) {
      Get.back();
    }
  }
}
