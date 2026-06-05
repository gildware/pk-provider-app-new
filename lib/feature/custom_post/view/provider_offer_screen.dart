import 'dart:math';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:demandium_provider/feature/custom_post/model/post_model.dart';
import 'package:get/get.dart';

class ProviderOfferScreen extends StatefulWidget {
  final PostData postData;
  final bool? fromNotification;
  final bool? fromDashboard;
  const ProviderOfferScreen({super.key, required this.postData, this.fromNotification, this.fromDashboard});

  @override
  State<ProviderOfferScreen> createState() => _ProviderOfferScreenState();
}

class _ProviderOfferScreenState extends State<ProviderOfferScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<PostController>().resetInputValue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "service_request".tr),
      body: ExpandableBottomSheet(
        background: GetBuilder<PostController>(builder: (postController){
          return GestureDetector(
            onTap: (){
              postController.hideInfoIcon();
            },
            child: SingleChildScrollView(
              child: Padding( padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
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
                            image: widget.postData.customer?.profileImageFullPath ?? "",
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
                        height: 40,width: 40,),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeLarge,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.postData.service?.name??"", style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault,), maxLines: 1, overflow: TextOverflow.ellipsis,),
                          Text(widget.postData.subCategory?.name??"",  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,color: Theme.of(context).secondaryHeaderColor.withValues(alpha:0.8)),maxLines: 1, overflow: TextOverflow.ellipsis,),
                        ],),
                    )
                  ],
                  ),

                  const SizedBox(height: Dimensions.paddingSizeDefault,),
                  TextFieldTitle(title: "offer_price".tr,requiredMark: false),

                  CustomTextFormField(
                    hintText: "Ex: 1000".tr,
                    inputType: TextInputType.number,
                    maxLines: 1,
                    controller: postController.offerPriceController,
                    focusNode: postController.offerPriceNode,
                    nextFocus: postController.providerNoteNode,
                  ),

                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.center,children: [
                        TextFieldTitle(title: "add_your_note".tr,requiredMark: false),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                        Padding(padding: const EdgeInsets.only(top: 5),
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: [
                              GestureDetector(
                                onTap: (){
                                 postController.changeNoteWidgetStatus();
                                },
                                  child: Icon(Icons.info_outline,size: 15 , color: Theme.of(context).primaryColor,)),
                              if(postController.showNoteInfoWidget)
                                Positioned(
                                  top: -19,
                                  child: Transform.rotate(
                                    angle:  45 * pi/180,
                                    child: Container(
                                      height: 15, width: 15, color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ]),

                      if(postController.showNoteInfoWidget)
                        Positioned(top: -39,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 30),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusLarge,),
                              color: Theme.of(context).primaryColorDark.withValues(alpha:0.95),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge,vertical: Dimensions.paddingSizeDefault),
                            child: Text("post_service_request_instruction".tr,
                              style: robotoRegular.copyWith(color: Colors.white.withValues(alpha:0.8),fontSize: Dimensions.fontSizeSmall),textAlign: TextAlign.center,
                            ),
                          ),
                        )
                    ],
                  ),

                  CustomTextFormField(
                    hintText: "write_something".tr,
                    inputType: TextInputType.text,
                    maxLines: 5,
                    controller: postController.providerNoteController,
                    focusNode: postController.providerNoteNode,
                    inputAction: TextInputAction.done,
                  ),
                ],),
              ),
            ),
          );
        }),
        persistentContentHeight: 80,
        expandableContent: GetBuilder<PostController>(builder: (postController){
          return AnimatedContainer(
            decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: context.customThemeColors.shadow,),
            duration: const Duration(seconds: 1),
            child: Column(
              children: [

                Container(height: 5,width: 50,decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  color: Theme.of(context).primaryColor.withValues(alpha:0.2),
                ),margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),),

                !postController.isLoading?
                CustomButton(
                  fontSize: Dimensions.fontSizeDefault,
                  btnTxt: "send_your_offer".tr,
                  height: 45,width: 250,
                  onPressed: (){

                    double amount =  double.tryParse(postController.offerPriceController.text)??0;
                    double minBiddingAmount = widget.postData.service?.minBiddingPrice ?? 0;

                    if(postController.offerPriceController.text.isEmpty){
                      showCustomSnackBar("enter_your_offer_price".tr, type : ToasterMessageType.info);
                    }else if(amount<minBiddingAmount){
                      showCustomSnackBar("${'minimum_bidding_amount'.tr} ${PriceConverter.convertPrice(minBiddingAmount)}");
                    }else{
                      postController.bidCustomBooking(
                        postId: widget.postData.id,
                        offerPrice: postController.offerPriceController.text,
                        note: postController.providerNoteController.text.isNotEmpty?postController.providerNoteController.text:"",
                        fromNotification: widget.fromNotification,
                        fromDashboard: widget.fromDashboard,
                      );
                    }
                  },
                ): const Padding(
                  padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                  child: Center(child: CircularProgressIndicator(),),
                ),


                !postController.isLoading?
                GestureDetector(
                  onTap: () async {
                    showCustomDialog(child: const CustomLoader());
                    await Get.find<PostController>().rejectCustomerPost(widget.postData.id!);
                    Get.back();
                    Get.back();
                  },
                  child: Padding( padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Text('not_interested'.tr, style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault+1, color: Theme.of(context).colorScheme.error,)
                    ),
                  ),
                ): const SizedBox(height: 15,),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

              ],
            ),
          );
        }),
      ),
    );
  }
}
