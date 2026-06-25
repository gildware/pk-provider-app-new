import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';


class NoSubscriptionWidget extends StatelessWidget {
  final bool fromAll;
  const NoSubscriptionWidget({super.key, required this.fromAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        fromAll ? Align(
          alignment: Alignment.topCenter,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow:  [BoxShadow(
                offset: const Offset(0, 2),
                blurRadius: 10,
                color: Get.isDarkMode ? Colors.grey.shade800 :  Colors.grey.shade200,
              )],
            ),
            padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              RichText(
                text: TextSpan(
                  text: 'you_have'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodySmall?.color),
                  children: <TextSpan>[
                    TextSpan(text: '0' , style: robotoBold.copyWith(color: context.adaptivePrimaryColor, fontSize: Dimensions.fontSizeDefault)),
                    TextSpan(text: 'subscription'.tr , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                  ],
                ),
              )
              ],
            ),
          ),
        ) : const SizedBox(),


        Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.start,
            children: [

              SizedBox(height:  MediaQuery.of(context).size.height * 0.10),

              Column(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Images.noSubscriptionFoundImage,
                    width: MediaQuery.of(context).size.height * 0.10,
                    height: MediaQuery.of(context).size.height * 0.10,
                  ),
                  SizedBox(height: Dimensions.paddingSizeSmall),

                  Text('no_subcategories_subscribed_yet'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                ],
              ),
              SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

              if(!fromAll)  GestureDetector(
                onTap: (){
                  Get.find<ServiceCategoryController>().changeCategoryToSubscribedMenuIndex(
                    Get.find<ServiceCategoryController>().selectedSubsCategoryIndex,
                  );
                  Get.offAllNamed(RouteHelper.getAllServicesRoute());
                  },
                child: Text("+ ${"subscribe_subcategory".tr}",
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault,
                    decoration: TextDecoration.underline,
                    color: context.adaptivePrimaryColor,
                    decorationColor: context.tabSelectedColor,
                  ),
                ),
              ),


              if(fromAll)...[
                Container(
                  margin: EdgeInsets.all(Dimensions.paddingSizeDefault),
                  padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                      color: context.adaptivePrimaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(Dimensions.radiusLarge)
                  ),
                  child: Column(
                    children: [
                      Text('subscribed_to_new_subcategory'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                      SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Text('yet_you_havent_choose'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault), textAlign: TextAlign.center,),
                      SizedBox(height: Dimensions.paddingSizeDefault),

                      InkWell(
                        onTap: () {
                          Get.offAllNamed(RouteHelper.getAllServicesRoute());
                        },
                        child: Container(
                          padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                              color: context.adaptivePrimaryColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              Container(
                                padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).cardColor
                                ),
                                child: Icon(Icons.add, color: context.adaptivePrimaryColor, size: 20),
                              ),
                              SizedBox(width: Dimensions.paddingSizeEight),

                              Text('subscribe'.tr, style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeDefault)),
                              SizedBox(width: Dimensions.paddingSizeSmall),
                            ],
                          ),
                        ),
                      )

                    ],
                  ),
                )
              ]

            ],
          ),
        )




      ],
    );
  }
}
