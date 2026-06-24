import 'package:demandium_provider/helper/booking_notification_action_handler.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BookingAlertDialogWidget extends StatefulWidget {
  final String bookingId;
  final String title;
  final String body;
  final String? bookingType;
  final String? repeatBookingType;
  final VoidCallback? onClosed;

  const BookingAlertDialogWidget({
    super.key,
    required this.bookingId,
    required this.title,
    required this.body,
    this.bookingType,
    this.repeatBookingType,
    this.onClosed,
  });

  @override
  State<BookingAlertDialogWidget> createState() =>
      _BookingAlertDialogWidgetState();
}

class _BookingAlertDialogWidgetState extends State<BookingAlertDialogWidget> {
  bool _isAcceptLoading = false;
  bool _isRejectLoading = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 38,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text(
                'new_booking_received'.tr,
                textAlign: TextAlign.center,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                ),
              ),
              if (widget.body.isNotEmpty) ...[
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Text(
                  widget.body,
                  textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.75),
                  ),
                ),
              ],
              const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),
              CustomButton(
                isLoading: _isAcceptLoading,
                btnTxt: 'accept'.tr,
                onPressed: _isRejectLoading ? null : _onAccept,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              CustomButton(
                isLoading: _isRejectLoading,
                btnTxt: 'ignore'.tr,
                color: Theme.of(context).disabledColor.withValues(alpha: 0.15),
                textColor: Theme.of(context).textTheme.bodyLarge?.color,
                onPressed: _isAcceptLoading ? null : _onReject,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              TextButton(
                onPressed: (_isAcceptLoading || _isRejectLoading)
                    ? null
                    : _onViewBooking,
                child: Text('view_booking'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onAccept() async {
    setState(() => _isAcceptLoading = true);
    await BookingNotificationActionHandler.acceptFromDialog(widget.bookingId);
    if (!mounted) return;
    setState(() => _isAcceptLoading = false);
    _closeDialog();
  }

  Future<void> _onReject() async {
    setState(() => _isRejectLoading = true);
    await BookingNotificationActionHandler.rejectFromDialog(widget.bookingId);
    if (!mounted) return;
    setState(() => _isRejectLoading = false);
    _closeDialog();
  }

  void _onViewBooking() {
    _closeDialog();
    if (widget.bookingType == 'repeat' && widget.repeatBookingType == 'single') {
      Get.toNamed(
        RouteHelper.getBookingDetailsRoute(
          subBookingId: widget.bookingId,
          fromPage: 'fromNotification',
        ),
      );
    } else if (widget.bookingType == 'repeat' &&
        widget.repeatBookingType != 'single') {
      Get.toNamed(
        RouteHelper.getRepeatBookingDetailsRoute(
          bookingId: widget.bookingId,
          fromPage: 'fromNotification',
        ),
      );
    } else {
      Get.toNamed(
        RouteHelper.getBookingDetailsRoute(
          bookingId: widget.bookingId,
          fromPage: 'fromNotification',
        ),
      );
    }
  }

  void _closeDialog() {
    widget.onClosed?.call();
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}
