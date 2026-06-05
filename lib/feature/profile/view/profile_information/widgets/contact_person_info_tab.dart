import 'package:demandium_provider/feature/profile/view/profile_information/widgets/profile_image_preview_box.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class ContactPersonInfoTab extends StatefulWidget {
  const ContactPersonInfoTab({super.key});

  @override
  State<ContactPersonInfoTab> createState() => _ContactPersonInfoTabState();
}

class _ContactPersonInfoTabState extends State<ContactPersonInfoTab> {
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(builder: (c) {
      final photoUrl = c.providerModel?.content?.providerInfo?.contactPersonPhotoFullPath;
      final localPhoto = c.contactPersonPhotoFile?.path;

      return Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Form(
          key: c.contactPersonFormKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trLabel('contact_person_info_title'), style: robotoBold),
                      Text(
                        trLabel('setup_your_responsible_contact_person_information'),
                        style: robotoLight.copyWith(fontSize: Dimensions.fontSizeSmall),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Center(
                        child: ProfileContactPhotoPreview(
                          networkUrl: localPhoto == null ? photoUrl : null,
                          localFilePath: localPhoto,
                          onPick: c.pickContactPersonPhoto,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      CustomTextField(
                        title: trLabel('contact_person_name'),
                        controller: c.personalNameController,
                        hintText: trLabel('enter_contact_person_name'),
                        focusNode: _nameFocus,
                        nextFocus: _phoneFocus,
                        onValidate: (v) =>
                            (v == null || v.isEmpty) ? trLabel('enter_contact_person_name') : null,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),
                      CustomTextField(
                        onCountryChanged: (code) {
                          c.countryDialCode = code.dialCode!;
                          c.onContactPhoneChanged();
                        },
                        countryDialCode: c.countryDialCode,
                        title: trLabel('contact_person_phone'),
                        controller: c.personalPhoneController,
                        inputType: TextInputType.phone,
                        focusNode: _phoneFocus,
                        nextFocus: _emailFocus,
                        onChanged: (_) => c.onContactPhoneChanged(),
                        onValidate: (v) {
                          if (v == null || v.isEmpty) return trLabel('phone_number_hint');
                          if (c.phoneErrorText != null) return c.phoneErrorText;
                          return FormValidationHelper().isValidPhone(c.countryDialCode + v);
                        },
                      ),
                      if (c.hasContactPhoneChanged) ...[
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        if (c.isContactPhoneVerified)
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  trLabel('phone_number_verified'),
                                  style: robotoRegular.copyWith(
                                    color: Colors.green,
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          CustomButton(
                            btnTxt: trLabel('verify_phone_number'),
                            isLoading: c.isLoading,
                            height: 40,
                            onPressed: () => _verifyPhone(c),
                          ),
                      ],
                      const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),
                      CustomTextField(
                        title: trLabel('contact_person_email_optional'),
                        controller: c.personalEmailController,
                        inputType: TextInputType.emailAddress,
                        focusNode: _emailFocus,
                        inputAction: TextInputAction.done,
                        isRequired: false,
                        onValidate: (v) {
                          if (v != null && v.isNotEmpty) {
                            return FormValidationHelper().isValidEmail(v);
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              CustomButton(
                btnTxt: trLabel('save'),
                isLoading: c.isLoading,
                onPressed: () => _save(c),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 12),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _verifyPhone(UserProfileController c) async {
    if (!(c.contactPersonFormKey.currentState?.validate() ?? false)) return;

    final status = await c.startContactPhoneVerification();
    if (!status.isSuccess!) {
      showCustomSnackBar(status.message);
      return;
    }

    final phone = status.message ?? c.fullContactPhone;
    await Get.toNamed(
      RouteHelper.getVerificationRoute(
        identity: phone,
        identityType: 'phone',
        fromPage: 'profile-phone-change',
        firebaseSession: null,
        showSignUpDialog: false,
      ),
    );
  }

  Future<void> _save(UserProfileController c) async {
    if (!c.contactPersonFormKey.currentState!.validate()) return;
    if (!c.hasContactPhotoForSubmit) {
      showCustomSnackBar(trLabel('provide_contact_person_photo'));
      return;
    }
    if (c.hasContactPhoneChanged && !c.isContactPhoneVerified) {
      showCustomSnackBar(trLabel('phone_verification_required'));
      return;
    }

    final address = c.buildFormattedAddress().isNotEmpty
        ? c.buildFormattedAddress()
        : (c.providerModel?.content?.providerInfo?.companyAddress ?? '');
    final identityNumber =
        c.providerModel?.content?.providerInfo?.owner?.identificationNumber ?? '';
    final status = await c.updateProfile(
      address: address,
      identityNumber: identityNumber,
      validateContactIdentity: false,
    );
    if (status.isSuccess!) {
      showCustomSnackBar(trLabel('profile_updated_successfully'), type: ToasterMessageType.success);
    } else {
      showCustomSnackBar(status.message);
    }
  }
}
