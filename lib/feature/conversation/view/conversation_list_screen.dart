import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class ConversationListScreen extends StatefulWidget {
  final String? fromNotification;
  const ConversationListScreen({super.key, this.fromNotification});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> with TickerProviderStateMixin {
  TabController? _inboxTabController;

  bool get _isCallingEnabled => InAppCallController.isFeatureEnabledFromConfig();

  @override
  void initState() {
    super.initState();
    _syncInboxTabController();
    Get.find<ConversationController>().clearSearchController(shouldUpdate: false);
    _loadData();
  }

  void _syncInboxTabController() {
    if (_isCallingEnabled && _inboxTabController == null) {
      _inboxTabController = TabController(length: 2, vsync: this);
      _inboxTabController!.addListener(_onInboxTabChanged);
    } else if (!_isCallingEnabled && _inboxTabController != null) {
      _inboxTabController!.removeListener(_onInboxTabChanged);
      _inboxTabController!.dispose();
      _inboxTabController = null;
    }
  }

  void _onInboxTabChanged() {
    if (_inboxTabController == null) return;
    if (_inboxTabController!.index == 1 && !_inboxTabController!.indexIsChanging) {
      Get.find<InAppCallController>().getCallHistory(1, reload: true);
    }
  }

  Future<void> _loadData() async {
    await Get.find<ConversationController>().getChannelList(1, type: "customer");
    if (AppFeatureFlags.servicemanEnabled) {
      await Get.find<ConversationController>().getChannelList(1, type: "serviceman");
    }
  }

  @override
  void dispose() {
    _inboxTabController?.removeListener(_onInboxTabChanged);
    _inboxTabController?.dispose();
    super.dispose();
  }

  void _handleBackNavigation() {
    if (widget.fromNotification == 'fromNotification') {
      Get.offNamed(RouteHelper.getInitialRoute());
      return;
    }
    final conversationController = Get.find<ConversationController>();
    if (conversationController.isActiveSuffixIcon && conversationController.isSearchComplete) {
      conversationController.clearSearchController();
      return;
    }
    popRouteOrGoHome(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (_) {
      final isCallingEnabled = _isCallingEnabled;
      final showCallingTabs = isCallingEnabled && _inboxTabController != null;
      if (isCallingEnabled != (_inboxTabController != null)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(_syncInboxTabController);
        });
      }

      return CustomPopScopeWidget(
        onPopInvoked: () {
          if (widget.fromNotification == 'fromNotification' || !Navigator.canPop(context)) {
            _handleBackNavigation();
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: CustomAppBar(
            title: 'inbox'.tr,
            onBackPressed: _handleBackNavigation,
          ),
          body: Column(
            children: [
              if (showCallingTabs)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: TabBar(
                    controller: _inboxTabController,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: context.tabIndicatorColor,
                    labelColor: context.tabSelectedColor,
                    labelStyle: robotoMedium,
                    tabs: [
                      Tab(text: 'chat'.tr),
                      Tab(text: 'calls'.tr),
                    ],
                  ),
                ),
              Expanded(
                child: showCallingTabs
                    ? TabBarView(
                        controller: _inboxTabController,
                        children: [
                          _buildChatTab(),
                          const CallHistoryListView(),
                        ],
                      )
                    : _buildChatTab(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildChatTab() {
    return RefreshIndicator(
      color: context.adaptivePrimaryColor,
      backgroundColor: Theme.of(context).cardColor,
      onRefresh: () async => Get.find<ConversationController>().getChannelList(1, reload: true),
      child: GetBuilder<ConversationController>(
        id: ConversationController.channelListUpdateId,
        builder: (conversationController) {
          if (conversationController.customerChannelList != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Dimensions.paddingSizeSmall),
                const ConversationSearchWidget(),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      conversationController.adminConversationModel != null
                          ? ChannelItem(
                              channelData: conversationController.adminConversationModel!,
                              isAdmin: true,
                            )
                          : const SizedBox(),
                      if (conversationController.adminConversationModel != null)
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      if (AppFeatureFlags.servicemanEnabled)
                        ConversationListTabview(tabController: conversationController.tabController),
                      if (AppFeatureFlags.servicemanEnabled)
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
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
                    ],
                  ),
                ),
              ],
            );
          }
          return const ConversationListShimmer();
        },
      ),
    );
  }
}
