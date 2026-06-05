import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<UserProfileController>(
        initState: (_) async {
          Get.find<BusinessSettingController>().getBookingSettingsDataFromServer();
          Get.find<UserProfileController>().getProviderInfo(reload: true);
          Get.find<TransactionController>().getWithdrawMethods();
        },
        builder: (userController) {
          if(userController.providerModel!=null){
            return  SingleChildScrollView(
              physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  profileHeaderSection(context,userController),

                  const ProviderPendingApprovalBanner(),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  GestureDetector(
                    onTap: () => Get.to(() => const ProfileInformationScreen()),
                    child: ProfileCardItem(title: "edit_profile", leadingIcon: Images.profileInformation),
                  ),

                  GestureDetector(
                    onTap: ()=> Get.to(() => const BusinessSettingScreen()),
                    child: ProfileCardItem(title: "business_settings", leadingIcon: Images.businessSettings),
                  ),

                  GestureDetector(
                    onTap: () => Get.to(() => const ShowcaseListScreen()),
                    child: ProfileCardItem(title: "work_showcase", leadingIcon: Images.chatImage),
                  ),

                  GestureDetector(
                    onTap: () {
                      Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrial){
                        if(isTrial){
                          if(userController.checkAvailableFeatureInSubscriptionPlan(featureType: 'review')){
                            Get.to(() => const ProviderReviewScreen());
                          }
                        }
                      });
                    },
                    child: ProfileCardItem(title: "reviews", leadingIcon: Images.reviewIcon),
                  ),

                  GestureDetector(
                    onTap: () {
                      Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrial){
                        if(isTrial){
                          if(userController.checkAvailableFeatureInSubscriptionPlan(featureType: "service_request")){
                            Get.toNamed(RouteHelper.suggestService);
                          }
                        }
                      });
                    },
                    child: ProfileCardItem(title: "suggest_service", leadingIcon: Images.suggestServiceIcon,isDarkItem: true,),
                  ),

                  Get.find<SplashController>().configModel.content?.providerSlfDelete == 1?
                  GestureDetector(
                    onTap: (){
                      showCustomBottomSheet(child: const DeleteAccountBottomSheet());
                    },
                    child: ProfileCardItem(title: "delete_account".tr, leadingIcon: Images.servicemanDelete,isDarkItem: true,),
                  ): const SizedBox(),

                  GestureDetector(
                    onTap: () => Get.to(() => const AccountInformation()),
                    child: ProfileCardItem(title: "account_information", leadingIcon: Images.accountInformation),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  RichText(
                    text: TextSpan(
                        text: "app_version".tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,color: Theme.of(context).primaryColorLight),
                        children: <TextSpan>[
                          TextSpan(
                            text: " ${AppConstants.appVersion} ",
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                          )
                        ]
                    ),
                  ),
                  
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],
              ),
            );
          }else{
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).hoverColor,),
            );
          }

        },
      ),
    );
  }

  Widget profileHeaderSection(BuildContext context,UserProfileController userController) {
    return Container(
      height: 310,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20)),
        color: Get.isDarkMode?Theme.of(context).primaryColorDark:Theme.of(context).primaryColor),

      child: Stack(
        children: [
          Container(
            height: 250, 
            width: MediaQuery.of(context).size.width-MediaQuery.of(context).size.width/4,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(300)
              ),
              color: Colors.white.withValues(alpha:.05),
              boxShadow:Get.isDarkMode? null: [
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 5,
                  color: Theme.of(context).primaryColor.withValues(alpha:0.3),
                )],
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              Padding(padding: const EdgeInsets.only(
                  top: Dimensions.paddingSizeDefault,
                  right: Dimensions.paddingSizeSmall,
                  left: Dimensions.paddingSizeSmall),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                           onPressed: ()=>Get.back(),
                           icon: Icon(Icons.arrow_back_ios,size: 16,color: light.cardColor)
                        ),
                        Text("my_profile".tr,style: robotoMedium.copyWith(fontSize: 16,
                           color: light.cardColor)
                        )
                      ],
                    ),

                    GetBuilder<ThemeController>(
                      builder: (themeController){
                        return GestureDetector(
                           onTap: ()=> themeController.toggleTheme(),
                           child: Container(height: 25, width: 45,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),
                              color: Colors.white.withValues(alpha:0.5)
                              ),
                             child: Row(
                               mainAxisAlignment: themeController.darkTheme?MainAxisAlignment.start:MainAxisAlignment.end,
                               children: [
                                 Container(
                                   height: 22,
                                   width: 22,
                                   margin: const EdgeInsets.all(2),
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(50),
                                     boxShadow: [
                                       BoxShadow(
                                         offset: const Offset(0, 2),
                                         blurRadius: 5,
                                         color: Colors.black.withValues(alpha:0.3),
                                       )],
                                     color: light.cardColor,),
                                   child: Icon(themeController.darkTheme ?
                                     Icons.dark_mode_outlined : Icons.light_mode_outlined,
                                     size: 16,
                                     color: Theme.of(context).primaryColor,
                                   ),
                                 ),
                               ],
                             ),
                          ),
                        );
                      },
                    ),
                ],),
              ),

              Padding( padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                child: Row(
                  children: [
                    ClipRRect(borderRadius: BorderRadius.circular(50),
                      child: CustomImage( height: 80, width: 80,
                        image: userController.providerModel?.content?.providerInfo?.displayLogoUrl ?? "",
                        placeholder: Images.userPlaceHolder,
                      )
                    ),

                    const SizedBox(width: Dimensions.paddingSizeDefault,),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userController.providerModel?.content?.providerInfo?.companyName??"",
                              style: robotoBold.copyWith(fontSize: 17, color: Colors.white),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

                          Text(userController.providerModel?.content?.providerInfo?.companyPhone?? userController.providerModel?.content?.providerInfo?.companyEmail??"",
                              style: robotoBold.copyWith(fontSize: 17, color: Colors.white),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),



              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                width: Get.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ColumnText(
                      amount: Get.find<DashboardController>().dashboardTopCards?.totalSubscribedServices.toString()??"",
                      title: "total_subscription".tr
                    ),

                    ColumnText(
                      amount: Get.find<DashboardController>().dashboardTopCards?.totalBookingServed.toString()??"",
                      title: "Booking_Served".tr
                    ),

                    ColumnText(
                      amount: DateTime.now().difference(DateConverter.isoStringToLocalDate(userController
                          .providerModel?.content?.providerInfo?.createdAt.toString()??DateTime.now().toString())).inDays.toString(),
                      title: "Days_Since_Joined".tr
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
