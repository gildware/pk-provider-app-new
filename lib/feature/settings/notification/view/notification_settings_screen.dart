import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class NotificationSettingScreen extends StatefulWidget{
  const NotificationSettingScreen({super.key});

  @override
  State<NotificationSettingScreen> createState() => _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {

    NotificationSetupController controller = Get.find<NotificationSetupController>();
    controller.clearSearchController(shouldUpdate: false);
    controller.getNotificationSetupList(type: "provider");
    // SERVICEMAN_DISABLED
    if (AppFeatureFlags.servicemanEnabled) {
      controller.getNotificationSetupList(type: "serviceman");
    }
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<NotificationSetupController>(builder: (businessSettingController){
      return Scaffold( backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: CustomAppBar(title: "notification_channel_setup".tr),

        body:  Column(children: [

          Container(
            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Colors.blue
                  )
              ),
            ),
            child: TabBar(
              unselectedLabelColor:Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha:0.5),
              indicatorColor: context.tabIndicatorColor,
              labelColor: Theme.of(context).primaryColorLight,
              labelStyle:  robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              labelPadding: EdgeInsets.zero,
              controller: businessSettingController.tabController,
              tabs: [
                SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width * (AppFeatureFlags.servicemanEnabled ? .5 : 1),
                  child: Center(
                    child: Text("notification_for_you".tr),
                  ),
                ),
                // SERVICEMAN_DISABLED
                if (AppFeatureFlags.servicemanEnabled)
                  SizedBox(
                    height: 40,
                    width: MediaQuery.of(context).size.width * .4,
                    child: Center(
                      child: Text("serviceman".tr),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault,),
          NotificationSetupSearchWidget(tabController: businessSettingController.tabController,),

          const SizedBox(height: Dimensions.paddingSizeSmall,),

          Expanded(
            child: TabBarView(
              controller: businessSettingController.tabController,
              children: [
                const ProviderNotificationSetup(),
                // SERVICEMAN_DISABLED
                if (AppFeatureFlags.servicemanEnabled) const ServicemanNotificationSetup(),
              ],
            ),
          ),
        ]),
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
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: showOutSideBorder ? Border.all(color: context.adaptivePrimaryColor) : null
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