import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

enum BookingProviderReasonDialogMode { cancel, reject }

class BookingCancelReasonDialog extends StatefulWidget {
  final String bookingId;
  final bool isSubBooking;
  final String currentBookingStatus;
  final BookingProviderReasonDialogMode mode;
  final bool popParentOnSuccess;

  const BookingCancelReasonDialog({
    super.key,
    required this.bookingId,
    required this.isSubBooking,
    required this.currentBookingStatus,
    this.mode = BookingProviderReasonDialogMode.cancel,
    this.popParentOnSuccess = false,
  });

  static void showReject({
    required String bookingId,
    bool isSubBooking = false,
    String currentBookingStatus = 'pending',
    bool popParentOnSuccess = false,
  }) {
    showCustomDialog(
      barrierDismissible: true,
      useSafeArea: false,
      child: BookingCancelReasonDialog(
        bookingId: bookingId,
        isSubBooking: isSubBooking,
        currentBookingStatus: currentBookingStatus,
        mode: BookingProviderReasonDialogMode.reject,
        popParentOnSuccess: popParentOnSuccess,
      ),
    );
  }

  @override
  State<BookingCancelReasonDialog> createState() => _BookingCancelReasonDialogState();
}

class _BookingCancelReasonDialogState extends State<BookingCancelReasonDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _noteController = TextEditingController();
  int? _selectedReasonId;
  List<BookingReasonModel> _reasons = [];
  bool _isLoadingReasons = true;
  bool _isSubmitting = false;

  bool get _isReject => widget.mode == BookingProviderReasonDialogMode.reject;

  @override
  void initState() {
    super.initState();
    _loadReasons();
  }

  Future<void> _loadReasons({bool forceReload = false}) async {
    final controller = Get.find<BookingDetailsController>();

    if (!forceReload && controller.providerCancellationReasons.isNotEmpty) {
      if (mounted) {
        setState(() {
          _reasons = List<BookingReasonModel>.from(controller.providerCancellationReasons);
          _isLoadingReasons = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _isLoadingReasons = true);
    }

    final reasons = await controller.getProviderCancellationReasons(forceReload: forceReload);
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
    return KeyboardAwareDialogShell(
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
                    _isReject
                        ? 'are_you_sure_to_reject_the_booking_request'.tr
                        : 'are_you_sure_to_cancel_this_booking'.tr,
                    textAlign: TextAlign.center,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Text(
                    _isReject
                        ? 'select_rejection_reason_hint'.tr
                        : 'select_cancellation_reason_hint'.tr,
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
                            'no_cancellation_reasons_configured'.tr,
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
                      _isReject ? 'rejection_reason'.tr : 'cancellation_reason'.tr,
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
                      hint: Text(
                        _isReject
                            ? 'select_rejection_reason'.tr
                            : 'select_cancellation_reason'.tr,
                      ),
                      items: _reasons.map((reason) {
                        return DropdownMenuItem<int>(
                          value: reason.id,
                          child: Text(reason.name ?? ''),
                        );
                      }).toList(),
                      onChanged: _isSubmitting
                          ? null
                          : (value) => setState(() => _selectedReasonId = value),
                      validator: (value) {
                        if (value == null) {
                          return _isReject
                              ? 'select_rejection_reason'.tr
                              : 'select_cancellation_reason'.tr;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Text(
                      'additional_note_optional'.tr,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    CustomTextFormField(
                      key: const ValueKey('provider_cancel_reason_note'),
                      controller: _noteController,
                      hintText: _isReject
                          ? 'rejection_note_optional_hint'.tr
                          : 'cancellation_note_optional_hint'.tr,
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
                          btnTxt: _isReject ? 'yes_reject'.tr : 'yes_cancel'.tr,
                          height: 40,
                          radius: Dimensions.radiusSmall,
                          color: Theme.of(context).colorScheme.error,
                          isLoading: _isSubmitting,
                          onPressed: _reasons.isEmpty || _isLoadingReasons || _isSubmitting
                              ? null
                              : _submit,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSubmitting = true);
    final controller = Get.find<BookingDetailsController>();
    var succeeded = false;

    try {
      if (_isReject) {
        succeeded = await controller.ignoreBookingRequest(
          widget.bookingId,
          providerCancellationReasonId: _selectedReasonId,
          statusChangeRemarks: _noteController.text.trim(),
        );
        if (succeeded) {
          _dismissAfterSuccess();
        }
        return;
      }

      controller.changeBookingStatusDropDownValue('canceled', widget.isSubBooking);
      succeeded = await controller.changeBookingStatus(
        widget.bookingId,
        bookingStatus: widget.currentBookingStatus,
        isSubBooking: widget.isSubBooking,
        providerCancellationReasonId: _selectedReasonId,
        statusChangeRemarks: _noteController.text.trim(),
        deferUiFeedback: true,
      );

      if (succeeded) {
        _dismissAfterSuccess(
          successMessage: controller.lastStatusUpdateMessage ??
              'provider_cancellation_request_received'.tr,
        );
      }
    } finally {
      if (mounted && !succeeded) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _dismissAfterSuccess({String? successMessage}) {
    if (!mounted) return;

    FocusManager.instance.primaryFocus?.unfocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (!widget.popParentOnSuccess) {
        if (successMessage != null && successMessage.isNotEmpty) {
          _showDeferredSnackBar(successMessage);
        }
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.key.currentState?.canPop() ?? false) {
          Get.back();
        }
        if (successMessage != null && successMessage.isNotEmpty) {
          _showDeferredSnackBar(successMessage);
        }
      });
    });
  }

  void _showDeferredSnackBar(String message) {
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      showCustomSnackBar(message, type: ToasterMessageType.success);
    });
  }
}
