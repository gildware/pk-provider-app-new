import 'package:demandium_provider/feature/profile/model/provider_model.dart';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/feature/settings/business/controller/identity_controller.dart';
import 'package:demandium_provider/feature/settings/business/widget/identity_info_widget.dart';
import 'package:demandium_provider/feature/tutorial/controller/tutorial_controller.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BusinessInfoTabItemWidget extends StatefulWidget {
  const BusinessInfoTabItemWidget({super.key});
  @override
  State<BusinessInfoTabItemWidget> createState() => _BusinessInfoTabItemWidgetState();
}
class _BusinessInfoTabItemWidgetState extends State<BusinessInfoTabItemWidget> {

  final FocusNode _companyNameFocus= FocusNode();
  final FocusNode _companyPhoneFocus = FocusNode();
  final FocusNode _companyAddressFocus = FocusNode();
  final FocusNode _companyEmailFocus = FocusNode();

  final FocusNode _contactPersonNameFocus= FocusNode();
  final FocusNode _contactPersonPhoneFocus = FocusNode();
  final FocusNode _contactPersonEmailFocus = FocusNode();

  final TextEditingController companyAddressController = TextEditingController();
  final TextEditingController identityNumber = TextEditingController();
  final FocusNode _identityNumberFocus = FocusNode();


  String? address;

  @override
  void initState() {
    super.initState();
    Get.find<UserProfileController>().getProviderInfo(reload: true);

    final ProviderInfo? providerInfo = Get.find<UserProfileController>().providerModel?.content?.providerInfo;
   companyAddressController.text = providerInfo?.companyAddress ?? "";
   identityNumber.text = providerInfo?.owner?.identificationNumber ?? "";

   Get.find<IdentityController>().onChangeIdentityType(
     providerInfo?.owner?.identificationType, isUpdate: false,
   );

    Get.find<IdentityController>().initializeCurrentImage(providerInfo?.owner?.identificationImageFullPath ?? []);
    Get.find<IdentityController>().identityImagePickInitialize();

  }

  Future<void> _scrollToFocus(FocusNode focusNode) async {

    if (focusNode.context != null) {
      await Scrollable.ensureVisible(
        focusNode.context!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: GetBuilder<UserProfileController>(builder: (userProfileController) {
        return Skeletonizer(
          enabled: userProfileController.isLoading,
          child: Form(
            key: userProfileController.profileInformationFormKey,
            child: Container(color: Theme.of(context).colorScheme.surface,
              child: Column(children: [

                Expanded(child: SingleChildScrollView(
                  child: Column(children: [

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                      ),
                      child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          Text("basic_information".tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),

                          Text('setup_your_responsible_contact_person_information'.tr, style: robotoLight.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                          )),
                          const SizedBox(height: Dimensions.paddingSizeDefault),


                          BasicInfoWidget(
                            companyNameFocus: _companyNameFocus,
                            companyPhoneFocus: _companyPhoneFocus,
                            companyEmailFocus: _companyEmailFocus,
                            companyAddressFocus: _companyAddressFocus,
                            companyAddressController: companyAddressController,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          TextFieldTitle(title:"logo".tr,requiredMark: true, isPadding: false),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          LogoWidget(),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          TextFieldTitle(title:"cover_image".tr,requiredMark: true, isPadding: false),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          CoverImageWidget(),

                        ]),
                      ),
                    ),
                    SizedBox(height: Dimensions.paddingSizeDefault),

                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                      ),
                      child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          Text("contact_person".tr, style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          )),
                          Text('setup_your_responsible_contact_person_information'.tr, style: robotoLight.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                          )),

                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text("same_as_business_info".tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),

                              SizedBox(
                                width: Dimensions.paddingSizeLarge,
                                height: Dimensions.paddingSizeLarge,
                                child: Checkbox(
                                  side: BorderSide(width: 1, color: Theme.of(context).hintColor),
                                  checkColor: Theme.of(context).cardColor,
                                  activeColor: Theme.of(context).primaryColor,
                                  value: userProfileController.keepPersonalInfoAsCompanyInfo,
                                  onChanged: (bool? isChecked) => userProfileController.togglePersonalInfoAsCompanyInfo(),
                                ),
                              ),
                            ]),
                          ),


                          IgnorePointer(
                            ignoring: userProfileController.keepPersonalInfoAsCompanyInfo,
                            child: personalInfoSection(userProfileController,context),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),


                        ]),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    IdentityInfoWidget(identityNumberController: identityNumber, identityNumberFocus: _identityNumberFocus),




                  ]),
                )),

                Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                  child: CustomButton(
                    btnTxt: "save_information".tr,
                    isLoading: userProfileController.isLoading,
                    onPressed: ()=> _updateProfile(context, userProfileController),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ?MediaQuery.of(context).padding.bottom : 15,)
              ]),
            ),
          ),
        );

      })
    );
  }

  Widget profileImageSection(UserProfileController userProfileController) {
    return Container(
      height: 120,
      width: Get.width,
      margin:
          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Center(
        child: Stack(alignment: AlignmentDirectional.center,
          children: [
            userProfileController.pickedFile == null ?
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CustomImage(
                height: 100, width: 100, image: userProfileController.providerModel?.content?.providerInfo?.displayLogoUrl ?? "",
                placeholder: Images.userPlaceHolder,
              ),
            ) : CircleAvatar(radius: Dimensions.paddingSizeExtraLarge * 2, backgroundImage:FileImage(File(userProfileController.pickedFile!.path))),

            IconButton( onPressed: ()=>userProfileController.pickImage(),
              icon: Icon(Icons.camera_enhance_rounded, color: light.cardColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget personalInfoSection(UserProfileController userProfileController,BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: Dimensions.paddingSizeDefault),
        CustomTextField(
          title: "contact_person_name".tr,
          controller: userProfileController.personalNameController,
          hintText: "enter_contact_person_name".tr,
          maxLines: 1,
          capitalization: TextCapitalization.words,
          inputAction: TextInputAction.next,
          focusNode: _contactPersonNameFocus,
          nextFocus: _contactPersonPhoneFocus,
          onValidate: (value){
            return (value ==null || value.isEmpty) ? "enter_contact_person_name".tr : null;
          },
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

        CustomTextField(
          onCountryChanged: (CountryCode countryCode){
            userProfileController.countryDialCode = countryCode.dialCode!;
          },
          countryDialCode:  userProfileController.countryDialCode,
          title: "contact_person_phone".tr,
          hintText: 'enter_contact_person_phone_number'.tr,
          controller: userProfileController.personalPhoneController,
          inputType: TextInputType.phone,
          inputAction: TextInputAction.next,
          focusNode: _contactPersonPhoneFocus,
          nextFocus: _contactPersonEmailFocus,
          onValidate: (value){
            if(value == null || value.isEmpty){
              return 'phone_number_hint'.tr;
            }else{
              return FormValidationHelper().isValidPhone(userProfileController.countryDialCode+value);
            }
          },
        ),

        const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),


        CustomTextField(
          title: "contact_person_email_optional".tr,
          controller: userProfileController.personalEmailController,
          hintText: "enter_contact_person_email_address".tr,
          maxLines: 1,
          focusNode: _contactPersonEmailFocus,
          inputAction: TextInputAction.done,
          isRequired: false,
          onValidate: (value){
            if(value != null && value.isNotEmpty){
              return FormValidationHelper().isValidEmail(value);
            }
            return null;
          },
        ),
    ]);
  }

  void _updateProfile(BuildContext context, UserProfileController userProfileController) {
    final IdentityController indicatorController = Get.find<IdentityController>();

    if(indicatorController.isUploadEmpty()) {
      showCustomSnackBar('please_update_identity_images'.tr);
      return;
    }

    if((userProfileController.coverImageFile?.path.isEmpty ?? true) && (userProfileController.providerModel?.content?.providerInfo?.displayCoverUrl?.isEmpty ?? true)){
      showCustomSnackBar('please_update_cover_image'.tr);
      return;
    }


    final isValidForm = userProfileController.profileInformationFormKey.currentState!.validate();
    final isZoneValid = userProfileController.isZoneValid;


    if (!isValidForm || !isZoneValid) {
      if (userProfileController.companyNameController?.text.isEmpty ?? true) {
        _companyNameFocus.requestFocus();
        _scrollToFocus(_companyNameFocus);

      } else if ((userProfileController.companyPhoneController?.text.isEmpty ?? true) ||
          FormValidationHelper().isValidPhone(userProfileController.countryDialCode + userProfileController.companyPhoneController!.text) != null) {
        _companyPhoneFocus.requestFocus();
        _scrollToFocus(_companyPhoneFocus);
      } else if ((userProfileController.companyEmailController?.text.isEmpty ?? true) ||
          FormValidationHelper().isValidEmail(userProfileController.companyEmailController!.text) != null) {
        _companyEmailFocus.requestFocus();
        _scrollToFocus(_companyEmailFocus);
      } else if (companyAddressController.text.isEmpty) {
        _companyAddressFocus.requestFocus();
        _scrollToFocus(_companyAddressFocus);
      } else if (userProfileController.personalNameController?.text.isEmpty ?? true) {
        _contactPersonNameFocus.requestFocus();
        _scrollToFocus(_contactPersonNameFocus);
      } else if ((userProfileController.personalPhoneController?.text.isEmpty ?? true) ||
          FormValidationHelper().isValidPhone(userProfileController.countryDialCode + userProfileController.personalPhoneController!.text) != null) {
        _contactPersonPhoneFocus.requestFocus();
        _scrollToFocus(_contactPersonPhoneFocus);
      } else if ((userProfileController.personalEmailController?.text.isEmpty ?? true) ||
          FormValidationHelper().isValidEmail(userProfileController.personalEmailController!.text) != null) {
        _contactPersonEmailFocus.requestFocus();
        _scrollToFocus(_contactPersonEmailFocus);
      } else if (identityNumber.text.isEmpty) {
        _identityNumberFocus.requestFocus();
        _scrollToFocus(_identityNumberFocus);
      }
      return;
    }


    if(userProfileController.profileInformationFormKey.currentState!.validate() &&
        userProfileController.isZoneValid){
      if (kDebugMode) {
        print("Everything is perfect");
      }

      if(userProfileController.providerModel?.content?.providerInfo!.tutorialData?[AppConstants.businessInfoTutorialKey]?.contains('0') ?? true) {
        Get.find<TutorialController>().updateTutorial(key: AppConstants.businessInfoTutorialKey);
      }

      userProfileController.updateProfile(address: companyAddressController.text, identityNumber: identityNumber.text).then((status){
        Get.find<ServiceCategoryController>().changeCategory(0, isUpdate: true);
        if(status.isSuccess!){
          Get.find<IdentityController>().initializeCurrentImage(userProfileController.providerModel?.content?.providerInfo?.owner?.identificationImageFullPath ?? []);
          Get.find<IdentityController>().identityImagePickInitialize();

          Get.find<AuthController>().updateToken();
          Get.find<SubcategorySubscriptionController>().getMySubscriptionData(1,false);
          showCustomSnackBar("profile_updated_successfully".tr, type: ToasterMessageType.success);
        }
        else{showCustomSnackBar(status.message);}
      });
    }

  }
}

class BasicInfoWidget extends StatelessWidget {
  const BasicInfoWidget({
    super.key,
    required FocusNode companyNameFocus,
    required FocusNode companyPhoneFocus,
    required FocusNode companyEmailFocus,
    required FocusNode companyAddressFocus,
    required this.companyAddressController,
    this.showZonePicker = true,
    this.showAddressSection = true,
    this.companyEmailOptional = false,
  }) : _companyNameFocus = companyNameFocus, _companyPhoneFocus = companyPhoneFocus, _companyEmailFocus = companyEmailFocus, _companyAddressFocus = companyAddressFocus;

  final bool showZonePicker;
  final bool showAddressSection;
  final bool companyEmailOptional;

  final FocusNode _companyNameFocus;
  final FocusNode _companyPhoneFocus;
  final FocusNode _companyEmailFocus;
  final FocusNode _companyAddressFocus;
  final TextEditingController companyAddressController;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          CustomTextField(
            title: "company/individual_name".tr,
            controller: userProfileController.companyNameController,
            hintText: "company_name_hint".tr,
            maxLines: 1,
            capitalization: TextCapitalization.words,
            inputAction: TextInputAction.next,
            focusNode: _companyNameFocus,
            nextFocus: _companyPhoneFocus,
            onChanged: (value) {
              if(userProfileController.keepPersonalInfoAsCompanyInfo){
                userProfileController.personalNameController?.text = value;
              }
            },
            onValidate: (value){
              return (value == null || value.isEmpty) ? "enter_contact_person_name".tr : null;
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          CustomTextField(
            onCountryChanged: (CountryCode countryCode){
              userProfileController.countryDialCode = countryCode.dialCode!;
            },
            countryDialCode:  userProfileController.countryDialCode,
            title: "phone_number".tr,
            hintText: 'enter_company_phone_number'.tr,
            controller: userProfileController.companyPhoneController,
            inputType: TextInputType.phone,
            inputAction: TextInputAction.next,
            focusNode: _companyPhoneFocus,
            nextFocus: _companyEmailFocus,
            onChanged: (value) {
              if(userProfileController.keepPersonalInfoAsCompanyInfo){
                userProfileController.personalPhoneController?.text = value;
              }
            },
            onValidate: (value){
              if(value == null || value.isEmpty){
                return 'phone_number_hint'.tr;
              }else{
                return FormValidationHelper().isValidPhone(
                    userProfileController.countryDialCode+value
                );
              }
            },
          ),


          const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

          CustomTextField(
            title: "email".tr,
            inputType: TextInputType.emailAddress,
            controller: userProfileController.companyEmailController,
            hintText:'enter_company_email_address'.tr,
            focusNode: _companyEmailFocus,
            nextFocus: _companyAddressFocus,
            onChanged: (value) {
              if(userProfileController.keepPersonalInfoAsCompanyInfo){
                userProfileController.personalEmailController?.text = value;
              }
            },
            isRequired: !companyEmailOptional,
            onValidate: (value){
              if (companyEmailOptional) {
                if (value != null && value.isNotEmpty) {
                  return FormValidationHelper().isValidEmail(value);
                }
                return null;
              }
              if(value == null || value.isEmpty){
                return 'empty_email_hint'.tr;
              }else{
                return FormValidationHelper().isValidEmail(value);
              }
            },
          ),
          if (showAddressSection) ...[
          const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

          GetBuilder<LocationController>(builder: (locationController){


            return  GestureDetector(
              onTap: () async {
                await Get.to(()=> PickMapScreen(
                  initialPosition: LatLng(
                    userProfileController.providerModel?.content?.providerInfo?.coordinates?.latitude ?? 23.777176,
                    userProfileController.providerModel?.content?.providerInfo?.coordinates?.longitude ?? -90.399452,
                  ),
                  initialAddress:  userProfileController.providerModel?.content?.providerInfo?.companyAddress,
                ));
                companyAddressController.text = locationController.pickAddress.address !=null &&  locationController.pickAddress.address != ""
                    ? locationController.pickAddress.address! : userProfileController.providerModel?.content?.providerInfo?.companyAddress ?? "" ;
              },
              child: CustomTextField(
                title: "address".tr,
                controller: companyAddressController,
                hintText: "address_hint".tr,
                maxLines: 1,
                capitalization: TextCapitalization.sentences,
                inputAction: TextInputAction.next,
                focusNode: _companyAddressFocus,
                isEnabled: Get.find<LocationController>().pickAddress.address != "" ? true : false,
                suffixIcon: Images.pickPointLocation,
                onPressedSuffix: () async {
                  final defaultLatLng = Get.find<SplashController>().configModel.content?.defaultLocation?.defaultLocation;
                  await Get.to(()=> PickMapScreen(
                    initialPosition: LatLng(
                      userProfileController.providerModel?.content?.providerInfo?.coordinates?.latitude ?? defaultLatLng?.lat ?? 0,
                      userProfileController.providerModel?.content?.providerInfo?.coordinates?.longitude ?? defaultLatLng?.lon ?? 0,
                    ),
                    initialAddress:  userProfileController.providerModel?.content?.providerInfo?.companyAddress,
                  ));

                  companyAddressController.text = locationController.pickAddress.address !=null &&  locationController.pickAddress.address != ""
                      ? locationController.pickAddress.address! : userProfileController.providerModel?.content?.providerInfo?.companyAddress ?? "" ;
                },
                onValidate: (value){
                  return (value ==null || value.isEmpty) ? "enter_address".tr  : null;
                },
              ),
            );
          }),
          const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),
          ],

          if (showZonePicker) ...[
            TextFieldTitle(title:"select_zone".tr,requiredMark: true),
            Container(width: Get.width, height: 30,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(
                    color:Theme.of(context).disabledColor,width: 1
                )),
              ),

              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  menuMaxHeight: Get.height*.40,
                  dropdownColor: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  elevation: 8,
                  hint: Text(
                    userProfileController.selectedZoneName==""? userProfileController.myZone:userProfileController.selectedZoneName,
                    style: robotoRegular.copyWith(
                      color: userProfileController.selectedZoneName==''?
                      Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.6):
                      Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.8),
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: userProfileController.zoneList.map((ZoneData zoneData) {
                    return DropdownMenuItem(
                      value: zoneData,
                      child: Text(zoneData.name!,
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.6),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (ZoneData? zoneData) {
                    userProfileController.setNewZoneValue(zoneData!.name!,zoneData.id!);
                    userProfileController.onProfileChangeValidationCheck();
                  },
                ),
              ),
            ),
            if(!userProfileController.isZoneValid)
              Padding(padding: const EdgeInsets.only(top : 5),
                child: Text("fill_required_field".tr,
                  style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall),
                ),
              ),
          ],
        ]);
      }
    );
  }
}

class PendingBrandingBadge extends StatelessWidget {
  const PendingBrandingBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final warningColor = context.customThemeColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeExtraSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: warningColor.withValues(alpha: Get.isDarkMode ? 0.85 : 0.92),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Text(
        trLabel('pending_approval'),
        style: robotoMedium.copyWith(
          fontSize: 10,
          color: Get.isDarkMode ? Colors.white : const Color(0xFF3D2E00),
        ),
      ),
    );
  }
}

class LogoWidget extends StatelessWidget {
  const LogoWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(builder: (userProfileController) {
      final localPath = userProfileController.brandingLogoLocalPath;
      final networkUrl = userProfileController.brandingLogoDisplayUrl ?? '';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DottedBorderBox(
            child: SizedBox(width: 100, height: 100, child: Stack(children: [
              Positioned.fill(child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                child: localPath != null
                    ? Image.file(
                        File(localPath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : CustomImage(
                  image: networkUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorWidget: InkWell(
                    onTap: (){
                      userProfileController.pickImage();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.cloud_upload, color: Theme.of(context).hintColor),

                          Text('update_logo'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall))
                        ]),
                      ],
                    ),
                  ),
                ),
              )),

              if (userProfileController.showBrandingLogoPendingBadge)
                const Positioned(
                  left: 4,
                  bottom: 4,
                  child: PendingBrandingBadge(),
                ),


              if(_canEdit(userProfileController)) Positioned.fill(child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  highlightColor: Colors.transparent,
                  onPressed: (){
                    userProfileController.pickImage();
                  },
                  icon: Container(
                    transform: Matrix4.translationValues(8, -8, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: Theme.of(context).primaryColor),
                    ),
                    padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    child: Icon(Icons.edit, color: Theme.of(context).primaryColor, size: Dimensions.paddingSizeDefault,),
                  ),
                ),
              )),
            ])),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          const ImageValidationTextWidget(textAlign: TextAlign.start, separator: '. '),
        ],
      );
    });
  }

  bool _canEdit(UserProfileController userProfileController) => true;
}


class CoverImageWidget extends StatelessWidget {
  const CoverImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      GetBuilder<UserProfileController>(
        builder: (userProfileController) {
          final localPath = userProfileController.brandingCoverLocalPath;
          final networkUrl = userProfileController.brandingCoverDisplayUrl ?? '';

          return DottedBorderBox(
            width: context.width,
            height: (context.width / 3),
            child: Stack(children: [
              Positioned.fill(child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                child: localPath != null
                ? Image.file(
                  File(localPath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ) :
                CustomImage(
                  image: networkUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorWidget: InkWell(
                    onTap: ()=> userProfileController.pickCoverImage(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.cloud_upload, color: Theme.of(context).hintColor),

                          Text('update_cover_image'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall))
                        ]),
                      ],
                    ),
                  ),
                ),
              )),

              if (userProfileController.showBrandingCoverPendingBadge)
                const Positioned(
                  left: 4,
                  bottom: 4,
                  child: PendingBrandingBadge(),
                ),


             if(_canEdit(userProfileController)) Positioned.fill(child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  highlightColor: Colors.transparent,
                  onPressed: ()=> userProfileController.pickCoverImage(),
                  icon: Container(
                    transform: Matrix4.translationValues(8, -8, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: Theme.of(context).primaryColor),
                    ),
                    padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    child: Icon(Icons.edit, color: Theme.of(context).primaryColor, size: Dimensions.paddingSizeDefault,),
                  ),
                ),
              )),

            ]),
          );
        }
      ),
      SizedBox(height: Dimensions.paddingSizeSmall),
      ImageValidationTextWidget(textAlign: TextAlign.start, separator: '. ', ratio: '3:1',),

    ]);
  }

  bool _canEdit(UserProfileController userProfileController) => true;
}



