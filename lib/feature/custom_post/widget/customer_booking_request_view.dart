import 'package:demandium_provider/util/core_export.dart';
import 'package:demandium_provider/feature/custom_post/model/post_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class CustomerBookingAcceptView extends StatelessWidget {
  final PostData postData;
  const CustomerBookingAcceptView({super.key, required this.postData});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PostController>(builder: (postController){
      return Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
        child: Slidable(
          key: const ValueKey(1),
          closeOnScroll: false,
          endActionPane: postController.tabController?.index==0 ? ActionPane(
            motion: const ScrollMotion(),
            dismissible: null,
            extentRatio: 0.4,
            children:  [

              CustomSlidableAction(
                padding: const EdgeInsets.symmetric(vertical: 15),
                flex: 1,
                onPressed: (context)  {
                  showDialog(context: context, builder: (_){
                    return ConfirmationDialog(icon: Images.ignore,
                      title: 'ignore'.tr,
                      description: 'do_you_want_to_ignore_this_post'.tr, onYesPressed: () async{
                        Get.back();
                        showCustomDialog(child: const CustomLoader());
                        await Get.find<PostController>().rejectCustomerPost(postData.id!);
                        Get.back();
                      },);
                  });
                },
                backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha:0.12),
                foregroundColor: Colors.white,
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(Dimensions.radiusSmall),
                    bottomRight:  Radius.circular(Dimensions.radiusSmall)),
                child: Image.asset(Images.ignore,height: 27,width: 27,),
              ),
            ],
          ): null,

          child: Container(decoration: BoxDecoration(color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.15)),
          ),
            child: Column(
              children: [
                Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeDefault),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [
                    ClipRRect(borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: CustomImage(height: 40, width: 40, fit: BoxFit.cover,
                        image: postData.customer?.profileImageFullPath??"",
                      ),
                    ),

                    const SizedBox(width: Dimensions.paddingSizeSmall,),
                    Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                      Text("${postData.customer?.firstName??""} ${postData.customer?.lastName??""}",
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge,color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.7)),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text("${postData.distance??"0 km"} ${'away_from_you'.tr}",style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.4)),),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    ],)
                  ],),
                ),
                Divider(color: Theme.of(context).primaryColor.withValues(alpha:0.2),height: 1,),

                Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault,
                    horizontal: Dimensions.paddingSizeDefault),
                  child: Row(children: [
                    Image.asset(Images.calenderOutline,height: 20,width: 20,),
                    const SizedBox(width: Dimensions.paddingSizeDefault,),
                    Text(" ${DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate(postData.createdAt!))}",
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.8),
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ],),
                ),

                Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start,children: [
                    ClipRRect(borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: CustomImage(height: 30, width: 30, fit: BoxFit.cover,
                          image: postData.service?.thumbnailFullPath??""),
                    ),

                    const SizedBox(width: Dimensions.paddingSizeDefault,),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.start,children: [
                        Text(postData.service?.name??"", style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault,color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.7)),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall-2),
                        Text(postData.subCategory?.name??"",style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha:0.5)),),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      ],),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall,),

                    GestureDetector(
                      onTap: () async {
                        if(postController.tabController!.index==0){
                          Get.to(()=>CustomerPostDetailsScreen(postData: postData,));
                        }else{

                          showDialog(context: context, builder: (_){
                            return ConfirmationDialog(icon: Images.ignore,
                              title: 'withdraw'.tr,
                              description: 'do_you_want_to_withdraw_you_bid'.tr, onYesPressed: () async{
                                Get.back();
                                showCustomDialog(child: const CustomLoader());
                                await postController.withdrawBidRequest(postData.id!);

                              },);
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          color: Theme.of(context).primaryColor
                        ),
                        child: Center(child: Text(
                          postController.tabController!.index==0?'place_offer'.tr:'withdraw_request'.tr, style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,color: Colors.white
                        ),
                        ),),
                      ),
                    )
                  ],),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall,)
              ],
            ),
          ),
        ),
      );
    });
  }
}
