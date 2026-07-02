import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class ConversationDetailsAppBar extends StatelessWidget implements PreferredSizeWidget{
  final String? name;
  final String? image;
  final String? phone;
  final String fromNotification;
  final String? channelId;
  final String? userType;

  const ConversationDetailsAppBar({
    super.key,
    this.name,
    this.image,
    this.phone,
    this.fromNotification = "",
    this.channelId,
    this.userType,
  });

  @override
  Widget build(BuildContext context) {
    final displayPhone = AdminChatBrandingHelper.chatPhone(
      userType: userType,
      fallback: phone,
    );

    return AppBar(
      elevation: 5, titleSpacing: 0,
      backgroundColor: Theme.of(context).cardColor, surfaceTintColor: Theme.of(context).cardColor,
      shadowColor: Get.isDarkMode?Theme.of(context).primaryColor.withValues(alpha:0.5):Theme.of(context).primaryColor.withValues(alpha:0.1),

      title: Row( children: [

        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraLarge * 2),
          child: AdminChatBrandingHelper.isSuperAdmin(userType)
              ? AdminChatBrandingHelper.supportAvatar(size: 30)
              : CustomImage(
                  image: image,
                  height: 30,
                  width: 30,
                  placeholder: Images.userPlaceHolder,
                ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Text(name ?? "", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),

            if(displayPhone.isNotEmpty) Text(displayPhone, style: robotoLight.copyWith( fontSize: Dimensions.fontSizeSmall)),

          ]),
        ),
      ]),

      actions: [
        GetBuilder<InAppCallController>(builder: (callController) {
          if (!callController.shouldShowCallButton(channelId, userType)) {
            return const SizedBox.shrink();
          }

          return IconButton(
            onPressed: callController.busy
                ? null
                : () => callController.startCall(
                      channelId!,
                      peerName: name,
                      peerImage: image,
                      peerPhone: displayPhone,
                      peerUserType: userType,
                    ),
            icon: Icon(Icons.call, color: context.adaptiveIconColor),
            tooltip: 'call'.tr,
          );
        }),
        const SizedBox(width: 4),
      ],

      leading: Padding(
        padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
        child: IconButton(onPressed: () {
          if (fromNotification == 'fromNotification') {
            Get.offNamed(RouteHelper.getInboxScreenRoute(fromNotification: fromNotification));
          } else if (Navigator.canPop(context)) {
            Get.back();
          } else {
            Get.offNamed(RouteHelper.getInboxScreenRoute());
          }
        },
          icon: Icon(Icons.arrow_back_ios,
            color: context.adaptiveIconColor,
            size: Dimensions.paddingSizeLarge,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, 55);
}
