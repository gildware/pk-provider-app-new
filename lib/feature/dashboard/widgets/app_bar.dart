import 'package:demandium_provider/common/widgets/circular_icon_button_widget.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class _AppBarHeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final int? badgeCount;

  const _AppBarHeaderIconButton({
    required this.icon,
    required this.onPressed,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      splashRadius: 22,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, size: 22, color: context.adaptiveIconColor),
          if (badgeCount != null && badgeCount! > 0)
            Positioned(
              right: -2,
              top: -2,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                  height: 18,
                  width: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.adaptivePrimaryColor,
                  ),
                  child: FittedBox(
                    child: Text(
                      badgeCount! > 99 ? '99+' : badgeCount.toString(),
                      style: robotoRegular.copyWith(
                        color: light.cardColor,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color color;
  final bool fromBookingRequest;
  final bool showBackButton;
  final  double? titleFontSize;
  const MainAppBar({
    super.key,
    this.title,
    required this.color, this.fromBookingRequest = false, this.showBackButton = false, this.titleFontSize,
  });

  @override
  Widget build(BuildContext context) {

    return GetBuilder<NotificationController>(builder: (notificationController){
      return GetBuilder<SplashController>(builder: (splashController){

        List<String> bookingFilterList = ['all_booking', "regular_booking", "repeat_booking"];

        return AppBar(
          elevation: 7,
          titleSpacing: -5,
          surfaceTintColor: Theme.of(context).cardColor,
          backgroundColor: Theme.of(context).cardColor,
          shadowColor: Get.isDarkMode ? Theme.of(context).primaryColor.withValues(alpha:0.5) :Theme.of(context).primaryColor.withValues(alpha:0.1),
          leading: showBackButton
              ? IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: context.adaptivePrimaryColor,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall + 3, vertical: Dimensions.paddingSizeExtraSmall ),
                  child: MobileAppIconHelper.homeLeadingLogo(
                    width: 40,
                    height: 40,
                    fit: BoxFit.fitWidth,
                  ),
                ),
          title: title!=null?
          Text(title!.tr,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: robotoBold.copyWith(
              color: context.adaptivePrimaryColor,
              fontSize: titleFontSize ?? Dimensions.fontSizeExtraLarge,
            ),
          ):MobileAppIconHelper.homeLogo(width: 110),
          actions: [
            if (fromBookingRequest)
              IconButton(
                onPressed: () => Get.toNamed(RouteHelper.getCalendarOrderRoute()),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                splashRadius: 22,
                icon: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Get.isDarkMode ? Theme.of(context).cardColor : Colors.white,
                    border: Border.all(color: context.adaptivePrimaryColor.withValues(alpha:0.1)),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Icon(Icons.calendar_month_rounded, size: 22, color: context.adaptiveIconColor),
                ),
              ),
            _AppBarHeaderIconButton(
              icon: Icons.chat_bubble_outline_rounded,
              onPressed: () => Get.toNamed(RouteHelper.getInboxScreenRoute()),
            ),
            _AppBarHeaderIconButton(
              icon: Icons.notifications_outlined,
              badgeCount: notificationController.unseenNotificationCount,
              onPressed: () => Get.toNamed(RouteHelper.getNotificationRoute()),
            ),

            // Post/bidding shortcut — hidden unless enabled via admin (Mobile App Management → App Features).
            if (fromBookingRequest && Get.find<SplashController>().configModel.content?.biddingStatus==1)
            Row(
              children: [

                GetBuilder<BookingRequestController>(builder: (bookingRequestController){
                  return PopupMenuButton<String>(
                    shape:  RoundedRectangleBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall,)),
                        side: BorderSide(color: Theme.of(context).hintColor.withValues(alpha:0.1))
                    ),
                    surfaceTintColor: Theme.of(context).cardColor,
                    position: PopupMenuPosition.under, elevation: 8,
                    shadowColor: Theme.of(context).hintColor.withValues(alpha:0.3),
                    padding: EdgeInsets.zero,
                    menuPadding: EdgeInsets.zero,
                    itemBuilder: (BuildContext context) {
                      return bookingFilterList.map((String option) {
                        ServiceType  type = option == "regular_booking" ? ServiceType.regular :  option == "repeat_booking" ? ServiceType.repeat : ServiceType.all;
                        return PopupMenuItem<String>(
                          value: option,
                          padding: EdgeInsets.zero,
                          height: 45,
                          child:  bookingRequestController.selectedServiceType == type ?
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: context.adaptivePrimaryColor.withValues(alpha:Get.isDarkMode ? 0.2 : 0.08),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 12),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(option.tr, style: robotoRegular.copyWith(color: context.adaptivePrimaryColor)),
                              ],
                            ),
                          ) : Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                            child: Text(option.tr, style: robotoRegular,),
                          ),
                          onTap: (){
                            bookingRequestController.updateSelectedServiceType(
                                type: option == "regular_booking" ? ServiceType.regular :  option == "repeat_booking" ? ServiceType.repeat : ServiceType.all
                            );
                          },
                        );
                      }).toList();
                    },
                    child: CircularIconButtonWidget(
                      icon: Icons.filter_list,
                      showIndicator: bookingRequestController.selectedServiceType != ServiceType.all,
                    ),
                  );
                }),

                GestureDetector(
                  onTap: () => Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrial){
                    if(isTrial){
                      if(Get.find<UserProfileController>().checkAvailableFeatureInSubscriptionPlan(featureType: 'bidding')){
                        Get.to(()=> const CustomerRequestListScreen());
                      }
                    }
                  }),

                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        MobileAppIconHelper.icon(
                          key: 'post',
                          fallbackAsset: Images.customPostIcon,
                          width: 20,
                          height: 20,
                          color: context.adaptiveIconColor,
                        ),
                        if (splashController.showRedDotIconForCustomBooking)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).cardColor, width: 1),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: Dimensions.paddingSizeExtraSmall,
            )
          ],
        );
      });
    });
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 55);
}

