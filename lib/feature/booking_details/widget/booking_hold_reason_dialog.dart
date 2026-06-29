import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BookingHoldReasonDialog extends StatefulWidget {
  final String bookingId;
  final bool isSubBooking;
  final String currentBookingStatus;

  const BookingHoldReasonDialog({
    super.key,
    required this.bookingId,
    required this.isSubBooking,
    required this.currentBookingStatus,
  });

  @override
  State<BookingHoldReasonDialog> createState() => _BookingHoldReasonDialogState();
}

class _BookingHoldReasonDialogState extends State<BookingHoldReasonDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _noteController = TextEditingController();
  int? _selectedReasonId;
  List<BookingReasonModel> _reasons = [];
  bool _isLoadingReasons = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadReasons();
  }

  Future<void> _loadReasons({bool forceReload = false}) async {
    final controller = Get.find<BookingDetailsController>();

    if (!forceReload && controller.providerHoldReasons.isNotEmpty) {
      if (mounted) {
        setState(() {
          _reasons = List<BookingReasonModel>.from(controller.providerHoldReasons);
          _isLoadingReasons = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _isLoadingReasons = true);
    }

    final reasons = await controller.getProviderHoldReasons(forceReload: forceReload);
    if (mounted) {
      setState(() {
        _reasons = reasons;
        _isLoadingReasons = false;
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: KeyboardAwareDialogShell(
        child: Material(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
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
                      'want_to_put_booking_on_hold'.tr,
                      textAlign: TextAlign.center,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      'select_hold_reason_hint'.tr,
                      textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    if (_isLoadingReasons)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_reasons.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                        child: Column(
                          children: [
                            Text(
                              'no_hold_reasons_configured'.tr,
                              textAlign: TextAlign.center,
                              style: robotoRegular.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            TextButton(
                              onPressed: () => _loadReasons(forceReload: true),
                              child: Text('try_again'.tr),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      Text(
                        'hold_reason'.tr,
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
                        hint: Text('select_hold_reason'.tr),
                        items: _reasons.map((reason) {
                          return DropdownMenuItem<int>(
                            value: reason.id,
                            child: Text(reason.name ?? ''),
                          );
                        }).toList(),
                        onChanged: _isSubmitting
                            ? null
                            : (value) => setState(() => _selectedReasonId = value),
                        validator: (value) => value == null ? 'select_hold_reason'.tr : null,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text(
                        'additional_note_optional'.tr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      CustomTextFormField(
                        key: const ValueKey('provider_hold_reason_note'),
                        controller: _noteController,
                        hintText: 'hold_note_optional_hint'.tr,
                        inputType: TextInputType.multiline,
                        maxLines: 3,
                        capitalization: TextCapitalization.sentences,
                        isShowBorder: true,
                        borderRadius: Dimensions.radiusSmall,
                      ),
                    ],
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: _isSubmitting ? null : () => Get.back(),
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
                            btnTxt: 'put_on_hold'.tr,
                            height: 40,
                            radius: Dimensions.radiusSmall,
                            isLoading: _isSubmitting,
                            onPressed: _reasons.isEmpty || _isLoadingReasons || _isSubmitting
                                ? null
                                : _submitHold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitHold() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSubmitting = true);
    final controller = Get.find<BookingDetailsController>();

    try {
      controller.changeBookingStatusDropDownValue('on_hold', widget.isSubBooking);
      final isSuccess = await controller.changeBookingStatus(
        widget.bookingId,
        bookingStatus: widget.currentBookingStatus,
        isSubBooking: widget.isSubBooking,
        holdReopenReasonId: _selectedReasonId,
        statusChangeRemarks: _noteController.text.trim(),
      );

      if (isSuccess && mounted) {
        Get.back();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
