import 'package:demandium_provider/feature/profile/model/provider_model.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class ProfileHeader extends StatelessWidget {
  final ProviderInfo? providerInfo;
  final VoidCallback? onRatingTap;

  const ProfileHeader({
    super.key,
    required this.providerInfo,
    this.onRatingTap,
  });

  @override
  Widget build(BuildContext context) {
    final phone = providerInfo?.companyPhone?.trim();
    final email = providerInfo?.companyEmail?.trim();
    final contact = (phone != null && phone.isNotEmpty)
        ? phone
        : (email != null && email.isNotEmpty ? email : null);
    final avgRating = providerInfo?.avgRating ?? 0;
    final ratingCount = providerInfo?.ratingCount ?? 0;
    final daysSinceJoined = DateTime.now()
        .difference(
          DateConverter.isoStringToLocalDate(
            providerInfo?.createdAt ?? DateTime.now().toString(),
          ),
        )
        .inDays
        .toString();
    final totalSubscriptions = Get.find<DashboardController>()
            .dashboardTopCards
            ?.totalSubscribedServices
            .toString() ??
        '';
    final bookingsServed = Get.find<DashboardController>()
            .dashboardTopCards
            ?.totalBookingServed
            .toString() ??
        '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeDefault,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).cardColor,
              boxShadow:
                  Get.isDarkMode ? null : context.customThemeColors.cardShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CustomImage(
                    width: 100,
                    height: 100,
                    image: providerInfo?.displayLogoUrl ?? '',
                    placeholder: Images.userPlaceHolder,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              providerInfo?.companyName ?? '',
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                Get.to(() => const ProfileInformationScreen()),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'edit'.tr,
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Get.isDarkMode
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color
                                        : context.adaptivePrimaryColor,
                                  ),
                                ),
                                const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall),
                                Icon(
                                  Icons.edit_outlined,
                                  size: Dimensions.fontSizeDefault,
                                  color: Get.isDarkMode
                                      ? Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color
                                      : context.adaptivePrimaryColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (contact != null) ...[
                        const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall),
                        Text(
                          contact,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Row(
                        children: [
                          _ProfileStat(
                            value: totalSubscriptions,
                            label: 'total_subscription'.tr,
                          ),
                          _verticalDivider(context),
                          _ProfileStat(
                            value: bookingsServed,
                            label: 'Booking_Served'.tr,
                          ),
                          _verticalDivider(context),
                          _ProfileStat(
                            value: daysSinceJoined,
                            label: 'Days_Since_Joined'.tr,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          InkWell(
            onTap: onRatingTap,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).cardColor,
                boxShadow:
                    Get.isDarkMode ? null : context.customThemeColors.cardShadow,
              ),
              child: Row(
                children: [
                  Text(
                    'rating'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        RatingBar(
                          rating: avgRating,
                          size: 16,
                        ),
                        const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall),
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Get.isDarkMode
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : context.adaptivePrimaryColor,
                          ),
                        ),
                        const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall),
                        Flexible(
                          child: Text(
                            '($ratingCount ${'ratings'.tr})',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall),
      width: 1,
      height: 28,
      color: Theme.of(context).hintColor.withValues(alpha: 0.3),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Get.isDarkMode
                  ? Theme.of(context).textTheme.bodyLarge?.color
                  : context.adaptivePrimaryColor,
            ),
            textDirection: TextDirection.ltr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Theme.of(context).hintColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
