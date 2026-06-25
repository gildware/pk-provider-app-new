import 'package:demandium_provider/feature/profile/view/profile_information/widgets/profile_image_preview_box.dart';
import 'package:demandium_provider/feature/settings/business/controller/company_identity_controller.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class CompanyIdentityInfoWidget extends StatelessWidget {
  final TextEditingController identityNumberController;
  final FocusNode identityNumberFocus;

  const CompanyIdentityInfoWidget({
    super.key,
    required this.identityNumberController,
    required this.identityNumberFocus,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CompanyIdentityController>(builder: (identityController) {
      final previewHeight = MediaQuery.sizeOf(context).width / 2.8;

      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trLabel('company_documents'), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
            Text(
              trLabel('setup_your_identity_information'),
              style: robotoLight.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Container(
              width: Get.width,
              height: 40,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Theme.of(context).hintColor.withValues(alpha: 0.4))),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  padding: EdgeInsets.zero,
                  dropdownColor: Theme.of(context).cardColor,
                  isExpanded: true,
                  hint: Text(trLabel('select_identity_type')),
                  value: identityController.selectedCompanyIdentityType,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: AppConstants.companyIdentityTypeList
                      .map((items) => DropdownMenuItem(
                            value: items,
                            child: Text(trLabel(AppConstants.identityTypeLabelKey(items))),
                          ))
                      .toList(),
                  onChanged: identityController.onChangeIdentityType,
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),
            CustomTextField(
              title: trLabel('identity_number'),
              controller: identityNumberController,
              focusNode: identityNumberFocus,
              hintText: trLabel('enter_identity_number'),
              onValidate: (value) =>
                  (value == null || value.isEmpty) ? trLabel('enter_identity_number') : null,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            TextFieldTitle(title: trLabel('identity_image'), requiredMark: true, isPadding: false),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            ..._buildImageSections(context, identityController, previewHeight),
          ],
        ),
      );
    });
  }

  List<Widget> _buildImageSections(
    BuildContext context,
    CompanyIdentityController ctrl,
    double previewHeight,
  ) {
    final widgets = <Widget>[];

    for (int index = 0; index < ctrl.currentIdentityImages.length; index++) {
      final picked = ctrl.replacedIdentityImages?[index] != null;
      widgets.add(
        ProfileImagePreviewBox(
          height: previewHeight,
          networkUrl: picked ? null : ctrl.currentIdentityImages[index],
          localFilePath: picked ? ctrl.replacedIdentityImages![index]!.imageFile!.path : null,
          onTap: picked
              ? null
              : () => showCustomDialog(
                    child: ImageDialog(imageUrl: ctrl.currentIdentityImages[index] ?? ''),
                  ),
          overlay: _actionOverlay(context, ctrl, index: index, picked: picked, isExisting: true),
        ),
      );
      widgets.add(const SizedBox(height: Dimensions.paddingSizeSmall));
    }

    for (int index = 0; index < (ctrl.identityImages?.length ?? 0); index++) {
      widgets.add(
        ProfileImagePreviewBox(
          height: previewHeight,
          localFilePath: ctrl.identityImages![index]!.path,
          overlay: _actionOverlay(context, ctrl, index: index, picked: true, isExisting: false),
        ),
      );
      widgets.add(const SizedBox(height: Dimensions.paddingSizeSmall));
    }

    final canAddMore = ctrl.currentIdentityImages.isEmpty && (ctrl.identityImages?.isEmpty ?? true) ||
        (ctrl.identityImages?.length ?? 0) < AppConstants.limitOfPickedIdentityImageNumber;

    if (canAddMore) {
      widgets.add(
        ProfileImagePreviewBox(
          height: previewHeight,
          onTap: () => ctrl.pickIdentityImage(),
          overlay: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_upload, color: Theme.of(context).hintColor, size: 32),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Text(
                  trLabel('upload_id_proof'),
                  style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
        ),
      );
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
          child: ImageValidationTextWidget(
            textAlign: TextAlign.start,
            separator: '. ',
            showRatioValidation: false,
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _actionOverlay(
    BuildContext context,
    CompanyIdentityController ctrl, {
    required int index,
    required bool picked,
    required bool isExisting,
  }) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.topRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isExisting && !picked)
              IconButton(
                onPressed: () {
                  showCustomDialog(
                    child: ConfirmationDialog(
                      icon: Images.deleteDialogIcon,
                      title: trLabel('are_you_want_to_delete'),
                      onNoPressed: Get.back,
                      onYesPressed: () {
                        ctrl.removeCurrentImage(index);
                        Get.back();
                      },
                      description: '',
                    ),
                    barrierDismissible: true,
                    useSafeArea: true,
                  );
                },
                icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              ),
            IconButton(
              onPressed: () {
                if (isExisting) {
                  ctrl.onReplacePickIdentityImage(index: index, isRemoved: picked);
                } else {
                  ctrl.pickIdentityImage(index: index, isRemoved: true);
                }
              },
              icon: Icon(
                picked ? Icons.close : Icons.edit,
                color: context.adaptivePrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
