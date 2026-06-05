import 'package:demandium_provider/util/core_export.dart';
import 'package:demandium_provider/feature/custom_post/model/post_model.dart';
import 'package:get/get.dart';

class NotificationDialog extends StatelessWidget {
  final PostData? postData;
  const NotificationDialog({super.key, this.postData});

  @override
  Widget build(BuildContext context) {


    return Padding(
      padding:const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge,vertical: 30),
      child: GestureDetector(
        onTap: ()=> Get.back(),
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          child: Column(mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: (){
                  Get.back();
                  Get.to(()=>CustomerPostDetailsScreen(postData: postData?? PostData(),fromNotification: true,));
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(child: const Row(mainAxisAlignment: MainAxisAlignment.end,children: [Icon(Icons.highlight_remove,size: 20,)]),
                          onTap: ()=>Get.back(),
                        ),

                        Stack(
                          children: [
                            Center(child: Column(children: [
                              Padding( padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraLarge),
                                child: Text("new_booking_request_from".tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),

                              ClipRRect(borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                child:CustomImage(height: 60, width: 60, fit: BoxFit.cover,
                                    image: postData?.customer?.profileImageFullPath??""),
                              ),

                              Padding(padding: const EdgeInsets.fromLTRB(0,Dimensions.paddingSizeDefault,0,Dimensions.paddingSizeExtraSmall-2),
                                child: Text("${postData?.customer?.firstName??" "} ${postData?.customer?.lastName??" "}",
                                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)
                                ),
                              ),
                              Text("${postData?.distance??"0 km"} ${'away_from_you'.tr}", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).secondaryHeaderColor.withValues(alpha:0.8))
                              ),
                            ])),
                          ],
                        ),

                        const SizedBox(height: Dimensions.paddingSizeExtraLarge,),
                        Row(crossAxisAlignment: CrossAxisAlignment.center,children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            child: CustomImage(
                              image: postData?.service?.thumbnailFullPath??"",
                              height: 40,width: 40,),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeLarge,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(postData?.service?.name??"", style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault), maxLines: 1, overflow: TextOverflow.ellipsis,),
                                Text(postData?.subCategory?.name??"",
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,color: Theme.of(context).secondaryHeaderColor.withValues(alpha:0.8)), maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          )
                        ],),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


