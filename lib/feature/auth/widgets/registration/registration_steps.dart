import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/util/core_export.dart';

class RegistrationProviderTypeStep extends StatelessWidget {
  final SignUpController controller;
  const RegistrationProviderTypeStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trLabel('choose_provider_type'), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(trLabel('choose_provider_type_hint'), style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          ProviderTypeOptionCard(
            icon: Icons.person_outline,
            titleKey: 'individual',
            subtitleKey: 'individual_provider_subtitle',
            isSelected: controller.providerType == ProviderType.individual,
            onTap: () {
              controller.setProviderType(ProviderType.individual);
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          ProviderTypeOptionCard(
            icon: Icons.business_outlined,
            titleKey: 'company',
            subtitleKey: 'company_provider_subtitle',
            isSelected: controller.providerType == ProviderType.company,
            onTap: () {
              controller.setProviderType(ProviderType.company);
            },
          ),
        ],
      ),
    );
  }
}

class RegistrationContactStep extends StatelessWidget {
  final SignUpController controller;
  final GlobalKey<FormState> formKey;
  const RegistrationContactStep({super.key, required this.controller, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          children: [
            Center(
              child: _ProfilePhotoPicker(controller: controller),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            RegistrationIconField(
              icon: Icons.person_outline,
              titleKey: 'contact_person_name',
              hintKey: 'enter_contact_person_name',
              controller: controller.contactPersonNameController,
              onValidate: (v) => (v == null || v.isEmpty) ? trLabel('enter_contact_person_name') : null,
            ),
            RegistrationIconField(
              icon: Icons.phone_outlined,
              titleKey: 'phone_number',
              hintKey: 'phone_example',
              controller: controller.contactPersonPhoneController,
              inputType: TextInputType.phone,
              isEnabled: !controller.phoneVerifiedForRegistration,
              onValidate: (v) {
                if (v == null || v.isEmpty) return trLabel('phone_number_hint');
                if (controller.phoneErrorText != null) return controller.phoneErrorText;
                return FormValidationHelper().isValidPhone(controller.countryDialCode + v);
              },
            ),
            RegistrationIconField(
              icon: Icons.email_outlined,
              titleKey: 'contact_person_email_optional',
              hintKey: 'enter_contact_person_email_address',
              controller: controller.contactPersonEmailController,
              inputType: TextInputType.emailAddress,
              isRequired: false,
              onValidate: (v) {
                if (v != null && v.isNotEmpty) {
                  if (controller.emailErrorText != null) return controller.emailErrorText;
                  return FormValidationHelper().isValidEmail(v);
                }
                return null;
              },
            ),
            if (controller.showRegistrationFieldErrors && !controller.hasContactPhotoForSubmit)
              Text(trLabel('provide_contact_person_photo'), style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall)),
          ],
        ),
      ),
    );
  }
}

class _ProfilePhotoPicker extends StatelessWidget {
  final SignUpController controller;
  const _ProfilePhotoPicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    final file = controller.contactPersonPhotoFile;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipOval(
          child: file != null
              ? Image.file(File(file.path), width: 110, height: 110, fit: BoxFit.cover)
              : (controller.draftContactPhotoUrl != null && controller.draftContactPhotoUrl!.isNotEmpty)
                  ? CustomImage(
                      image: controller.draftContactPhotoUrl!,
                      height: 110,
                      width: 110,
                      fit: BoxFit.cover,
                    )
                  : Container(
                  width: 110,
                  height: 110,
                  color: Theme.of(context).hintColor.withValues(alpha: 0.15),
                  child: Icon(Icons.person, size: 48, color: Theme.of(context).hintColor),
                ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => controller.pickContactPersonPhoto(false),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}

class RegistrationIdentityStep extends StatelessWidget {
  final SignUpController controller;
  final GlobalKey<FormState> formKey;
  const RegistrationIdentityStep({super.key, required this.controller, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _identityDropdown(context),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            RegistrationIconField(
              icon: Icons.badge_outlined,
              titleKey: 'identity_number',
              hintKey: 'enter_identity_number',
              controller: controller.identityNumberController,
              onValidate: (v) => (v == null || v.isEmpty) ? trLabel('enter_identity_number') : null,
            ),
            Text(trLabel('upload_id_proof'), style: robotoBold),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _IdentitySideUpload(
                    controller: controller,
                    isFront: true,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: _IdentitySideUpload(
                    controller: controller,
                    isFront: false,
                  ),
                ),
              ],
            ),
            if (controller.showRegistrationFieldErrors &&
                (!controller.hasIdentityFront || !controller.hasIdentityBack))
              Padding(
                padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                child: Text(
                  trLabel('upload_id_front_and_back'),
                  style: robotoRegular.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _identityDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: controller.selectedIdentityType.isEmpty ? null : controller.selectedIdentityType,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.credit_card_outlined),
        labelText: trLabel('identity_type'),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      ),
      items: AppConstants.contactIdentityTypeList
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(trLabel(AppConstants.identityTypeLabelKey(e))),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) controller.setIdentityType(v);
      },
      validator: (v) => (v == null || v.isEmpty) ? trLabel('select_identity_type') : null,
    );
  }
}

class _IdentitySideUpload extends StatelessWidget {
  final SignUpController controller;
  final bool isFront;

  const _IdentitySideUpload({required this.controller, required this.isFront});

  @override
  Widget build(BuildContext context) {
    final file = isFront ? controller.identityImageFront : controller.identityImageBack;
    final draftUrl = isFront ? controller.draftIdentityFrontUrl : controller.draftIdentityBackUrl;
    final hasFile = file != null || (draftUrl != null && draftUrl!.isNotEmpty);
    final hasSide = isFront ? controller.hasIdentityFront : controller.hasIdentityBack;
    final isValid = !controller.showRegistrationFieldErrors || hasSide;

    return RegistrationUploadBox(
      titleKey: isFront ? 'upload_id_front' : 'upload_id_back',
      subtitleKey: 'upload_id_proof_hint',
      isValid: isValid,
      onTap: () => isFront ? controller.pickIdentityImageFront(false) : controller.pickIdentityImageBack(false),
      preview: hasFile
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: file != null
                  ? Image.file(File(file.path), height: 72, width: double.infinity, fit: BoxFit.cover)
                  : CustomImage(image: draftUrl!, height: 72, width: double.infinity, fit: BoxFit.cover),
            )
          : null,
    );
  }
}

class RegistrationCompanyInfoStep extends StatelessWidget {
  final SignUpController controller;
  final GlobalKey<FormState> formKey;
  const RegistrationCompanyInfoStep({super.key, required this.controller, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          children: [
            const CompanyStepBadge(),
            Center(child: _LogoPicker(controller: controller)),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            RegistrationIconField(
              icon: Icons.business,
              titleKey: 'company_or_individual_name',
              hintKey: 'company_name_hint',
              controller: controller.companyNameController,
              onValidate: (v) => (v == null || v.isEmpty) ? trLabel('company_name_hint') : null,
            ),
            RegistrationIconField(
              icon: Icons.email_outlined,
              titleKey: 'company_email_optional',
              hintKey: 'enter_company_email_address',
              controller: controller.companyEmailController,
              inputType: TextInputType.emailAddress,
              isRequired: false,
            ),
            RegistrationIconField(
              icon: Icons.phone_outlined,
              titleKey: 'phone_number',
              hintKey: 'phone_example',
              controller: controller.companyPhoneController,
              inputType: TextInputType.phone,
              onValidate: (v) {
                if (v == null || v.isEmpty) return trLabel('phone_number_hint');
                return FormValidationHelper().isValidPhone(controller.countryDialCode + v);
              },
            ),
            if (controller.showRegistrationFieldErrors && !controller.hasLogoForSubmit)
              Text(trLabel('provide_image_logo'), style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall)),
          ],
        ),
      ),
    );
  }
}

class _LogoPicker extends StatelessWidget {
  final SignUpController controller;
  const _LogoPicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    final file = controller.profileImageFile;
    return GestureDetector(
      onTap: () => controller.pickProfileImage(false),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.3)),
          color: Theme.of(context).hintColor.withValues(alpha: 0.08),
        ),
        child: file != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(File(file.path), fit: BoxFit.cover),
              )
            : (controller.draftLogoUrl != null && controller.draftLogoUrl!.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CustomImage(image: controller.draftLogoUrl!, height: 100, width: 100, fit: BoxFit.cover),
                  )
                : Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.storefront_outlined, size: 40, color: Theme.of(context).hintColor),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Icon(Icons.camera_alt, size: 20, color: context.adaptivePrimaryColor),
                  ),
                ],
              ),
      ),
    );
  }
}

class RegistrationCompanyDocsStep extends StatelessWidget {
  final SignUpController controller;
  final GlobalKey<FormState> formKey;
  const RegistrationCompanyDocsStep({super.key, required this.controller, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CompanyStepBadge(),
            DropdownButtonFormField<String>(
              value: controller.selectedCompanyIdentityType.isEmpty ? null : controller.selectedCompanyIdentityType,
              decoration: InputDecoration(
                labelText: trLabel('identity_type'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
              ),
              items: AppConstants.companyIdentityTypeList
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(trLabel(AppConstants.identityTypeLabelKey(e))),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) controller.setCompanyIdentityType(v);
              },
              validator: (v) => (v == null || v.isEmpty) ? trLabel('select_identity_type') : null,
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            RegistrationIconField(
              icon: Icons.numbers,
              titleKey: 'identity_number',
              hintKey: 'enter_identity_number',
              controller: controller.companyIdentityNumberController,
              onValidate: (v) => (v == null || v.isEmpty) ? trLabel('enter_identity_number') : null,
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            _CompanyIdentityDocumentsPreview(controller: controller),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            if (!controller.hasCompanyIdentityImagesForSubmit)
              RegistrationUploadBox(
                titleKey: 'upload_id_proof',
                subtitleKey: 'upload_id_proof_hint',
                isValid: !controller.showRegistrationFieldErrors ||
                    controller.hasCompanyIdentityImagesForSubmit,
                onTap: () => controller.pickCompanyIdentityImage(false),
              )
            else
              RegistrationUploadBox(
                titleKey: 'upload_image',
                subtitleKey: 'tap_to_replace_company_document',
                isValid: true,
                onTap: () => controller.pickCompanyIdentityImage(false),
              ),
            if (controller.showRegistrationFieldErrors &&
                !controller.hasCompanyIdentityImagesForSubmit)
              Padding(
                padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                child: Text(
                  trLabel('provide_company_identity_image'),
                  style: robotoRegular.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CompanyIdentityDocumentsPreview extends StatelessWidget {
  final SignUpController controller;

  const _CompanyIdentityDocumentsPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final hasDraft = controller.draftCompanyIdentityImageUrls.isNotEmpty;
    final hasLocal = controller.selectedCompanyIdentityImageList.isNotEmpty;
    if (!hasDraft && !hasLocal) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(trLabel('upload_file'), style: robotoMedium),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Wrap(
          spacing: Dimensions.paddingSizeSmall,
          runSpacing: Dimensions.paddingSizeSmall,
          children: [
            ...controller.draftCompanyIdentityImageUrls.asMap().entries.map((entry) {
              return _CompanyDocThumb(
                imageUrl: entry.value,
                onRemove: () {
                  controller.draftCompanyIdentityImageUrls.removeAt(entry.key);
                  controller.update();
                },
              );
            }),
            ...controller.selectedCompanyIdentityImageList.asMap().entries.map((entry) {
              return _CompanyDocThumb(
                localPath: entry.value.file.path,
                onRemove: () => controller.pickCompanyIdentityImage(true, index: entry.key),
              );
            }),
          ],
        ),
      ],
    );
  }
}

class _CompanyDocThumb extends StatelessWidget {
  final String? imageUrl;
  final String? localPath;
  final VoidCallback onRemove;

  const _CompanyDocThumb({
    this.imageUrl,
    this.localPath,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 88,
            height: 88,
            child: localPath != null
                ? Image.file(File(localPath!), fit: BoxFit.cover)
                : CustomImage(image: imageUrl!, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Theme.of(context).colorScheme.error,
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class RegistrationServiceAreasStep extends StatelessWidget {
  final SignUpController controller;
  const RegistrationServiceAreasStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFieldTitle(title: 'select_zone', requiredMark: true),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          RegistrationZoneDropdown(controller: controller),
        ],
      ),
    );
  }
}

class RegistrationAddressStep extends StatelessWidget {
  final SignUpController controller;
  final GlobalKey<FormState> formKey;
  const RegistrationAddressStep({super.key, required this.controller, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _openMap(context),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    hintText: trLabel('search_your_address'),
                    suffixIcon: const Icon(Icons.my_location),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text(trLabel('address_details'), style: robotoBold),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            RegistrationIconField(
              icon: Icons.signpost_outlined,
              titleKey: 'town',
              hintKey: 'town_hint',
              controller: controller.streetController,
              onValidate: (v) => (v == null || v.isEmpty) ? trLabel('town_hint') : null,
            ),
            RegistrationIconField(
              icon: Icons.location_city_outlined,
              titleKey: 'city',
              hintKey: 'city_hint',
              controller: controller.cityController,
              onValidate: (v) => (v == null || v.isEmpty) ? trLabel('city_hint') : null,
            ),
            RegistrationIconField(
              icon: Icons.pin_outlined,
              titleKey: 'pincode',
              hintKey: 'pincode_hint',
              controller: controller.pincodeController,
              inputType: TextInputType.number,
              onValidate: (v) => (v == null || v.isEmpty) ? trLabel('pincode_hint') : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMap(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      showCustomDialog(child: const PermissionDialog(), barrierDismissible: true);
    } else if (permission != LocationPermission.denied) {
      await Get.to(() => const PickMapScreen());
      final loc = Get.find<LocationController>();
      final address = loc.pickAddress.address ?? '';
      if (address.isNotEmpty) {
        controller.syncAddressFromMap(address);
      }
    } else {
      showCustomSnackBar(trLabel('you_have_to_allow'), type: ToasterMessageType.info);
    }
  }
}

class RegistrationReviewStep extends StatelessWidget {
  final SignUpController controller;
  final void Function(RegistrationStep step) onEdit;
  const RegistrationReviewStep({super.key, required this.controller, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trLabel('review_and_submit'),
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            trLabel('approval_time_hint'),
            style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          _reviewRow(context, 'contact_person_info_title', controller.contactPersonNameController.text, RegistrationStep.contactInfo),
          _reviewRow(
            context,
            'identity_verification',
            controller.selectedIdentityType.isNotEmpty
                ? trLabel(AppConstants.identityTypeLabelKey(controller.selectedIdentityType))
                : '-',
            RegistrationStep.identityVerification,
          ),
          if (controller.isCompanyProvider)
            _reviewRow(context, 'company_information', controller.companyNameController.text, RegistrationStep.companyInformation),
          _reviewRow(
            context,
            'service_zones',
            controller.selectedZoneReviewText.isNotEmpty
                ? controller.selectedZoneReviewText
                : trLabel('select_zone'),
            RegistrationStep.serviceAreas,
          ),
          _reviewRow(context, 'address_information', controller.buildFormattedAddress(), RegistrationStep.currentAddress),
          _reviewRow(
            context,
            'service_categories',
            controller.selectedCategoriesReviewText.isNotEmpty
                ? controller.selectedCategoriesReviewText
                : trLabel('select_at_least_one_category'),
            RegistrationStep.serviceCategories,
          ),
          _reviewRow(
            context,
            'service_subcategories',
            controller.selectedSubCategoriesReviewText.isNotEmpty
                ? controller.selectedSubCategoriesReviewText
                : trLabel('select_at_least_one_subcategory'),
            RegistrationStep.serviceSubcategories,
          ),
        ],
      ),
    );
  }

  Widget _reviewRow(BuildContext context, String titleKey, String value, RegistrationStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: context.customThemeColors.lightShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trLabel(titleKey), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                const SizedBox(height: 4),
                Text(value.isEmpty ? '-' : value, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall)),
              ],
            ),
          ),
          TextButton(onPressed: () => onEdit(step), child: Text(trLabel('edit'), style: robotoMedium.copyWith(color: context.adaptivePrimaryColor))),
        ],
      ),
    );
  }
}
