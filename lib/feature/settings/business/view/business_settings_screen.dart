import 'package:demandium_provider/feature/settings/business/widget/business_branding_tab_item_widget.dart';
import 'package:demandium_provider/feature/settings/business/widget/service_zone_tab_item_widget.dart';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class BusinessSettingScreen extends StatefulWidget{
  final int? tabIndex;
  const BusinessSettingScreen({super.key, this.tabIndex});

  @override
  State<BusinessSettingScreen> createState() => _BusinessSettingScreenState();
}

class _BusinessSettingScreenState extends State<BusinessSettingScreen> {

  @override
  void initState() {
    super.initState();
    UserProfileController.scheduleProfileDataLoad(reloadProvider: true);
    Get.find<BusinessSettingController>().initServiceLocationValue();
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<BusinessSettingController>(builder: (businessSettingController){
      return Scaffold( backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: CustomAppBar(title: "business_settings".tr),

        body:  SafeArea(
          child: DefaultTabController(length: 4, initialIndex: widget.tabIndex ?? 0, child: Column(children: [
            SizedBox(height: Dimensions.paddingSizeDefault),

            Container(
              height: 45,
              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: TabBar(
                isScrollable: true,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                  color: context.adaptivePrimaryColor,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                labelStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                unselectedLabelStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                tabAlignment: TabAlignment.start,
                dividerHeight: 0,
                labelPadding: EdgeInsets.symmetric(horizontal: 10),
                splashBorderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                tabs: [
                  Tab(child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                      color: context.adaptivePrimaryColor.withValues(alpha: 0.1),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Text(trLabel('business_branding')),
                  )),

                  Tab(child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                      color: context.adaptivePrimaryColor.withValues(alpha: 0.1),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Text(trLabel('service_zones')),
                  )),

                  Tab(child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                      color: context.adaptivePrimaryColor.withValues(alpha: 0.1),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      child: Text("service_availability".tr),
                    ),
                  )),

                  Tab(child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                      color: context.adaptivePrimaryColor.withValues(alpha: 0.1),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Text("bookings".tr),
                  )),
                ],
              ),
            ),

            const Expanded(child: TabBarView(
              children: [
                BusinessBrandingTabItemWidget(),
                ServiceZoneTabItemWidget(),
                ServiceAvailabilityTabItemWidget(),
                BookingSetupTabItemWidget(),
              ],
            )),


          ])),
        ),
      );
    });
  }
}

class SwitchButton extends StatelessWidget {
  final String titleText;
  final String tootTipText;
  final int value;
  final Function(bool) onTap;
  final JustTheController ? tooltipController;
  final bool showOutSideBorder;
  final TextStyle ? titleTextStyle;
  const SwitchButton({super.key, required this.titleText, required this.value, required this.onTap,this.tooltipController,this.showOutSideBorder = false, this.titleTextStyle, required this.tootTipText,});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: showOutSideBorder ? Border.all(color: context.adaptivePrimaryColor.withValues(alpha: 0.7)) : null,
        boxShadow: context.customThemeColors.lightShadow,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [ Row(children: [

        Text( titleText.tr, style: titleTextStyle ?? robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall,),

        if(tooltipController !=null)
        JustTheTooltip( backgroundColor: Colors.black87, controller: tooltipController,
          preferredDirection: AxisDirection.down, tailLength: 14, tailBaseWidth: 20,
          content: Padding( padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child:  Text(tootTipText.tr, style: robotoRegular.copyWith(color: Colors.white,)),
          ),
          child:  InkWell( onTap: ()=> tooltipController?.showTooltip(),
            child: Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.primary, size: 18,),
          )
        )]),

        FlutterSwitch(
          width: 40, height: 22, valueFontSize: Dimensions.fontSizeExtraSmall, showOnOff: true,
          activeText: "", inactiveText: "", activeColor: Theme.of(context).primaryColor,
          value: value == 1 ?  true : false,
          padding: 1.5,
          toggleSize: 19,
          onToggle: (value) => onTap(value),
        ),
      ],),
    );
  }
}