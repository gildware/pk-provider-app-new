import 'package:demandium_provider/feature/settings/business/widget/business_info_tab_item_widget.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BusinessBrandingTabItemWidget extends StatelessWidget {
  const BusinessBrandingTabItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(builder: (c) {
      final canSave = c.canSaveBranding;

      return Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trLabel('business_branding'), style: robotoBold),
            Text(
              trLabel('update_logo_cover_hint'),
              style: robotoLight.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
            if (c.showBrandingSubmittedMessage) ...[
              const SizedBox(height: Dimensions.paddingSizeSmall),
              ProviderPendingVerificationWarningCard(
                messageKey: 'branding_change_sent_for_approval',
                margin: EdgeInsets.zero,
              ),
            ] else if (c.hasPendingProfileChanges &&
                !c.hasPendingBrandingChanges) ...[
              const SizedBox(height: Dimensions.paddingSizeSmall),
              const ProviderPendingApprovalBanner(),
            ],
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFieldTitle(title: trLabel('logo'), requiredMark: true, isPadding: false),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    const LogoWidget(),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    TextFieldTitle(title: trLabel('cover_image'), requiredMark: true, isPadding: false),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    const CoverImageWidget(),
                  ],
                ),
              ),
            ),
            if (!canSave && !c.showBrandingSubmittedMessage) ...[
              Text(
                trLabel('branding_save_pick_new_image'),
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ],
            CustomButton(
              btnTxt: trLabel('save'),
              isLoading: c.isLoading,
              onPressed: canSave ? () => _save(c) : null,
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom
                  : 12,
            ),
          ],
        ),
      );
    });
  }

  Future<void> _save(UserProfileController c) async {
    final status = await c.updateBrandingImages();
    if (!status.isSuccess!) {
      if (status.message != null && status.message!.isNotEmpty) {
        showCustomSnackBar(status.message!);
      }
      return;
    }
    if (status.message != null && status.message!.isNotEmpty) {
      showCustomSnackBar(status.message!, type: ToasterMessageType.info);
    }
  }
}
