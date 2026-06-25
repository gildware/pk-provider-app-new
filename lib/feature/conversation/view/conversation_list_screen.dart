import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class ConversationListScreen extends StatefulWidget {
  final String? fromNotification;
  const ConversationListScreen({super.key, this.fromNotification});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> with SingleTickerProviderStateMixin {


  @override
  void initState() {
    super.initState();
    Get.find<ConversationController>().clearSearchController(shouldUpdate: false);
    _loadData();
  }

  Future<void> _loadData() async {
    await Get.find<ConversationController>().getChannelList(1, type: "customer");
    // SERVICEMAN_DISABLED
    if (AppFeatureFlags.servicemanEnabled) {
      await Get.find<ConversationController>().getChannelList(1, type: "serviceman");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'inbox'.tr,
        onBackPressed: (){


          if(widget.fromNotification == "fromNotification"){
            Get.offNamed(RouteHelper.getInitialRoute());
          }else{

            if(Get.find<ConversationController>().isActiveSuffixIcon && Get.find<ConversationController>().isSearchComplete){
              Get.find<ConversationController>().clearSearchController();

            }else{
              Get.back();
            }
          }
        },
      ),
      body: RefreshIndicator(
        color: context.adaptivePrimaryColor,
        backgroundColor: Theme.of(context).cardColor,
        onRefresh: () async=> Get.find<ConversationController>().getChannelList(1, reload: true),

        child: GetBuilder<ConversationController>(
          builder: (conversationController){


            if(conversationController.customerChannelList != null) {
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                const SizedBox(height: Dimensions.paddingSizeDefault),
                const ConversationSearchWidget(),
                const SizedBox(height: Dimensions.paddingSizeSmall,),

                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start , children: [

                    conversationController.adminConversationModel != null?
                    ChannelItem(
                      channelData: conversationController.adminConversationModel!,
                      isAdmin: true,
                    ): const SizedBox(),

                    const SizedBox(height: Dimensions.paddingSizeSmall,),
                    if (AppFeatureFlags.servicemanEnabled)
                      ConversationListTabview(tabController: conversationController.tabController),
                    const SizedBox(height: Dimensions.paddingSizeSmall,),

                    Expanded(
                      child: AppFeatureFlags.servicemanEnabled
                          ? TabBarView(
                              controller: conversationController.tabController,
                              children: [
                                conversationController.searchedChannelList == null &&
                                        !conversationController.isSearchComplete
                                    ? const ConversationSearchShimmer()
                                    : ConversationListView(
                                        channelList: conversationController.isSearchComplete
                                            ? conversationController.searchedCustomerChannelList
                                            : conversationController.customerChannelList!,
                                        tabIndex: 0,
                                      ),
                                conversationController.searchedChannelList == null &&
                                        !conversationController.isSearchComplete
                                    ? const ConversationSearchShimmer()
                                    : ConversationListView(
                                        channelList: conversationController.isSearchComplete
                                            ? conversationController.searchedServicemanChannelList
                                            : conversationController.servicemanChannelList ?? [],
                                        tabIndex: 1,
                                      ),
                              ],
                            )
                          : (conversationController.searchedChannelList == null &&
                                  !conversationController.isSearchComplete
                              ? const ConversationSearchShimmer()
                              : ConversationListView(
                                  channelList: conversationController.isSearchComplete
                                      ? conversationController.searchedCustomerChannelList
                                      : conversationController.customerChannelList!,
                                  tabIndex: 0,
                                )),
                    ),
                  ],),
                ),

              ],);
            }else{
              return const ConversationListShimmer();
            }
          },
        ),
      ),
    );
  }
}


