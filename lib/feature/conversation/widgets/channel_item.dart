import 'package:demandium_provider/feature/conversation/widgets/channel_last_message_status.dart';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class ChannelItem extends StatelessWidget {
  final ChannelData channelData;
  final bool isAdmin;
  const ChannelItem({super.key, required this.channelData, this.isAdmin = false, });
  @override
  Widget build(BuildContext context) {

    ConversationUserModel? conversationUser;
    int? isRead;
    int? isSeen;
    String? lastMessage;

    String currentUserName = "${Get.find<UserProfileController>().providerModel?.content?.providerInfo?.owner?.firstName ?? ''} ${Get.find<UserProfileController>().providerModel?.content?.providerInfo?.owner?.lastName ?? ''}".trim();
    final isLastMessageFromCurrentUser =
        channelData.lastMessageSentUser?.trim() == currentUserName;


    if(channelData.channelUsers !=null && channelData.channelUsers!.length > 1){
      conversationUser = channelData.channelUsers?[0].user?.userType != "provider-admin" ? channelData.channelUsers![0] : channelData.channelUsers![1];
      isRead = channelData.channelUsers![0].user?.userType == "provider-admin" ? channelData.channelUsers![0].isRead! : channelData.channelUsers![1].isRead!;
      isSeen = channelData.channelUsers?[0].user?.userType == "provider-admin" ? channelData.channelUsers![1].isRead : channelData.channelUsers![0].isRead;

    }

    if (isAdmin && conversationUser == null) {
      isRead = 1;
    }

    final isAdminChat = isAdmin ||
        AdminChatBrandingHelper.isSuperAdmin(conversationUser?.user?.userType);

    String imageWithPath = isAdminChat
        ? AdminChatBrandingHelper.logoImageUrl()
        : (conversationUser?.user?.profileImageFullPath ?? '');

    if(channelData.lastSentMessage !=null ){
      if(channelData.lastMessageSentUser?.trim() == currentUserName){
        lastMessage = "${'you'.tr}: ${channelData.lastSentMessage}";
      }else{
        lastMessage = "${channelData.lastSentMessage}";
      }

    }else{
      if(channelData.lastSentAttachmentType !=null){
       if((channelData.lastSentAttachmentType == "png" || channelData.lastSentAttachmentType == "jpg")){
         if(channelData.lastMessageSentUser?.trim() == currentUserName){

           if(channelData.lastSentFileCount!=null && channelData.lastSentFileCount! > 1){
             lastMessage = "${'you_sent'.tr} ${channelData.lastSentFileCount} ${'photos'.tr}";
           }else{
             lastMessage = "you_sent_a_photo".tr;
           }

         }else{

           if(channelData.lastSentFileCount!=null && channelData.lastSentFileCount! > 1){
             lastMessage = "${'sent'.tr} ${channelData.lastSentFileCount!} ${'photos'.tr}";
           }else{
             lastMessage = 'sent_a_photo'.tr;
           }

         }
       }else{

         if(channelData.lastMessageSentUser?.trim() == currentUserName){
           if(channelData.lastSentFileCount!=null && channelData.lastSentFileCount! > 1){
             lastMessage = "${'you_sent'.tr} ${channelData.lastSentFileCount} ${"attachments".tr}";
           }else{
             lastMessage = "you_sent_an_attachment".tr;
           }

         }else{
           if(channelData.lastSentFileCount!=null && channelData.lastSentFileCount! > 1){
             lastMessage = "${'sent'.tr} ${channelData.lastSentFileCount!} ${'attachments'.tr}";
           }else{
             lastMessage = 'sent_an_attachment'.tr;
           }

         }
       }
      }
    }

    final channelTimestamp = conversationUser?.updatedAt ??
        channelData.lastSentAt ??
        channelData.createdAt;

    if (!isAdmin && conversationUser == null) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: Dimensions.paddingSizeEight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: isRead == 0 ? Theme.of(context).primaryColor.withValues(alpha:Get.isDarkMode?0.2:0.05) : Theme.of(context).cardColor.withValues(alpha:Get.isDarkMode?0.5:1),
        boxShadow:  context.customThemeColors.lightShadow ,
        border: Border.all(
          color:  isRead == 0 ? Theme.of(context).primaryColor.withValues(alpha:0.5): Theme.of(context).cardColor,
          width: 0.5
        )
      ),
      child: Stack( children: [

        Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeEight),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: isAdminChat
                  ? AdminChatBrandingHelper.supportAvatar(size: 42)
                  : CustomImage(
                      height: 42,
                      width: 42,
                      image: imageWithPath,
                      placeholder: Images.userPlaceHolder,
                    ),
            ),

            const SizedBox(width: Dimensions.paddingSizeSmall),

            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Row(children: [
                Expanded(
                  child: Text(isAdminChat
                      ? AdminChatBrandingHelper.displayName
                      : "${conversationUser?.user?.firstName ?? ""} ${conversationUser?.user?.lastName}",
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha:0.7)
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                if (isAdminChat) Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha:.2),
                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 2),
                      child: Text('support'.tr, style: robotoMedium.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: Dimensions.fontSizeExtraSmall,
                      )),
                    ),
                  ),
                ),

                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                if (channelTimestamp != null && channelTimestamp.isNotEmpty)
                  Text(DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate(channelTimestamp)),
                    style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeExtraSmall),
                    textDirection: TextDirection.ltr,
                  ),
              ]),

              if(lastMessage!=null) Padding(padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(lastMessage.capitalizeFirst ?? "" ,
                        style: isRead ==0 ? robotoMedium.copyWith(
                          color: Theme.of(context).textTheme.bodySmall!.color!.withValues(alpha:0.7),
                          fontSize: Dimensions.fontSizeSmall,
                        ) : robotoRegular.copyWith(
                          color: Theme.of(context).textTheme.bodySmall!.color!.withValues(alpha:0.5),
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    if(isLastMessageFromCurrentUser) ChannelLastMessageStatus(
                      status: channelData.lastMessageStatus,
                      peerIsRead: isSeen,
                    ),
                  ],
                ),
              ),

            ])),
          ]),
        ),

        Positioned.fill(child: CustomInkWell(
          radius: Dimensions.radiusDefault,
          onTap:(){
            String name = isAdminChat
                ? AdminChatBrandingHelper.displayName
                : "${conversationUser?.user?.firstName ?? ""} ${conversationUser?.user?.lastName ?? ""}";
            String image = isAdminChat ? AdminChatBrandingHelper.logoImageUrl() : imageWithPath;
            String phone = AdminChatBrandingHelper.chatPhone(
              userType: isAdminChat ? 'super-admin' : conversationUser?.user?.userType,
              fallback: conversationUser?.user?.phone,
            );
            String userType = isAdminChat ? 'super-admin' : (conversationUser?.user?.userType ?? "");
            final channelId = channelData.id ?? conversationUser?.channelId ?? "";
            final conversationController = Get.find<ConversationController>();
            conversationController.setChannelId(channelId);
            conversationController.setActiveChannelPeer(
              userType: userType,
              name: name,
              image: image,
              phone: phone,
            );
            conversationController.prefetchConversation(channelId);
            Get.toNamed(RouteHelper.getChatScreenRoute(
                channelId,name,image,phone,userType));
          },
        ),)


      ],),

    );
  }
}

