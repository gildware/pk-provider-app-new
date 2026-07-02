import 'dart:async';

import 'package:demandium_provider/feature/conversation/helper/conversation_download_port.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class ConversationDetailsScreen extends StatefulWidget {
  final String channelID;
  final String name;
  final String image;
  final String phone;
  final String userType;
  final String formNotification;

  const ConversationDetailsScreen({super.key,
    required this.name,
    required this.image,
    required this.channelID,
    required this.phone,
    required this.userType,
    this.formNotification = ""
  });

  @override
  State<ConversationDetailsScreen> createState() => _ConversationDetailsScreenState();
}

class _ConversationDetailsScreenState extends State<ConversationDetailsScreen> {

  String phone ='';
  Timer? _incomingCallPollTimer;
  late final VoidCallback _onDownloadUpdate;

  String? get _currentProviderUserId =>
      Get.find<UserProfileController>().providerModel?.content?.providerInfo?.userId;

  @override
  void initState() {
    super.initState();
    _onDownloadUpdate = () {
      if (mounted) {
        setState(() {});
      }
    };
    ConversationDownloadPort.attach(_onDownloadUpdate);

    final conversationController = Get.find<ConversationController>();
    conversationController.setChannelId(widget.channelID);
    conversationController.setActiveChannelPeer(
      userType: widget.userType,
      name: widget.name,
      image: widget.image,
      phone: widget.phone,
    );
    conversationController.getConversation(
      widget.channelID,
      1,
      refreshChannelList: false,
    );
    conversationController.resetControllerValue(shouldUpdate: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Get.find<InAppCallController>().loadConfig();
      Get.find<InAppCallController>().checkPendingIncomingCall();
      _incomingCallPollTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        Get.find<InAppCallController>().checkPendingIncomingCall();
      });
    });

    if(Get.find<SplashController>().configModel.content?.showPhoneNumber==0 && widget.userType.contains("customer")){
      phone = "";
    }else{
      phone = widget.phone != "" ? "+${widget.phone}" : "";
    }

    unawaited(NotificationHelper.setIosForegroundBannerEnabled(false));
  }

  @override
  void dispose() {
    _incomingCallPollTimer?.cancel();
    ConversationDownloadPort.detach(_onDownloadUpdate);
    if (Get.isRegistered<ConversationController>()) {
      final conversationController = Get.find<ConversationController>();
      conversationController.refreshActiveChannelListPreview();
      conversationController.clearActiveChannel();
    }
    unawaited(NotificationHelper.setIosForegroundBannerEnabled(true));
    super.dispose();
  }

  void _handleBackNavigation() {
    handleNotificationBack(
      fromNotification: widget.formNotification == 'fromNotification',
      whenFromNotification: () => Get.offNamed(
        RouteHelper.getInboxScreenRoute(fromNotification: widget.formNotification),
      ),
      context: context,
      whenCannotPop: () => Get.offNamed(RouteHelper.getInboxScreenRoute()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      onPopInvoked: () {
        if (widget.formNotification == 'fromNotification' || !Navigator.canPop(context)) {
          _handleBackNavigation();
        }
      },
      child: Scaffold(

      appBar: ConversationDetailsAppBar(
        fromNotification: widget.formNotification,
        name: widget.name, phone: phone, image: widget.image,
        channelId: widget.channelID,
        userType: widget.userType,
      ),

      body: GetBuilder<ConversationController>(
        id: ConversationController.chatMessagesUpdateId,
        builder: (conversationController) {

        return !conversationController.isFirst ? Column(children: [

          if (conversationController.isLoadingOlderMessages)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),

          conversationController.conversationList !=null && conversationController.conversationList!.isNotEmpty ?
          Expanded(child: ListView.builder(
            key: PageStorageKey<String>('provider_chat_${widget.channelID}'),
            controller: conversationController.messageScrollController,
            padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
            itemCount: conversationController.conversationList!.length,
            reverse: true,
            cacheExtent: 800,
            itemBuilder: (context, index) {

              bool isRightMessage = conversationController.conversationList!.elementAt(index).userId == _currentProviderUserId;
              final conversationData = conversationController.conversationList!.elementAt(index);
              return RepaintBoundary(
                child: ConversationBubbleWidget(
                key: ValueKey(conversationData.id ?? 'chat-msg-$index'),
                conversationData: conversationData,
                isRightMessage: isRightMessage,
                nextConversationData: index == (conversationController.conversationList!.length - 1)  ?
                null : conversationController.conversationList?.elementAt(index+1),
                previousConversationData:  index == 0  ?
                null : conversationController.conversationList?.elementAt(index-1),
              ),
              );

            },
          )) : Expanded(child: Center(child: Text('no_conversation_found'.tr),)),


          ConversationSendMessageWidget(channelId: widget.channelID,),


        ]) : const ConversationDetailsShimmer();
      }),
    ),
    );
  }
}
