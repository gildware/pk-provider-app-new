import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

/// Warning card for providers awaiting admin approval (banner + full-page use).
class ProviderPendingVerificationWarningCard extends StatelessWidget {
  final String messageKey;
  final EdgeInsetsGeometry? margin;

  const ProviderPendingVerificationWarningCard({
    super.key,
    this.messageKey = 'provider_pending_verification_banner',
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final warningColor = context.customThemeColors.warning;

    return Container(
      width: double.infinity,
      margin: margin ??
          const EdgeInsets.fromLTRB(
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeSmall,
            Dimensions.paddingSizeDefault,
            0,
          ),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: warningColor.withValues(alpha: Get.isDarkMode ? 0.22 : 0.14),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: warningColor.withValues(alpha: 0.55),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 22,
            color: warningColor,
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            trLabel(messageKey),
            textAlign: TextAlign.center,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              height: 1.3,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          CustomButton(
            btnTxt: trLabel('contact_for_support'),
            height: 34,
            width: 160,
            radius: Dimensions.radiusDefault,
            color: warningColor,
            textColor: Get.isDarkMode ? Colors.white : const Color(0xFF3D2E00),
            onPressed: () => Get.toNamed(RouteHelper.getHelpAndSupportScreen()),
          ),
        ],
      ),
    );
  }
}

/// Shown below the main app bar while admin has not approved the provider yet.
class ProviderPendingApprovalBanner extends StatelessWidget {
  const ProviderPendingApprovalBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(builder: (profileController) {
      final widgets = <Widget>[];

      if (profileController.isPendingAdminVerification) {
        widgets.add(const ProviderPendingVerificationWarningCard());
      }

      if (profileController.hasPendingProfileChanges) {
        widgets.add(ProviderPendingVerificationWarningCard(
          messageKey: 'profile_changes_pending_admin_approval',
          margin: widgets.isEmpty
              ? null
              : const EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeSmall,
                  Dimensions.paddingSizeDefault,
                  0,
                ),
        ));
      }

      if (widgets.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(mainAxisSize: MainAxisSize.min, children: widgets);
    });
  }
}
