import 'package:demandium_provider/feature/tutorial/controller/tutorial_controller.dart';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';


class ServiceAvailabilityTabItemWidget extends StatelessWidget {
  const ServiceAvailabilityTabItemWidget({super.key});

  @override
  Widget build(BuildContext context) {

    JustTheController tooltipController = JustTheController();


    return GetBuilder<BusinessSettingController>(builder: ( businessSettingController){

      return Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        boxShadow: context.customThemeColors.lightShadow
                      ),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),

                      child: Column(children: [
                        SwitchButton(
                          titleText: "service_availability",
                          value: businessSettingController.serviceAvailabilitySettings ? 1 : 0,
                          onTap: (bool value) {
                            businessSettingController.toggleServiceAvailabilitySettings();
                          },
                          titleTextStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                          showOutSideBorder: true,
                          tootTipText: "",
                        ),

                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        Text("service_availability_hint".tr,
                          style: robotoRegular.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                              fontSize: Dimensions.fontSizeSmall + 1
                          ),
                          textAlign: TextAlign.justify,
                        )
                      ],),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: context.customThemeColors.lightShadow
                      ),
                      margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start ,children: [

                        Padding(
                          padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeLarge, Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall),
                          child: Row(children: [
                            Image.asset(Images.customCalender, height: 20, width: 20, color: Theme.of(context).primaryColor,),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                            Text("availability_schedule".tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                            JustTheTooltip( backgroundColor: Colors.black87, controller: tooltipController,
                              preferredDirection: AxisDirection.down, tailLength: 14, tailBaseWidth: 20,
                              content: Padding( padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                child:  Text("service_availability_hint_text".tr, style: robotoRegular.copyWith(color: Colors.white,)),
                              ),
                              child:  InkWell( onTap: ()=> tooltipController.showTooltip(),
                                child: Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.primary, size: 18,),
                              ),
                            )
                          ],),
                        ),

                        Divider(color: Theme.of(context).hintColor,),

                        Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          child: Text("service_providing_time".tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha:0.8)),),
                        ),

                        Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                          child: Row(
                            children: [

                              Text("from".tr, style: robotoRegular.copyWith(),),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                              TimePickerWidget(
                                title: 'open_time'.tr,
                                time: businessSettingController.serviceStartTime,
                                onTimeChanged: (time){
                                  businessSettingController.setServiceStartTime = time;
                                },
                              ),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                              Text("till".tr, style: robotoRegular.copyWith(),),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                              TimePickerWidget(
                                title: 'close_time'.tr, time: businessSettingController.serviceEndTime,
                                onTimeChanged: (time) =>businessSettingController.setServiceEndTime = time,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall,),

                        Divider(color: Theme.of(context).hintColor,),
                        Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          child: Text("weekend".tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha:0.8)),),
                        ),

                        GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 40,
                          ),
                          itemBuilder: (context,index){
                          return InkWell(
                            onTap: ()=>businessSettingController.toggleDaysCheckedValue(index),
                            child: CustomCheckBox(title:  businessSettingController.daysList[index],
                              value: businessSettingController.daysCheckList[index],
                              onTap: ()=>businessSettingController.toggleDaysCheckedValue(index),
                            ),
                          );
                        },itemCount: businessSettingController.daysList.length,
                          shrinkWrap: true,
                          physics : const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                        ),

                        const SizedBox(height: Dimensions.paddingSizeDefault * 1.5,),

                      ],),
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeSmall,),

            CustomButton(btnTxt: "save_information".tr,
              onPressed: () {
                final tutorialData = Get.find<UserProfileController>().providerModel?.content?.providerInfo?.tutorialData;

                if(tutorialData?[AppConstants.serviceAvailabilityTutorialKey]?.contains('0') ?? true) {
                  Get.find<TutorialController>().updateTutorial(key: AppConstants.serviceAvailabilityTutorialKey);
                }

                businessSettingController.updateServiceAvailabilitySettingsIntoServer();
              },
              isLoading: businessSettingController.isLoading,
            )
          ],
        ),
      );
    });
  }
}
