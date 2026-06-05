import 'package:demandium_provider/common/widgets/circular_icon_button_widget.dart';
import 'package:demandium_provider/helper/help_me.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color color;
  final bool fromBookingRequest;
  final  double? titleFontSize;
  const MainAppBar({
    super.key,
    this.title,
    required this.color, this.fromBookingRequest = false, this.titleFontSize,
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
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall + 3, vertical: Dimensions.paddingSizeExtraSmall ),
            child: MobileAppIconHelper.homeLeadingLogo(
              width: 40,
              height: 40,
              fit: BoxFit.fitWidth,
            ),
          ),
          title: title!=null?
          Text(title!.tr,
            style: robotoBold.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: titleFontSize ?? Dimensions.fontSizeExtraLarge,
            ),
          ):MobileAppIconHelper.homeLogo(width: 110),
          actions: [

           if(fromBookingRequest) InkWell(
              onTap: (){
                Get.toNamed(RouteHelper.getCalendarOrderRoute());
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.1)),
                ),
                padding: const EdgeInsets.all(5),
                child: Icon(Icons.calendar_month_rounded, size: 22, color: Theme.of(context).hintColor),
              ),
            ),
            SizedBox(width: Dimensions.fontSizeExtraSmall),

            (fromBookingRequest && Get.find<SplashController>().configModel.content?.biddingStatus==1)?
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
                              color: Theme.of(context).primaryColor.withValues(alpha:Get.isDarkMode ? 0.2 : 0.08),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 12),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(option.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
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
                          color: Theme.of(context).hintColor,
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
            ) :
            Row(children: [
              Padding(padding: const EdgeInsets.only(top: 10.0), child: SizedBox(
                height: 20, width: 20,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Get.toNamed(RouteHelper.getInboxScreenRoute());
                    if(isRedundentClick(DateTime.now())){
                      return;
                    }
                  },
                  icon: Image.asset(Images.messageIcon, height: 20, width: 20)
                ),
              )),

              Padding(padding: const EdgeInsets.only(top: 10.0), child: Stack(children: [
                IconButton(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onPressed: () {
                    Get.toNamed(RouteHelper.getNotificationRoute());
                    if(isRedundentClick(DateTime.now())){
                      return;
                    }
                    notificationController.resetNotificationCount();
                  },
                  icon: Image.asset(Images.notificationIcon, height: 22, width: 22)
                ),
                if( notificationController.unseenNotificationCount>0)Positioned(
                  right: 2,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 3),
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor
                    ),
                    child: FittedBox(
                        child: Text(
                          notificationController.unseenNotificationCount.toString(),
                          style: robotoRegular.copyWith(color: light.cardColor
                          ),
                        )
                    ),
                  ),
                )
              ])),
              ]
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

