import 'dart:math';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:demandium_provider/feature/custom_post/model/post_model.dart';
import 'package:get/get.dart';

class CustomerPostDetailsScreen extends StatefulWidget {
  final PostData postData;
  final bool? fromNotification;
  final bool? fromDashboard;
  const CustomerPostDetailsScreen({super.key, required this.postData, this.fromNotification, this.fromDashboard});

  @override
  State<CustomerPostDetailsScreen> createState() => _CustomerPostDetailsScreenState();
}

class _CustomerPostDetailsScreenState extends State<CustomerPostDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<PostController>().resetInputValue();
    Get.find<PostController>().getProviderOfferList(1, widget.postData.id!,reload: true);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "service_request".tr),
      body: GetBuilder<PostController>(builder: (postController){
        return GestureDetector(
          onTap: (){
            postController.hideInfoIcon();
          },
          child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
              Stack(
                children: [
                  Center(child: Column(children: [
                    Padding( padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraLarge),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                        Text("new_booking_request_from".tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                        Stack(
                          alignment: Alignment.topCenter, clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                                onTap: (){
                                  postController.changeVisibilityInfoWidgetStatus();
                                },
                                child: Icon(Icons.info_outline,size: 18 , color: Theme.of(context).primaryColor,)),
                            if(postController.showInfoWidget)
                              Positioned(
                                top: 25,
                                child: Transform.rotate(
                                  angle:  45 * pi/180,
                                  child: Container(
                                    height: 15, width: 15, color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              )
                          ],
                        ),
                      ]),
                    ),

                    ClipRRect(borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child:CustomImage(height: 60, width: 60, fit: BoxFit.cover,
                        image: widget.postData.customer?.profileImageFullPath??"",
                      ),
                    ),

                    Padding(padding: const EdgeInsets.fromLTRB(0,Dimensions.paddingSizeDefault,0,Dimensions.paddingSizeExtraSmall-2),
                      child: Text("${widget.postData.customer?.firstName??""} ${widget.postData.customer?.lastName??""}",
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)
                      ),
                    ),
                    Text("${widget.postData.distance??"0 km"} ${'away_from_you'.tr}", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).secondaryHeaderColor.withValues(alpha:0.8))
                    ),
                  ])),
                  if(postController.showInfoWidget)
                    Positioned(top: 30, left: 20, right: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusLarge,),
                          color: Theme.of(context).primaryColorDark.withValues(alpha:0.95),
                        ),
                        width: Get.width*.85,
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge,vertical: Dimensions.paddingSizeDefault),
                        child: Text("accept_service_request_instruction".tr,
                          style: robotoRegular.copyWith(color: Colors.white.withValues(alpha:0.8),fontSize: Dimensions.fontSizeSmall),textAlign: TextAlign.center,
                        ),
                      ),
                    )
                ],
              ),

              const SizedBox(height: Dimensions.paddingSizeExtraLarge,),
              Row(crossAxisAlignment: CrossAxisAlignment.start,children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: CustomImage(
                    image: "${widget.postData.service?.thumbnailFullPath}",
                    height: 40,width: 40,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeLarge,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.postData.service?.name??"", style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault,), textAlign: TextAlign.justify,),
                      Text(widget.postData.subCategory?.name??"",
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,color: Theme.of(context).secondaryHeaderColor.withValues(alpha:0.8))),
                    ],),
                )
              ],
              ),
              Padding(padding: const EdgeInsets.fromLTRB(0,Dimensions.paddingSizeLarge,0,Dimensions.paddingSizeExtraSmall),
                child: Text("description".tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault,color: Theme.of(context).secondaryHeaderColor)),
              ),

              Text(widget.postData.serviceDescription??"",
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.justify,
                maxLines: 100,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge,),

              if(widget.postData.additionInstructions!.isNotEmpty)
              Text("additional_instruction".tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault,color: Theme.of(context).secondaryHeaderColor),
                maxLines: 1, overflow: TextOverflow.ellipsis,),
              const SizedBox(height: Dimensions.paddingSizeSmall,),
              ListView.builder(itemBuilder: (context,index){
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.2)),
                      color: Theme.of(context).primaryColor.withValues(alpha:0.05),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeSmall),

                    child: Text(widget.postData.additionInstructions![index].details??"",style: robotoRegular.copyWith(color: Theme.of(context).primaryColor,fontSize: Dimensions.fontSizeDefault),),
                  ),
                );
              },itemCount: widget.postData.additionInstructions!.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),

              const SizedBox(height: 100,)
            ]),
          )),
        );
      }),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
      Get.find<SplashController>().configModel.content?.bidOfferVisibilityForProvider==1?
      Padding(
        padding: EdgeInsets.symmetric(horizontal: Get.width*0.2,vertical: 55),
        child: GestureDetector(
          onTap: (){
            showModalBottomSheet(
                isScrollControlled: false,
                backgroundColor: Colors.transparent,
                context: Get.context!,
                builder: (context) => const OtherProviderOfferScreen()
            );
          },
          child: Container(height: 45,decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(50),
            boxShadow: Get.isDarkMode? null:[
              BoxShadow(
                offset: const Offset(0, 2),
                blurRadius: 5,
                color: Colors.black.withValues(alpha:0.2),
              )],
          ),
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeExtraSmall+2),
            child: Center(child: Text("see_other_provider_offers".tr,style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
            ),),),
          ),
        ),

      ):const SizedBox(),

      bottomSheet: Container(
        height: 60,
        decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: context.customThemeColors.shadow,),
        child: CustomButton(btnTxt: "place_your_offer".tr,height: 45,width: 250,
          fontSize: Dimensions.fontSizeDefault,
          onPressed: (){
            Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrial) async {
              if(isTrial) {
                if(Get.find<UserProfileController>().checkAvailableFeatureInSubscriptionPlan(featureType: 'bidding')){
                  Get.off(()=> ProviderOfferScreen(postData: widget.postData,fromNotification: widget.fromNotification, fromDashboard: widget.fromDashboard,));
                }
              }
            });
          },
        ),
      ),
    );
  }
}
