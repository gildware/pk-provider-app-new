import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class CreateAdvertisementScreen extends StatefulWidget {
  final bool isEditScreen;
  final bool fromDetailsScreen;
  final bool isForResubmit;
  final AdvertisementData? advertisementData;
  const CreateAdvertisementScreen({super.key, required this.isEditScreen, this.advertisementData, this.fromDetailsScreen = false, this.isForResubmit = false});
  @override
  State<CreateAdvertisementScreen> createState() => _CreateAdvertisementScreenState();
}
class _CreateAdvertisementScreenState extends State<CreateAdvertisementScreen> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FocusNode _validationFocus = FocusNode();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final Language _defaultLanguage = Language(fullName: 'Default', languageCode: 'default');

  @override
  void initState() {

    if(widget.isEditScreen){
      titleController.text = widget.advertisementData?.defaultTitle ?? "";
      descriptionController.text = widget.advertisementData?.defaultDescription ?? "";

      AdvertisementController advertisementController = Get.find();
      advertisementController.initializeAdvertisementValues(widget.advertisementData!);
    }
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    Get.find<AdvertisementController>().videoPlayerController?.dispose();
    super.dispose();
  }

  List<TextEditingController> get _titleControllers => [titleController];
  List<TextEditingController> get _descriptionControllers => [descriptionController];
  List<Language> get _languageList => [_defaultLanguage];

  @override
  Widget build(BuildContext context) {

    return GetBuilder<AdvertisementController>( builder: (advertisementController) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: CustomAppBar(title: widget.isEditScreen && !widget.isForResubmit? "edit_advertisement".tr : "create_new_advertisement".tr),
        body: Column(children: [

          Expanded(
            child: SingleChildScrollView(
              physics:  const BouncingScrollPhysics(),
              child:Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: context.customThemeColors.lightShadow, color: Theme.of(context).cardColor,
                ),
                padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeDefault, vertical: 0),
                margin: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall,Dimensions.paddingSizeSmall,Dimensions.paddingSizeSmall,3),

                child: Form(key: formKey, autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    TextFieldTitle(title:"ads_type".tr,requiredMark: true, isPadding: false, fontSize: Dimensions.fontSizeExtraSmall,),

                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(width: Get.width, height: 40,
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: advertisementController.isDateRangeValid ? Theme.of(context).hintColor : Theme.of(context).colorScheme.error)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(padding: EdgeInsets.zero, dropdownColor: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(5),
                            elevation: 2,
                            hint: Text(advertisementController.selectedAdsType.tr,
                              style: robotoRegular.copyWith(
                                color: advertisementController.selectedAdsType==''?
                                Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.6):
                                Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.8),
                                fontSize: advertisementController.selectedAdsType ==''? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault,
                              ),
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: advertisementController.adsType.map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Row(children: [
                                  Text(items.tr,
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.7),
                                    ),
                                  ),
                                ]),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                            advertisementController.setAdsType(type: newValue!);
                            },
                          ),
                        ),
                      ),
                      if(!advertisementController.isDateRangeValid)
                        Padding(padding: const EdgeInsets.only(top : 5),
                          child: Text('fill_required_field'.tr,
                            style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall),
                          ),
                        )
                    ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),


                    InkWell(
                      onTap:()async{

                        DateTimeRange? dateTimeRange = await showDateRangePicker(
                          //locale: Get.find<LocalizationController>().locale,
                            initialEntryMode: DatePickerEntryMode.calendar,
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(3000),
                            currentDate: DateTime.now()
                        );

                        if(dateTimeRange != null){
                          advertisementController.dateTimeRange = dateTimeRange;
                          advertisementController.validationController?.text =
                              advertisementController.modifyDateRange();
                        }
                        setState(() {
                          formKey.currentState!.validate();
                        });
                      },
                      child: CustomTextField(
                        inputType: TextInputType.text,
                        controller: advertisementController.validationController,
                        hintText: "validation".tr,
                        title: "validation".tr,
                        focusNode: _validationFocus,
                        capitalization: TextCapitalization.sentences,
                        inputAction: TextInputAction.done,
                        isEnabled :  false,
                        suffixIcon: Images.customCalender,
                        onValidate: (value){
                          if(value == null || value.isEmpty){
                            return "enter_validation".tr;
                          }else if (value.isNotEmpty){
                            if(widget.isEditScreen){
                              bool isNotValidTimeRange = advertisementController.validateTimeRange();
                              if(isNotValidTimeRange){
                                return "Enter a valid date range";
                              }
                            }
                          }
                          return null;

                        },
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        color: context.adaptivePrimaryColor.withValues(alpha:0.04)
                      ),
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeSmall),

                      child: Column(children: [
                        CustomTextFieldWidget(
                          titleText: 'title'.tr,
                          controller: titleController,
                          focusNode: _titleFocus,
                          nextFocus: _descriptionFocus,
                          inputType: TextInputType.name,
                          capitalization: TextCapitalization.words,
                          labelText: 'title'.tr,
                          required: true,
                          validator: (value) => (value == null || value.isEmpty) ? 'enter_title'.tr : null,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),
                        CustomTextFieldWidget(
                          titleText: 'description'.tr,
                          controller: descriptionController,
                          focusNode: _descriptionFocus,
                          inputType: TextInputType.text,
                          capitalization: TextCapitalization.words,
                          maxLines: 2,
                          maxLength: 100,
                          labelText: 'description'.tr.replaceAll(':', ''),
                          required: true,
                          validator: (value) => (value == null || value.isEmpty) ? 'enter_description'.tr : null,
                        ),
                      ]),
                    ),

                    advertisementController.selectedAdsType != 'video_promotion' ? TextFieldTitle(title: 'show_review_ratings'.tr): const SizedBox(),
                    advertisementController.selectedAdsType != 'video_promotion' ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                        vertical: Dimensions.paddingSizeExtraSmall
                      ),
                      decoration: BoxDecoration(
                        color: context.adaptivePrimaryColor.withValues(alpha:0.05),
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                      ),
                      child: Wrap(
                        spacing: Dimensions.paddingSizeDefault,
                        runSpacing: Dimensions.paddingSizeExtraSmall,
                        children: [

                        CustomCheckBox(
                          value: advertisementController.isReviewChecked,
                          title: 'review'.tr,
                          onTap: ()=> advertisementController.toggleReviewChecked(),
                        ),

                        CustomCheckBox(
                          value: advertisementController.isRatingsChecked,
                          title: 'ratings'.tr,
                          onTap: ()=> advertisementController.toggleRatingChecked(),
                        ),

                        CustomCheckBox(
                          value: advertisementController.isShowcaseChecked,
                          title: 'work_showcase'.tr,
                          onTap: ()=> advertisementController.toggleShowcaseChecked(),
                        ),

                      ]),
                    ): const SizedBox(),

                    advertisementController.selectedAdsType != 'video_promotion' ? const SizedBox(height: Dimensions.paddingSizeDefault) : const SizedBox(),


                    advertisementController.selectedAdsType != 'video_promotion' ?
                    TextFieldTitle(title: "logo/profile".tr, subtitle: "(1:1)".tr, requiredMark: true): const SizedBox(),


                    advertisementController.selectedAdsType != 'video_promotion' ?
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [

                            advertisementController.pickedProfileImage!=null || advertisementController.networkProfileImage != null ?
                            const CreateAdvertisementLogoView() : DottedBorderBox(
                              height: 100, width: 100,
                              showErrorBorder: !advertisementController.isLogoValid,
                              onTap: ()=> advertisementController.pickProfileImage(false),
                            ),

                          ]),
                        ),

                        Expanded(child: ImageValidationTextWidget(
                          textAlign: TextAlign.start,
                          useSmallExtensionFont: true,
                        )),

                      ]),


                      !advertisementController.isLogoValid ?
                      Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                        child: Text("provide_image_logo".tr,
                          overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall),
                        ),
                      ) : const SizedBox()

                    ]) : const SizedBox(),


                    advertisementController.selectedAdsType != 'video_promotion' ?
                    const SizedBox(height: Dimensions.paddingSizeDefault) : const SizedBox(),


                    advertisementController.selectedAdsType == 'video_promotion' ?
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [


                      TextFieldTitle(title:"upload_video".tr, subtitle : "(16/9)".tr, requiredMark: true),


                      advertisementController.pickedVideoFile == null && advertisementController.networkVideoFile == null ?
                      AspectRatio(
                        aspectRatio: 16/9,
                        child: DottedVideoBorder(
                          showErrorBorder: !advertisementController.isVideoValid,
                          text: 'upload_video_message'.tr,
                          onTap: ()=> advertisementController.pickVideoFile(false),
                        ),
                      ) : advertisementController.videoPlayerController!.value.isInitialized ?
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: advertisementController.videoPlayerController!.value.aspectRatio,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              child: VideoPlayer(advertisementController.videoPlayerController!),
                            ),
                          ),

                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall - 5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              ),
                              child: InkWell(
                                  onTap: (){
                                    advertisementController.pickVideoFile(true);
                                  },
                                  child: Icon(
                                      Icons.close,
                                      color: Theme.of(context).colorScheme.error)
                              ),
                            ),
                          ),

                          FloatingActionButton.small(
                            backgroundColor: Colors.grey,
                            onPressed: () {
                              setState(() {
                                advertisementController.videoPlayerController!.value.isPlaying
                                    ? advertisementController.videoPlayerController!.pause()
                                    : advertisementController.videoPlayerController!.play();
                              });
                            },
                            child: Icon(
                              advertisementController.videoPlayerController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            ),
                          )
                        ],
                      ): const CreateAdvertisementVideoViewShimmer(),

                      !advertisementController.isVideoValid ?
                      Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                        child: Text("enter_video".tr,
                          overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall),
                        ),
                      ) : const SizedBox(),


                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      Text("${"maximum".tr} ${FileValidationHelper.formatFileSize(Get.find<SplashController>().configModel.content?.maxVideoUploadSize ?? 50)}",
                        style: robotoRegular.copyWith(fontSize: 12,
                          color: Theme.of(context).hintColor,
                        ),
                        maxLines: 5,
                      ),

                      Text("${"supports".tr} ${AppConstants.allowedVideoExtensions.join(', ').toUpperCase()}",
                        style: robotoRegular.copyWith(fontSize: 12,
                          color: Theme.of(context).hintColor,
                        ),
                        maxLines: 5,
                      ),

                      const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),


                    ]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      TextFieldTitle(title:"upload_cover_image".tr, subtitle : "(2:1)".tr, requiredMark: true),


                      advertisementController.pickedCoverImage != null || advertisementController.networkCoverImage != null ? Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 20/9,
                            child: advertisementController.pickedCoverImage != null && advertisementController.networkCoverImage == null ? ClipRRect(borderRadius: BorderRadius.circular(10),
                              child: Image.file(File(advertisementController.pickedCoverImage!.path),
                                  fit: BoxFit.cover, height: 100, width: 100
                              ),
                            ): advertisementController.networkCoverImage != null && advertisementController.pickedCoverImage == null ?
                            AspectRatio(
                                aspectRatio : 20/9,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CustomImage(
                                      image: "${advertisementController.networkCoverImage}"),
                                )
                            ): const SizedBox(),
                          ),

                          Positioned(top: -10, right: -10,
                              child: IconButton(onPressed: ()=> advertisementController.pickCoverImage(true),
                                  icon: const Icon(Icons.highlight_remove_rounded,color: Colors.red,size: 25)
                              )
                          ),
                        ],
                      ) : AspectRatio(
                        aspectRatio: 20/9,
                        child: DottedVideoBorder(
                          showErrorBorder: !advertisementController.isCoverImageValid,
                          text: 'upload_video_message'.tr,
                          onTap: ()=> advertisementController.pickCoverImage(false),
                        ),
                      ),


                      !advertisementController.isCoverImageValid ?
                      Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                        child: Text("enter_cover_image".tr,
                          overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall),
                        ),
                      ) : const SizedBox(),


                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      ImageValidationTextWidget(showRatioValidation: false),
                      const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

                    ]),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Row(mainAxisAlignment: MainAxisAlignment.end,
              children: [


                CustomButton(btnTxt: "reset".tr,
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor.withValues(alpha:0.2),
                  textColor: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha:0.8),
                  width: 100,height: 40,
                  onPressed: (){
                  if(widget.isEditScreen){
                    advertisementController.initializeAdvertisementValues(advertisementController.advertisementDetailsModel!.advertisementData!);
                  }else{
                    advertisementController.resetAllValues(shouldUpdate: true);
                  }

                  },
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                CustomButton(
                  btnTxt: widget.isEditScreen && !widget.isForResubmit? "re_submit".tr : "submit".tr, fontSize: Dimensions.fontSizeSmall, width: 100, height: 40,
                  isLoading : advertisementController.isLoading,
                  onPressed: (){
                    advertisementController.checkValidation();
                    if(widget.isEditScreen){
                      if(advertisementController.selectedAdsType == 'video_promotion'){
                        if(formKey.currentState!.validate() && advertisementController.isVideoValid){
                          if(widget.isForResubmit){
                            advertisementController.reSubmitAdvertisement(widget.advertisementData!, titleController: _titleControllers, descriptionController: _descriptionControllers, languageList: _languageList);
                          }else{
                            advertisementController.editAdvertisement(widget.advertisementData!, isFromDetailsPage: widget.fromDetailsScreen, titleController: _titleControllers, descriptionController: _descriptionControllers, languageList: _languageList);
                          }
                        }
                      }else{
                        if(formKey.currentState!.validate() && advertisementController.isCoverImageValid && advertisementController.isLogoValid){
                          if(widget.isForResubmit){
                            advertisementController.reSubmitAdvertisement(widget.advertisementData!,titleController: _titleControllers, descriptionController: _descriptionControllers, languageList: _languageList);
                          }else{
                            advertisementController.editAdvertisement(widget.advertisementData!, isFromDetailsPage: widget.fromDetailsScreen,titleController: _titleControllers, descriptionController: _descriptionControllers, languageList: _languageList);
                          }
                        }
                      }
                    }else{
                      if(advertisementController.selectedAdsType == 'video_promotion'){
                        if(formKey.currentState!.validate() && advertisementController.isVideoValid){
                          advertisementController.submitNewAdvertisement(titleController: _titleControllers, descriptionController: _descriptionControllers, languageList: _languageList);
                        }
                      }else{
                        if(formKey.currentState!.validate() && advertisementController.isCoverImageValid && advertisementController.isLogoValid){
                          advertisementController.submitNewAdvertisement(titleController: _titleControllers, descriptionController: _descriptionControllers, languageList: _languageList);
                        }
                      }
                    }

                   },
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),

              ],
            ),
          ),
        ]),

        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: FloatingActionButton(
            heroTag: 'create_screen',
            shape: const CircleBorder(),
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,

            onPressed: () {
              if(advertisementController.pickedVideoFile != null && advertisementController.videoPlayerController!.value.isInitialized){
                advertisementController.videoPlayerController!.pause();
              }

              advertisementController.selectedAdsType == 'video_promotion' ?
              showCustomDialog(child: PreviewVideoDialogWidget(
                title: titleController.text,
                description: descriptionController.text,
                validation: advertisementController.validationController?.text,
              ),
                barrierDismissible: true,): showCustomDialog(child: PreviewProviderPromotionWidget(
                title: titleController.text,
                description: descriptionController.text,
                validation: advertisementController.validationController?.text,
                pickedCoverImage: advertisementController.pickedCoverImage?.path,
                networkCoverImage: advertisementController.networkCoverImage,
                pickedProfileImage: advertisementController.pickedProfileImage?.path,
                networkProfileImage: advertisementController.networkProfileImage,
                isShowRatings: advertisementController.isRatingsChecked,
                isShowReview: advertisementController.isReviewChecked,
                isShowShowcase: advertisementController.isShowcaseChecked,
              ), barrierDismissible: true);
            },
            child: Icon(Icons.remove_red_eye_sharp, color: light.cardColor),
          ),
        ),
      );
    });
  }
}






