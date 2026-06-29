import 'package:demandium_provider/helper/booking_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class ChangeStatusDropdownButton extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final String bookingId;
  final bool isSubBooking;

  const ChangeStatusDropdownButton({
    super.key,
    required this.bookingDetails,
    required this.bookingId,
    required this.isSubBooking,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(builder: (bookingDetailsController) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Get.isDarkMode
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                  : Theme.of(context).primaryColor.withValues(alpha: 0.07),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: Dimensions.paddingSizeDefault,
            right: Dimensions.paddingSizeDefault,
            top: Dimensions.paddingSizeDefault,
          ),
          child: bookingDetailsController.isStatusUpdateLoading
              ? const SizedBox(
                  height: 48,
                  child: Center(
                    child: SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : _buildStatusActions(context, bookingDetailsController),
        ),
      );
    });
  }

  Widget _buildStatusActions(
    BuildContext context,
    BookingDetailsController controller,
  ) {
    final status = isSubBooking
        ? controller.subBookingDetails?.content?.bookingStatus
        : controller.bookingDetails?.content?.bookingStatus;
    switch (status ?? bookingDetails.bookingStatus) {
      case 'pending':
        return _buildPendingActions(context, controller);
      case 'accepted':
        return _buildAcceptedActions(context, controller);
      case 'pending_cancellation':
        return _buildPendingCancellationInfo(context);
      case 'ongoing':
        return _buildOngoingActions(context, controller);
      case 'on_hold':
        return _buildOnHoldActions(context, controller);
      default:
        return const SizedBox();
    }
  }

  Widget _buildPendingActions(
    BuildContext context,
    BookingDetailsController controller,
  ) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            btnTxt: 'accept'.tr,
            color: context.adaptivePrimaryColor.withValues(alpha: 0.1),
            textColor: _actionButtonTextColor(
              context,
              context.adaptivePrimaryColor,
            ),
            fontSize: Dimensions.fontSizeDefault,
            isLoading: controller.isAcceptButtonLoading,
            onPressed: controller.isIgnoreButtonLoading
                ? () {}
                : () => _showAcceptConfirmation(controller),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(
          child: CustomButton(
            btnTxt: 'reject'.tr,
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
            textColor: _actionButtonTextColor(
              context,
              Theme.of(context).colorScheme.error,
            ),
            fontSize: Dimensions.fontSizeDefault,
            isLoading: controller.isIgnoreButtonLoading,
            onPressed: controller.isAcceptButtonLoading
                ? () {}
                : () => _showRejectConfirmation(context, controller),
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptedActions(
    BuildContext context,
    BookingDetailsController controller,
  ) {
    final canCancel = _canCancelBooking(controller);

    return Row(
      children: [
        if (canCancel) ...[
          Expanded(
            child: CustomButton(
              btnTxt: 'cancel'.tr,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              textColor: _actionButtonTextColor(
                context,
                Theme.of(context).colorScheme.error,
              ),
              fontSize: Dimensions.fontSizeDefault,
              onPressed: () => _showCancelReasonDialog(context),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
        ],
        Expanded(
          child: CustomButton(
            btnTxt: 'start_work'.tr,
            color: context.adaptivePrimaryColor.withValues(alpha: 0.1),
            textColor: _actionButtonTextColor(
              context,
              context.adaptivePrimaryColor,
            ),
            fontSize: Dimensions.fontSizeDefault,
            onPressed: () => _showStatusChangeConfirmation(
              context: context,
              controller: controller,
              targetStatus: 'ongoing',
              title: 'want_to_start_work_on_this_booking'.tr,
              description: 'start_work_booking_hint_text'.tr,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingCancellationInfo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Text(
        'provider_cancellation_pending_message'.tr,
        textAlign: TextAlign.center,
        style: robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Color _actionButtonTextColor(BuildContext context, Color lightModeColor) {
    return Get.isDarkMode ? Colors.white : lightModeColor;
  }

  Widget _buildOnHoldActions(
    BuildContext context,
    BookingDetailsController controller,
  ) {
    final holdAfterVisit = BookingHelper.isHoldAfterVisit(bookingDetails);
    final targetStatus = BookingHelper.resolveUnholdTargetStatus(bookingDetails);

    return CustomButton(
      btnTxt: holdAfterVisit ? 'resume_work'.tr : 'remove_from_hold'.tr,
      color: context.adaptivePrimaryColor.withValues(alpha: 0.1),
      textColor: _actionButtonTextColor(
        context,
        context.adaptivePrimaryColor,
      ),
      fontSize: Dimensions.fontSizeDefault,
      onPressed: () => _showStatusChangeConfirmation(
        context: context,
        controller: controller,
        targetStatus: targetStatus,
        title: holdAfterVisit
            ? 'want_to_resume_work_on_this_booking'.tr
            : 'want_to_remove_booking_from_hold'.tr,
        description: holdAfterVisit
            ? 'resume_work_booking_hint_text'.tr
            : 'remove_from_hold_booking_hint_text'.tr,
        yesButtonText: holdAfterVisit ? 'resume_work'.tr : 'remove_from_hold'.tr,
      ),
    );
  }

  Widget _buildOngoingActions(
    BuildContext context,
    BookingDetailsController controller,
  ) {
    final canComplete = BookingHelper.canCompleteBooking(bookingDetails);

    return Row(
      children: [
        Expanded(
          child: CustomButton(
            btnTxt: 'put_on_hold'.tr,
            color: Theme.of(context).hintColor.withValues(alpha: 0.15),
            textColor: _actionButtonTextColor(
              context,
              Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
            ),
            fontSize: Dimensions.fontSizeDefault,
            onPressed: () => _showHoldReasonDialog(context),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(
          child: CustomButton(
            btnTxt: 'completed'.tr,
            color: context.adaptivePrimaryColor,
            textColor: Colors.white,
            fontSize: Dimensions.fontSizeDefault,
            onPressed: canComplete
                ? () => _showCompleteConfirmation(context, controller)
                : null,
          ),
        ),
      ],
    );
  }

  bool _canCancelBooking(BookingDetailsController controller) {
    if (!controller.statusTypeList.contains('canceled')) {
      return false;
    }
    final status = isSubBooking
        ? controller.subBookingDetails?.content?.bookingStatus
        : controller.bookingDetails?.content?.bookingStatus;
    if (status != 'accepted' && status != 'pending') {
      return false;
    }
    if (isSubBooking && bookingDetails.isPaid == 1) {
      return false;
    }
    return true;
  }

  void _showCancelReasonDialog(BuildContext context) {
    showCustomDialog(
      barrierDismissible: true,
      useSafeArea: false,
      child: BookingCancelReasonDialog(
        bookingId: bookingId,
        isSubBooking: isSubBooking,
        currentBookingStatus: bookingDetails.bookingStatus ?? '',
        popParentOnSuccess: true,
      ),
    );
  }

  void _showHoldReasonDialog(BuildContext context) {
    showCustomDialog(
      barrierDismissible: true,
      useSafeArea: false,
      child: BookingHoldReasonDialog(
        bookingId: bookingId,
        isSubBooking: isSubBooking,
        currentBookingStatus: bookingDetails.bookingStatus ?? '',
      ),
    );
  }

  void _showRejectConfirmation(
    BuildContext context,
    BookingDetailsController controller,
  ) {
    BookingCancelReasonDialog.showReject(
      bookingId: bookingId,
      isSubBooking: isSubBooking,
      currentBookingStatus: bookingDetails.bookingStatus ?? 'pending',
      popParentOnSuccess: true,
    );
  }

  void _showAcceptConfirmation(BookingDetailsController controller) {
    if (Get.find<UserProfileController>()
            .providerModel
            ?.content
            ?.subscriptionInfo
            ?.subscribedPackageDetails
            ?.isCanceled ==
        1) {
      showCustomSnackBar(
        'your_subscription_plan_has_been_cancelled_you_will_not_able_to_accept_any_booking_request'
            .tr,
        type: ToasterMessageType.info,
      );
      return;
    }

    Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrial) {
      if (isTrial) {
        showCustomDialog(
          child: ConfirmationDialog(
            yesButtonColor: Theme.of(Get.context!).primaryColor,
            title: 'want_accept_this_booking?'.tr,
            icon: Images.servicemanImage,
            description: 'accept_booking_hint_text'.tr,
            onYesPressed: () {
              controller.acceptBookingRequest(bookingId);
              Get.back();
            },
            onNoPressed: () => Get.back(),
          ),
        );
      }
    });
  }

  void _showStatusChangeConfirmation({
    required BuildContext context,
    required BookingDetailsController controller,
    required String targetStatus,
    required String title,
    String? description,
    String? yesButtonText,
  }) {
    showCustomDialog(
      child: ConfirmationDialog(
        yesButtonColor: Theme.of(Get.context!).primaryColor,
        title: title,
        description: description,
        icon: Images.warning,
        yesButtonText: yesButtonText,
        onYesPressed: () {
          Get.back();
          controller.changeBookingStatusDropDownValue(targetStatus, isSubBooking);
          controller.changeBookingStatus(
            bookingId,
            bookingStatus: bookingDetails.bookingStatus,
            isSubBooking: isSubBooking,
          );
        },
        onNoPressed: () => Get.back(),
      ),
    );
  }

  void _showCompleteConfirmation(
    BuildContext context,
    BookingDetailsController controller,
  ) {
    showCustomDialog(
      child: ConfirmationDialog(
        yesButtonColor: Theme.of(Get.context!).primaryColor,
        title: 'want_to_complete_this_booking'.tr,
        description: 'complete_booking_hint_text'.tr,
        icon: Images.servicemanImage,
        onYesPressed: () {
          Get.back();
          _handleCompleteAction(controller);
        },
        onNoPressed: () => Get.back(),
      ),
    );
  }

  void _handleCompleteAction(BookingDetailsController controller) {
    controller.changeBookingStatusDropDownValue('completed', isSubBooking);

    final config = Get.find<SplashController>().configModel.content;
    if (config?.bookingImageVerification == 1 &&
        controller.pickedPhotoEvidence.isNotEmpty) {
      controller.changePhotoEvidenceStatus(status: true);
    } else if (config?.bookingOtpVerification == 1) {
      controller.changePhotoEvidenceStatus(status: true);
    } else {
      controller.changePhotoEvidenceStatus(status: false);
    }

    if (config?.bookingImageVerification == 1 &&
        controller.pickedPhotoEvidence.isEmpty) {
      showCustomBottomSheet(
        child: CameraButtonSheet(bookingId: bookingId, isSubBooking: isSubBooking),
      );
    } else if (config?.bookingOtpVerification == 1) {
      controller.sendBookingOTPNotification(bookingId, shouldUpdate: false);
      showCustomBottomSheet(
        child: OtpVerificationBottomSheet(
          bookingId: bookingId,
          isSubBooking: isSubBooking,
        ),
      );
    } else {
      controller.changeBookingStatus(
        bookingId,
        bookingStatus: bookingDetails.bookingStatus,
        isSubBooking: isSubBooking,
      );
    }
  }
}
