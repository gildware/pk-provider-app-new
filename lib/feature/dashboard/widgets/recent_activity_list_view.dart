import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class RecentActivityListView extends StatelessWidget {
  const RecentActivityListView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (dashboardController){
      return dashboardController.showNormalBooking ?  dashboardController.dashboardRecentActivityList.isNotEmpty ? ListView.builder(
        itemBuilder: (context, index) {
          return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Stack(children: [

              RecentActivityCardItem(
                dashboardRecentActivityModel: dashboardController.dashboardRecentActivityList[index],
              ),

              Positioned.fill(child: CustomInkWell(
                onTap:(){
                  if(dashboardController.dashboardRecentActivityList[index].isRepeatBooking == 1){
                    Get.toNamed(RouteHelper.getRepeatBookingDetailsRoute(
                        bookingId : dashboardController.dashboardRecentActivityList[index].id),
                    );
                  }else{
                    Get.toNamed(RouteHelper.getBookingDetailsRoute(
                        bookingId : dashboardController.dashboardRecentActivityList[index].id),
                    );
                  }
                }
              ))

            ]),

            if(index!=dashboardController.dashboardRecentActivityList.length-1) Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Divider(height: 1,color: Colors.grey[Get.isDarkMode ? 500 : 300]),
            ),

          ]);
        },
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: dashboardController.dashboardRecentActivityList.length,


      ): const Padding(padding: EdgeInsets.only(top: Dimensions.paddingSizeLarge),
          child: NoDataScreen(text: "you_have_no_normal_request", type: NoDataType.none,)) :
      dashboardController.dashboardCustomizedPostList.isNotEmpty ?
      ListView.builder(itemBuilder: (context, index){
        return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

          Container(
            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            padding:  const EdgeInsets.symmetric( vertical: Dimensions.paddingSizeSmall),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [
              ClipRRect(borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                child: CustomImage(height: 60, width: 60, fit: BoxFit.cover,
                  image: dashboardController.dashboardCustomizedPostList[index].service?.thumbnailFullPath??"",
                ),
              ),

              const SizedBox(width: Dimensions.paddingSizeDefault,),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.start,children: [
                  Text(dashboardController.dashboardCustomizedPostList[index].service?.name??"", style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault,color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.7)),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(dashboardController.dashboardCustomizedPostList[index].subCategory?.name??"",style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.5),),
                  ),
                  Text(DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate("${dashboardController.dashboardCustomizedPostList[index].createdAt}")),
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.5),
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                ],),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall,),

              GestureDetector(
                onTap: () async {
                 Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrial) async {
                   if(isTrial) {
                     if(Get.find<UserProfileController>().checkAvailableFeatureInSubscriptionPlan(featureType: 'bidding')){
                       await Get.to(()=> CustomerPostDetailsScreen(postData: dashboardController.dashboardCustomizedPostList[index], fromNotification: true, fromDashboard: true,));
                     }
                   }
                 });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall +2,vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Center(child: Text('place_offer'.tr, style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,color: Colors.white,
                  ),
                  ),),
                ),
              )
            ],),
          ),

          if(index!=dashboardController.dashboardRecentActivityList.length-1) Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Divider(height: 1,color: Colors.grey[Get.isDarkMode ? 500 : 300]),
          ),
        ]);
      },
        itemCount: dashboardController.dashboardCustomizedPostList.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
      ) : const Padding(padding: EdgeInsets.only(top: Dimensions.paddingSizeLarge),
        child: NoDataScreen(text: "you_have_no_customizes_request", type: NoDataType.none,),
      );
    });
  }
}
