import 'package:demandium_provider/feature/customer_review/controller/customer_review_controller.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class CustomerRatingButton extends StatefulWidget {
  final String bookingId;
  final String customerName;

  const CustomerRatingButton({
    super.key,
    required this.bookingId,
    required this.customerName,
  });

  @override
  State<CustomerRatingButton> createState() => _CustomerRatingButtonState();
}

class _CustomerRatingButtonState extends State<CustomerRatingButton> {
  bool _isLoading = true;
  bool _hasReview = false;

  @override
  void initState() {
    super.initState();
    _loadReviewStatus();
  }

  Future<void> _loadReviewStatus() async {
    var hasReview = false;
    try {
      CustomerReviewController.ensureDependencies();
      final controller = Get.find<CustomerReviewController>();
      hasReview = await controller.checkReviewExists(widget.bookingId);
    } catch (_) {
      hasReview = false;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _hasReview = hasReview;
      _isLoading = false;
    });
  }

  void _openRatingScreen() {
    Get.toNamed(RouteHelper.getRateCustomerRoute(
      bookingId: widget.bookingId,
      customerName: widget.customerName,
    ))?.then((_) => _loadReviewStatus());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: CustomButton(
        btnTxt: _hasReview ? 'view_rating'.tr : 'rate_customer'.tr,
        onPressed: _openRatingScreen,
      ),
    );
  }
}
