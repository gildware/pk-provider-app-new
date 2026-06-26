import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:demandium_provider/feature/profile/widgets/profile_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _openReviews(UserProfileController userController) {
    Get.find<BusinessSubscriptionController>()
        .openTrialEndBottomSheet()
        .then((isTrial) {
      if (isTrial &&
          userController.checkAvailableFeatureInSubscriptionPlan(
              featureType: 'review')) {
        Get.to(() => const ProviderReviewScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: 'my_profile'.tr,
        usePrimaryColor: true,
        actionWidget: GetBuilder<ThemeController>(
          builder: (themeController) {
            return IconButton(
              onPressed: () => themeController.toggleTheme(),
              icon: Icon(
                themeController.darkTheme
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            );
          },
        ),
      ),
      body: GetBuilder<UserProfileController>(
        initState: (_) async {
          Get.find<BusinessSettingController>()
              .getBookingSettingsDataFromServer();
          Get.find<UserProfileController>().getProviderInfo(reload: true);
          Get.find<TransactionController>().getWithdrawMethods();
        },
        builder: (userController) {
          if (userController.providerModel != null) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProfileHeader(
                    providerInfo:
                        userController.providerModel?.content?.providerInfo,
                    onRatingTap: () => _openReviews(userController),
                  ),
                  const ProviderPendingApprovalBanner(),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  GestureDetector(
                    onTap: () =>
                        Get.to(() => const ProfileInformationScreen()),
                    child: ProfileCardItem(
                      title: 'edit_profile',
                      leadingIcon: Icons.person_outline_rounded,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const BusinessSettingScreen()),
                    child: ProfileCardItem(
                      title: 'business_settings',
                      leadingIcon: Icons.storefront_outlined,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const ShowcaseListScreen()),
                    child: ProfileCardItem(
                      title: 'work_showcase',
                      leadingIcon: Icons.photo_library_outlined,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _openReviews(userController),
                    child: ProfileCardItem(
                      title: 'reviews',
                      leadingIcon: Icons.star_rate_rounded,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.find<BusinessSubscriptionController>()
                          .openTrialEndBottomSheet()
                          .then((isTrial) {
                        if (isTrial &&
                            userController.checkAvailableFeatureInSubscriptionPlan(
                                featureType: 'service_request')) {
                          Get.toNamed(RouteHelper.suggestService);
                        }
                      });
                    },
                    child: ProfileCardItem(
                      title: 'suggest_service',
                      leadingIcon: Icons.lightbulb_outline_rounded,
                      isDarkItem: true,
                    ),
                  ),
                  Get.find<SplashController>()
                              .configModel
                              .content
                              ?.providerSlfDelete ==
                          1
                      ? GestureDetector(
                          onTap: () {
                            showCustomBottomSheet(
                                child: const DeleteAccountBottomSheet());
                          },
                          child: ProfileCardItem(
                            title: 'delete_account'.tr,
                            leadingIcon: Icons.person_remove_outlined,
                            isDarkItem: true,
                          ),
                        )
                      : const SizedBox(),
                  GestureDetector(
                    onTap: () => Get.to(() => const AccountInformation()),
                    child: ProfileCardItem(
                      title: 'account_information',
                      leadingIcon: Icons.info_outline_rounded,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  RichText(
                    text: TextSpan(
                      text: 'app_version'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).primaryColorLight,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' ${AppConstants.appVersion} ',
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).hoverColor,
              ),
            );
          }
        },
      ),
    );
  }
}
