import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class AdvertisementSection extends StatelessWidget {
  const AdvertisementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(builder: (userProfileController) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeDefault,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: context.customThemeColors.cardBottomShadow,
        ),
        child: Row(
          children: [
            // Icon on the left
            Image.asset(Images.dashboardAdsIcon, height: 50, width: 50),

            const SizedBox(width: Dimensions.paddingSizeDefault),

            // Text content in the middle
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('want_to_get_highlighted'.tr, style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                )),
                SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(
                  'create_ads_to_reach_more_customers'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            )),
            const SizedBox(width: Dimensions.paddingSizeDefault),

            // Create Ad button on the right
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: InkWell(
                onTap: () {
                  Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrial){
                    if(isTrial){
                      if(Get.find<UserProfileController>().checkAvailableFeatureInSubscriptionPlan(featureType: 'advertisement')){
                        Get.find<AdvertisementController>().resetAllValues();
                        Get.to(()=>const CreateAdvertisementScreen(isEditScreen: false));
                      }
                    }
                  });
                },
                child: Text('create_ads'.tr, style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).primaryColor,
                )),
              ),
            ),
          ],
        ),
      );
    });
  }
}