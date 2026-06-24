import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class NoDataScreen extends StatelessWidget {
  final NoDataType? type;
  final String? text;
  final GlobalKey? showCaseKey;
  final bool isShowHomePage;
  const NoDataScreen({super.key, required this.text, this.type, this.showCaseKey, this.isShowHomePage = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: type == NoDataType.notification ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Row(),
        type != NoDataType.none ?
        Container(
          padding: type == NoDataType.notification ? EdgeInsets.all(MediaQuery.of(context).size.height * 0.03) : null,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Image.asset(
            type == NoDataType.conversation ? Images.chatImage :
            type == NoDataType.request ? Images.noData :
            type == NoDataType.notification ? Images.emptyNotification :
            type == NoDataType.transaction ? Images.noTransaction :
            type == NoDataType.service ? Images.settingsLoading :
            type == NoDataType.customPost ? Images.customPost :
            type == NoDataType.myBids ? Images.myBids :
            type == NoDataType.others ? Images.othersNoData :
            type == NoDataType.subscriptions ? Images.settingsIcon :
            type == NoDataType.paymentInfo ? Images.emptyPaymentInfo:
            type == NoDataType.advertisement ? Images.emptyAdvertisementIcon :
            Images.help,
            width: type == NoDataType.notification ? MediaQuery.of(context).size.height * 0.1 : MediaQuery.of(context).size.height * 0.06,
            height: type == NoDataType.notification ? MediaQuery.of(context).size.height * 0.1 : MediaQuery.of(context).size.height * 0.06,
            color: Get.isDarkMode && type == NoDataType.notification ? Theme.of(context).primaryColorLight : null,
          ),
        ) : const SizedBox(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        CustomShowCaseWidget(
          showcaseKey: showCaseKey,
          isActive: true,
          child: Padding(
            padding: type == NoDataType.notification ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault) : EdgeInsets.zero,
            child: Text(
              type == NoDataType.conversation ? 'your_inbox_list_empty_right_now'.tr :
              type == NoDataType.myBids ? 'bid_request_not_found'.tr :
              type == NoDataType.customPost ? 'new_request_not_found'.tr :
              type == NoDataType.others ? 'no_data_found'.tr :
              type == NoDataType.notification ? 'empty_notifications'.tr : text!.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: type == NoDataType.notification ? 0.4 : 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * (type == NoDataType.notification ? 0.04 : 0.08)),
        if (type == NoDataType.notification &&
            (ResponsiveHelper.isMobile(context) || ResponsiveHelper.isTab(context)) &&
            isShowHomePage)
          CustomButton(
            height: 40,
            width: 200,
            btnTxt: 'back_to_homepage'.tr,
            onPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
          ),
      ],
    );
  }
}