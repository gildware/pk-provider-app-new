import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> contactFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> identityFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> companyFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> companyDocsFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();
  final FocusNode contactEmailFocus = FocusNode();
  final FocusNode contactPhoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    Get.find<SplashController>().getConfigData();
    Get.find<LocationController>().setPickedLocation(shouldUpdate: false);
    Get.find<SignUpController>().checkOthersFieldValidity(shouldUpdate: false, isInitial: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const SignUpAppbar(),
      body: SafeArea(
        bottom: GetPlatform.isIOS,
        child: GetBuilder<SignUpController>(
          builder: (signUpController) {
            return Column(
              children: [
                Expanded(child: _buildStepContent(signUpController)),
                if (!signUpController.isOnReviewStep)
                  RegistrationContinueButton(
                    isLoading: signUpController.isLoading ?? false,
                    labelKey: 'save_and_continue',
                    onPressed: (signUpController.isLoading! || !signUpController.canProceedFromCurrentStep)
                        ? null
                        : () => _onContinue(signUpController),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: CustomButton(
                      height: 48,
                      width: double.infinity,
                      radius: Dimensions.radiusDefault,
                      isLoading: signUpController.isLoading ?? false,
                      btnTxt: trLabel('submit_application'),
                      onPressed: signUpController.isLoading! ? null : () => _submitRegistration(signUpController),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepContent(SignUpController controller) {
    switch (controller.currentRegistrationStep) {
      case RegistrationStep.providerType:
        return RegistrationProviderTypeStep(controller: controller);
      case RegistrationStep.contactInfo:
        return RegistrationContactStep(controller: controller, formKey: contactFormKey);
      case RegistrationStep.identityVerification:
        return RegistrationIdentityStep(controller: controller, formKey: identityFormKey);
      case RegistrationStep.companyInformation:
        return RegistrationCompanyInfoStep(controller: controller, formKey: companyFormKey);
      case RegistrationStep.companyDocuments:
        return RegistrationCompanyDocsStep(controller: controller, formKey: companyDocsFormKey);
      case RegistrationStep.serviceAreas:
        return RegistrationServiceAreasStep(controller: controller);
      case RegistrationStep.currentAddress:
        return RegistrationAddressStep(controller: controller, formKey: addressFormKey);
      case RegistrationStep.serviceCategories:
        return RegistrationServiceCategoriesStep(controller: controller);
      case RegistrationStep.serviceSubcategories:
        return RegistrationServiceSubcategoriesStep(controller: controller);
      case RegistrationStep.review:
        return RegistrationReviewStep(
          controller: controller,
          onEdit: (step) => controller.goToRegistrationStep(step),
        );
    }
  }

  Future<void> _onContinue(SignUpController controller) async {
    final step = controller.currentRegistrationStep;
    final valid = await _validateStep(controller, step);
    if (!valid) {
      controller.showRegistrationFieldErrors = true;
      controller.update();
      return;
    }
    controller.clearRegistrationFieldErrors();
    final saved = await controller.saveRegistrationStepToBackend(step);
    if (!saved) {
      controller.showRegistrationFieldErrors = true;
      controller.update();
    }
  }

  Future<bool> _validateStep(SignUpController controller, RegistrationStep step) async {
    switch (step) {
      case RegistrationStep.providerType:
        return true;
      case RegistrationStep.contactInfo:
        controller.checkOthersFieldValidity(step1: true);
        if (!(contactFormKey.currentState?.validate() ?? false)) {
          return false;
        }
        if (!controller.hasContactPhotoForSubmit) {
          showCustomSnackBar(trLabel('provide_contact_person_photo'));
          return false;
        }
        return _verifyContactCredentials(controller);
      case RegistrationStep.identityVerification:
        if (!(identityFormKey.currentState?.validate() ?? false)) {
          return false;
        }
        if (!controller.hasIdentityFront || !controller.hasIdentityBack) {
          showCustomSnackBar(trLabel('upload_id_front_and_back'));
          return false;
        }
        return true;
      case RegistrationStep.companyInformation:
        if (!(companyFormKey.currentState?.validate() ?? false)) {
          return false;
        }
        if (!controller.hasLogoForSubmit) {
          showCustomSnackBar(trLabel('provide_image_logo'));
          return false;
        }
        return true;
      case RegistrationStep.companyDocuments:
        if (!(companyDocsFormKey.currentState?.validate() ?? false)) {
          return false;
        }
        if (controller.selectedCompanyIdentityType.isEmpty) {
          showCustomSnackBar(trLabel('select_identity_type'));
          return false;
        }
        if (!controller.hasCompanyIdentityImagesForSubmit) {
          showCustomSnackBar(trLabel('provide_company_identity_image'));
          return false;
        }
        return true;
      case RegistrationStep.serviceAreas:
        if (controller.selectedZoneIds.isEmpty) {
          showCustomSnackBar(trLabel('select_at_least_one_zone'));
          return false;
        }
        return true;
      case RegistrationStep.currentAddress:
        if (!(addressFormKey.currentState?.validate() ?? false)) return false;
        controller.companyAddressController.text = controller.buildFormattedAddress();
        return controller.companyAddressController.text.isNotEmpty;
      case RegistrationStep.serviceCategories:
        if (!controller.hasSelectedCategories) {
          showCustomSnackBar(trLabel('select_at_least_one_category'));
          return false;
        }
        return true;
      case RegistrationStep.serviceSubcategories:
        if (!controller.hasSelectedSubCategories) {
          showCustomSnackBar(trLabel('select_at_least_one_subcategory'));
          return false;
        }
        return true;
      case RegistrationStep.review:
        return true;
    }
  }

  Future<bool> _verifyContactCredentials(SignUpController controller) async {
    if (controller.phoneVerifiedForRegistration) return true;

    final email = controller.contactPersonEmailController.text.trim();
    final phone = controller.countryDialCode +
        ValidationHelper.getValidPhone(
          '${controller.countryDialCode}${controller.contactPersonPhoneController.text}',
        );

    final value = await controller.checkUserCredentials(email, phone);
    if (value.statusCode == 200) return true;
    if (value.statusCode == 0) return false;

    contactFormKey.currentState?.validate();
    if (controller.emailErrorText != null) {
      contactEmailFocus.requestFocus();
    } else if (controller.phoneErrorText != null) {
      contactPhoneFocus.requestFocus();
    }
    return false;
  }

  Future<void> _submitRegistration(SignUpController controller) async {
    controller.companyAddressController.text = controller.buildFormattedAddress();

    final ready = await controller.prepareForFinalSubmit();
    if (!ready) {
      if (!controller.hasContactPhotoForSubmit) {
        showCustomSnackBar(trLabel('provide_contact_person_photo'));
        return;
      }
      if (controller.isCompanyProvider && !controller.hasLogoForSubmit) {
        showCustomSnackBar(trLabel('provide_image_logo'));
        return;
      }
      showCustomSnackBar(trLabel('complete_required_fields'));
      return;
    }

    if (controller.registrationToken == null || controller.registrationToken!.isEmpty) {
      showCustomSnackBar(trLabel('complete_required_fields'));
      return;
    }

    controller.registration(_getSignUpBody(controller));
  }

  SignUpBody _getSignUpBody(SignUpController signUpController) {
    final contactNumberWithCountryCode = signUpController.countryDialCode +
        ValidationHelper.getValidPhone(
          '${signUpController.countryDialCode}${signUpController.contactPersonPhoneController.text}',
        );

    String? companyPhone;
    String? companyEmail;
    String? companyName;
    if (signUpController.isCompanyProvider) {
      companyName = signUpController.companyNameController.text;
      companyPhone = signUpController.countryDialCode +
          ValidationHelper.getValidPhone(
            '${signUpController.countryDialCode}${signUpController.companyPhoneController.text}',
          );
      final companyEmailText = signUpController.companyEmailController.text.trim();
      companyEmail = companyEmailText.isNotEmpty ? companyEmailText : null;
    }

    return SignUpBody(
      providerType: signUpController.isCompanyProvider ? 'company' : 'individual',
      contactPersonEmail: signUpController.contactPersonEmailController.text.trim().isNotEmpty
          ? signUpController.contactPersonEmailController.text.trim()
          : null,
      contactPersonName: signUpController.contactPersonNameController.text,
      contactPersonPhone: contactNumberWithCountryCode,
      companyName: companyName,
      companyAddress: signUpController.buildFormattedAddress(),
      companyEmail: companyEmail,
      companyPhone: companyPhone,
      identityType: signUpController.selectedIdentityType,
      identityNumber: signUpController.identityNumberController.text,
      companyIdentityType: signUpController.isCompanyProvider ? signUpController.selectedCompanyIdentityType : null,
      companyIdentityNumber: signUpController.isCompanyProvider ? signUpController.companyIdentityNumberController.text : null,
      zoneIds: signUpController.selectedZoneIds,
      subscribedSubCategoryIds: signUpController.selectedSubCategoryIds,
      lat: '${Get.find<LocationController>().pickPosition.latitude}',
      lon: '${Get.find<LocationController>().pickPosition.longitude}',
      chooseBusinessPlan: 'commission_base',
      paymentPlatform: 'app',
      registrationToken: signUpController.registrationToken,
    );
  }
}
