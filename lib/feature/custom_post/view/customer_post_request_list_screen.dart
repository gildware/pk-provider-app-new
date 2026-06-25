import 'package:demandium_provider/util/core_export.dart';
import 'package:demandium_provider/feature/custom_post/widget/custom_post_list_view.dart';
import 'package:get/get.dart';

class CustomerRequestListScreen extends StatefulWidget {
  final bool embeddedInBottomNav;
  const CustomerRequestListScreen({super.key, this.embeddedInBottomNav = false});

  @override
  State<CustomerRequestListScreen> createState() => _CustomerRequestListScreenState();
}

class _CustomerRequestListScreenState extends State<CustomerRequestListScreen> {

  @override
  void initState() {

    super.initState();
    Get.find<PostController>().setTabControllerIndex(index: 0);
    if(Get.find<PostController>().tabController!.index==0){
      Get.find<PostController>().getCustomerPostList(1,"new_request",reload: false, fromBid: false);
    }else{
      Get.find<PostController>().getCustomerPostList(1,"placed_offer",reload: false, fromBid: true);
    }

    Get.find<SplashController>().updateCustomBookingRedDotButtonStatus(status: false, shouldUpdate: true);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: widget.embeddedInBottomNav
          ? MainAppBar(title: 'post', color: context.adaptivePrimaryColor)
          : CustomAppBar(
        title: "custom_booking_request".tr,
        onBackPressed: (){
          if(Navigator.canPop(context)){
            Get.back();
          }else{
            Get.offNamed(RouteHelper.initial);
          }
        },
      ),

      body: GetBuilder<PostController>(
        builder: (postController){
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: TabBar(
                  unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
                  indicatorColor: context.tabIndicatorColor,
                  controller: postController.tabController,
                  labelColor: context.tabSelectedColor,
                  labelStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                  unselectedLabelStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                  labelPadding: EdgeInsets.zero,
                  tabs: [
                    Tab(text: 'new_request'.tr, height: 45),
                    Tab(text: 'my_bids'.tr, height: 45),
                  ],
                  onTap: (index)  {
                    if(index==0){
                      Get.find<PostController>().getCustomerPostList(1,"new_request", fromBid: false);
                    }else{
                      Get.find<PostController>().getCustomerPostList(1,"placed_offer", fromBid: true);
                    }
                  },
                ),
              ),

               Expanded(
                child: GetBuilder<PostController>(
                  builder: (postController) {
                    if(postController.loading){
                      return const Center(child: CircularProgressIndicator(),);
                    }else{
                      return CustomPostListview(
                        myPost: postController.tabController!.index == 0 ? postController.postList??[]: postController.bidPostList??[],
                        newRequest: postController.tabController!.index == 0 ? true : false,
                      );
                    }
                  }
                ),

              ),
            ],
          );
    },
      ),
    );
  }
}
