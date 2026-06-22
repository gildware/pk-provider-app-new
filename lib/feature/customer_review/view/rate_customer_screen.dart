import 'package:demandium_provider/feature/customer_review/controller/customer_review_controller.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class RateCustomerScreen extends StatefulWidget {
  final String bookingId;
  final String customerName;

  const RateCustomerScreen({
    super.key,
    required this.bookingId,
    required this.customerName,
  });

  @override
  State<RateCustomerScreen> createState() => _RateCustomerScreenState();
}

class _RateCustomerScreenState extends State<RateCustomerScreen> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<CustomerReviewController>()) {
      Get.lazyPut(() => CustomerReviewController(customerReviewRepo: Get.find()));
    }
    Get.find<CustomerReviewController>().loadCustomerReview(widget.bookingId);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerReviewController>(
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(
            title: controller.hasReview ? 'view_rating'.tr : 'rate_customer'.tr,
          ),
          body: _buildBody(context, controller),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CustomerReviewController controller) {
    if (controller.isFetching) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.customerName,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            controller.hasReview ? 'view_rating_subtitle'.tr : 'rate_customer_subtitle'.tr,
            style: robotoRegular.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final filled = index < controller.selectedRating;
              return IconButton(
                onPressed: controller.isEditable
                    ? () => controller.selectRating(index + 1)
                    : null,
                icon: Icon(
                  filled ? Icons.star : Icons.star_border,
                  color: Theme.of(context).colorScheme.tertiary,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          if (controller.isEditable)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                color: Theme.of(context).cardColor,
                border: Border.all(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                ),
              ),
              child: TextFormField(
                controller: controller.reviewController,
                maxLines: 4,
                style: robotoRegular.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  hintText: 'write_your_review'.tr,
                  border: InputBorder.none,
                  hintStyle: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
            )
          else if (controller.reviewComment.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                color: Theme.of(context).cardColor,
                border: Border.all(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                ),
              ),
              child: Text(controller.reviewComment, style: robotoRegular),
            ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          if (controller.isEditable)
            CustomButton(
              isLoading: controller.isLoading,
              btnTxt: 'submit'.tr,
              onPressed: () => controller.submitCustomerReview(
                bookingId: widget.bookingId,
              ),
            )
          else if (controller.hasReview)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      controller.isApproved ? Icons.verified : Icons.hourglass_top,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(
                      controller.isApproved
                          ? 'rating_approved'.tr
                          : 'rating_pending_approval'.tr,
                      style: robotoMedium.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                if (controller.canEdit) ...[
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  CustomButton(
                    btnTxt: 'edit'.tr,
                    onPressed: controller.enableEdit,
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
