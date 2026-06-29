import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class ConversationListTabview extends StatelessWidget {
  final TabController? tabController;
  const ConversationListTabview({super.key, this.tabController});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConversationController>(builder: (conversationController){
      return Padding( padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: Row(
          children: [
            TabBar(
              controller: tabController,
              unselectedLabelColor: Colors.grey,
              isScrollable: true,
              dividerColor: Colors.transparent,
              indicatorColor: context.tabIndicatorColor,
              labelColor: context.tabSelectedColor,
              labelStyle: robotoMedium,
              indicatorWeight: 1,
              tabAlignment: TabAlignment.start,
              labelPadding: EdgeInsets.only(
                right: conversationController.isActiveSuffixIcon && conversationController.isSearchComplete
                    && conversationController.searchedCustomerChannelList.isNotEmpty ? 8 : 18,
              ),
              indicatorPadding: const EdgeInsets.only(right: 24),
              tabs:  [
                SizedBox(
                  height: 28,
                  child:Center(
                    child: Row(
                      children: [
                        Text("customer".tr),
                        conversationController.isActiveSuffixIcon && conversationController.isSearchComplete  && conversationController.searchedCustomerChannelList.isNotEmpty?
                        Container(height: 13 , width: 13,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, color: context.adaptivePrimaryColor,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.all(2),
                          child: FittedBox(child: Text(
                            conversationController.searchedCustomerChannelList.length.toString(),
                            style: robotoRegular.copyWith(color: Colors.white),
                          ),
                          ),
                        ) : const SizedBox(),
                      ],
                    ),
                  ),
                ),
                // SERVICEMAN_DISABLED
                if (AppFeatureFlags.servicemanEnabled)
                SizedBox(
                  height: 28,
                  child:  Center(
                    child: Row(
                      children: [
                        Text("serviceman".tr),
                        conversationController.isActiveSuffixIcon && conversationController.isSearchComplete  && conversationController.searchedServicemanChannelList.isNotEmpty?
                        Container(height: 13 , width: 13,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, color: context.adaptivePrimaryColor,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.all(2),
                          child: FittedBox(child: Text(
                              conversationController.searchedServicemanChannelList.length.toString(),
                            style: robotoRegular.copyWith(color: Colors.white),
                          ),
                          ),
                        ) : const SizedBox(),
                      ],
                    ),
                  ),
                ),
              ],
              onTap: (index){
                if( conversationController.isActiveSuffixIcon && conversationController.isSearchComplete){

                }else{
                  conversationController.getChannelList(1,type: index == 0 ? "customer": "serviceman");
                }
              },
            ),

            const Expanded(child: SizedBox()),

          ],
        ),
      );
    });
  }
}
