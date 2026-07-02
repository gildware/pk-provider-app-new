import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:demandium_provider/common/widgets/demo_reset_dialog_widget.dart';
import 'package:demandium_provider/firebase_options.dart';
import 'package:demandium_provider/helper/booking_notification_constants.dart';
import 'package:demandium_provider/helper/error_logger.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:demandium_provider/helper/notification_sound_util.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class NotificationHelper {

  static bool _foregroundMessagingRegistered = false;

  /// iOS foreground: when true, FCM/APNS shows the system banner (used off chat).
  /// When false, banners are suppressed while viewing a chat thread.
  static Future<void> setIosForegroundBannerEnabled(bool enabled) async {
    if (!GetPlatform.isIOS) {
      return;
    }

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: enabled,
      badge: true,
      sound: enabled,
    );
  }

  static Future<void> createAndroidNotificationChannels(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    if (!GetPlatform.isAndroid) return;

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await NotificationSoundUtil.deleteLegacyAndroidChannels(androidPlugin);
    for (final channel in NotificationSoundUtil.buildAndroidChannels()) {
      await androidPlugin?.createNotificationChannel(channel);
    }
  }

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    await createAndroidNotificationChannels(flutterLocalNotificationsPlugin);
    var androidInitialize = const AndroidInitializationSettings('notification_icon');
    const iOSInitialize = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationsSettings,
      onDidReceiveNotificationResponse: (NotificationResponse? notificationResponse) async {
        try {
          if (notificationResponse == null) {
            return;
          }

          final payload = notificationResponse.payload;
          if (payload == null || payload.isEmpty) {
            return;
          }

          final data = Map<String, dynamic>.from(jsonDecode(payload));
          if (data['type']?.toString() == 'booking' &&
              data['booking_id'] != null &&
              data['booking_id'].toString().isNotEmpty) {
            _openBookingFromNotificationData(data);
            return;
          }

          if (_isInAppCallEvent(data['type']?.toString())) {
            if (Get.isRegistered<InAppCallController>()) {
              unawaited(Get.find<InAppCallController>().handlePushData(data));
            }
            return;
          }

          NotificationBody notificationBody = NotificationBody.fromJson(data);
          if (kDebugMode) {
            print("Type: ${notificationBody.notificationType}");
          }
          if(notificationBody.notificationType=="chatting"){
            openChatFromNotification(notificationBody);
          }
          else if(_isInAppCallEvent(notificationBody.notificationType)){
            if(Get.isRegistered<InAppCallController>()){
              unawaited(Get.find<InAppCallController>().handlePushData(notificationBody.toJson()));
            }
          }
          else if(notificationBody.notificationType=='bidding'){
            Get.to(()=>const CustomerRequestListScreen());
          }
          else if(notificationBody.notificationType=='booking' && notificationBody.bookingId != null && notificationBody.bookingId != ''){
            if(notificationBody.bookingType == "repeat" && notificationBody.repeatBookingType == "single"){
              Get.toNamed(RouteHelper.getBookingDetailsRoute( subBookingId : notificationBody.bookingId, fromPage : "fromNotification"));
            }else if(notificationBody.bookingType == "repeat" && notificationBody.repeatBookingType != "single"){
              Get.toNamed(RouteHelper.getRepeatBookingDetailsRoute( bookingId : notificationBody.bookingId, fromPage : "fromNotification"));
            }else{
              Get.toNamed(RouteHelper.getBookingDetailsRoute( bookingId : notificationBody.bookingId, fromPage : "fromNotification"));
            }
          } else if(notificationBody.notificationType == 'privacy_policy' && notificationBody.title!=null && notificationBody.title!=''){
            Get.toNamed(RouteHelper.getHtmlRoute(HtmlType.privacyPolicy.value));
          }else if(notificationBody.notificationType == 'terms_and_conditions' && notificationBody.title!=null && notificationBody.title!=''){
            Get.toNamed(RouteHelper.getHtmlRoute(HtmlType.termsAndCondition.value));
          }else if(notificationBody.notificationType == 'withdraw'){
            Get.toNamed(RouteHelper.getTransactionListRoute(fromPage: "fromNotification"));
          }
          else if(notificationBody.notificationType == 'admin_pay'){
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }
          else if(notificationBody.notificationType == 'service_request'){
            Get.to(()=> const SuggestedServiceListScreen());
          }
          else if(notificationBody.notificationType == 'showcase'){
            Get.to(() => const ShowcaseListScreen());
          }
          else if(notificationBody.notificationType == 'maintenance'){
            Get.toNamed(RouteHelper.getSplashRoute());
          }
          else if(notificationBody.notificationType == 'suspend'){
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }
          else if(notificationBody.notificationType == 'logout'){
            Get.find<AuthController>().clearSharedData();
            Get.find<UserProfileController>().clearUserProfileData();
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }

          else if(notificationBody.notificationType == 'advertisement'){
            Get.toNamed(RouteHelper.getAdvertisementDetailsScreen(advertisementId: notificationBody.advertisementId, fromNotification: "fromNotification"));
          }
          else if(isReviewNotification(notificationBody)){
            openReviewNotificationTarget();
          }
          else{
            Get.toNamed(RouteHelper.getNotificationRoute(fromPage: "notification"));

          }
        }catch (e) {
          if (kDebugMode) {
            print("");
          }
        }
      },
    );

    if (GetPlatform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    if (kDebugMode) {
      print('NotificationHelper: FCM onMessage listener registered');
    }

    if (_foregroundMessagingRegistered) {
      return;
    }
    _foregroundMessagingRegistered = true;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      if (kDebugMode) {
        print("onMessage: Notification Type => ${message.data["type"]}/ Title => ${message.data['title']} ${message.notification?.title}/${message.notification?.body}/${message.notification?.titleLocKey}");
        print("Notification Body => ${message.data.toString()}");
      }


      if(message.data['type']=='bidding'){
        if(message.data['post_id']!="" &&  message.data['post_id']!=null){
          Get.find<SplashController>().updateCustomBookingButtonStatus();
          Get.find<SplashController>().updateCustomBookingRedDotButtonStatus(status: true, shouldUpdate: true);
          Get.find<PostController>().getPostDetailsForNotification(message.data['post_id']);
          Get.find<DashboardController>().getDashboardData(reload: true);
        }else{
          NotificationHelper.showNotification(message, false,flutterLocalNotificationsPlugin);
        }
      }

      else if(message.data['type']=='chatting'){
        unawaited(_handleChattingPush(message, flutterLocalNotificationsPlugin));
      }
      
      else if(message.data['type']=='general'){
        NotificationHelper.showNotification(message, false,flutterLocalNotificationsPlugin);
        _refreshInAppNotificationList();
      }
      else if(message.data['type'] == 'logout'){
        NotificationHelper.showNotification(message, false,flutterLocalNotificationsPlugin);
        Get.find<AuthController>().clearSharedData();
        Get.find<UserProfileController>().clearUserProfileData();
        Get.offAllNamed(RouteHelper.getInitialRoute());
        showCustomSnackBar(message.data['title'], duration: 4);
      }
      else if(message.data['type'] == 'maintenance'){
        Get.find<SplashController>().getConfigData();
      }
      else if(message.data['type'] == 'demo_reset') {
        if(Get.find<SplashController>().configModel.content?.appEnvironment == "demo"){
          Get.dialog(const DemoResetDialogWidget(), barrierDismissible: false);
        }
      }
      else if (message.data['type'] == 'booking') {
        NotificationHelper.showNotification(message, false, flutterLocalNotificationsPlugin);
        _refreshInAppNotificationList();
        _refreshBookingDataIfPending(message.data);
      }
      else if(_isInAppCallEvent(message.data['type']?.toString())) {
        if(Get.isRegistered<InAppCallController>()){
          unawaited(Get.find<InAppCallController>().handlePushData(Map<String, dynamic>.from(message.data)));
        }
      }
      else{
        NotificationHelper.showNotification(message, false,flutterLocalNotificationsPlugin);
        _refreshInAppNotificationList();
      }
    });


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) async {
      try{
        if(message!=null && message.data.isNotEmpty) {
          if (message.data['type'] == 'booking' &&
              message.data['booking_id'] != null &&
              message.data['booking_id'].toString().isNotEmpty) {
            _openBookingFromNotificationData(message.data);
            return;
          }

          NotificationBody notificationBody = convertNotification(message.data);
          if(notificationBody.notificationType=="chatting"){
            openChatFromNotification(notificationBody);
          }
          else if(_isInAppCallEvent(notificationBody.notificationType)){
            if(Get.isRegistered<InAppCallController>()){
              await Get.find<InAppCallController>().handlePushData(Map<String, dynamic>.from(message.data));
            }
          }
          else if(notificationBody.notificationType=='bidding' ){
            Get.to(()=>const CustomerRequestListScreen());
          }

          else if(notificationBody.notificationType =='booking' && notificationBody.bookingId!=null && notificationBody.bookingId!=''){
            if(notificationBody.bookingType == "repeat" && notificationBody.repeatBookingType == "single"){
              Get.toNamed(RouteHelper.getBookingDetailsRoute( subBookingId : notificationBody.bookingId, fromPage : "fromNotification"));
            }else if(notificationBody.bookingType == "repeat" && notificationBody.repeatBookingType != "single"){
              Get.toNamed(RouteHelper.getRepeatBookingDetailsRoute( bookingId : notificationBody.bookingId, fromPage : "fromNotification"));
            }else{
              Get.toNamed(RouteHelper.getBookingDetailsRoute( bookingId : notificationBody.bookingId, fromPage : "fromNotification"));
            }
          }
          else if(notificationBody.notificationType == 'privacy_policy' && notificationBody.title!=null && notificationBody.title!=''){
            Get.toNamed(RouteHelper.getHtmlRoute(HtmlType.privacyPolicy.value));
          }
          else if(notificationBody.notificationType == 'terms_and_conditions' && notificationBody.title!=null && notificationBody.title!=''){
            Get.toNamed(RouteHelper.getHtmlRoute(HtmlType.termsAndCondition.value));
          }
          else if(notificationBody.notificationType == 'service_request'){
            Get.to(()=> const SuggestedServiceListScreen());
          }
          else if(notificationBody.notificationType == 'showcase'){
            Get.to(() => const ShowcaseListScreen());
          }
          else if(notificationBody.notificationType == 'suspend'){
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }
          else if(notificationBody.notificationType == 'withdraw'){
            Get.toNamed(RouteHelper.getTransactionListRoute(fromPage: "fromNotification"));
          }
          else if(notificationBody.notificationType == 'admin_pay'){
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }
          else if(notificationBody.notificationType == 'maintenance'){
            Get.toNamed(RouteHelper.getSplashRoute());
          }
          else if(message.data['type'] == 'logout'){
            Get.find<AuthController>().clearSharedData();
            Get.find<UserProfileController>().clearUserProfileData();
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }
          else if(message.data['type'] == 'advertisement'){
            Get.toNamed(RouteHelper.getAdvertisementDetailsScreen(advertisementId: notificationBody.advertisementId, fromNotification: "fromNotification"));
          }
          else if(isReviewNotification(notificationBody)){
            openReviewNotificationTarget();
          }
          else{
            Get.toNamed(RouteHelper.getNotificationRoute(fromPage: "notification"));
          }
        }
      }catch (e) {
        if (kDebugMode) {
          print("");
        }
      }
    });
  }



  static void _refreshInAppNotificationList() {
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().refreshInboxFromPush();
    }
  }

  /// On iOS the chat screen disables APNS banners; show a local banner for other threads.
  static bool _isOnChatScreen() {
    return Get.currentRoute.contains(RouteHelper.chatScreen);
  }

  static Future<void> _presentChatMessageBanner(
    RemoteMessage message,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    if (_isOnChatScreen()) {
      await _showCrossThreadChatHeadsUp(message);
      await _playForegroundNotificationSound(
        message.data['type']?.toString(),
        message.data,
      );
      return;
    }

    try {
      await NotificationHelper.showNotification(
        message,
        false,
        flutterLocalNotificationsPlugin,
      );
    } catch (e, stack) {
      ErrorLogger.record(e, stack, reason: 'NotificationHelper.chatPushBanner');
    }
  }

  static Future<void> _showCrossThreadChatHeadsUp(RemoteMessage message) async {
    final title = message.data['title']?.toString().trim() ?? '';
    final body = message.data['body']?.toString().trim() ?? '';
    if (title.isEmpty) {
      return;
    }

    final notificationBody = convertNotification(message.data);
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      borderRadius: Dimensions.radiusDefault,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      onTap: (_) {
        openChatFromNotification(notificationBody);
      },
    );
  }

  static Future<void> _handleChattingPush(
    RemoteMessage message,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    final channelId = message.data['channel_id']?.toString().trim() ?? '';
    final conversationController = Get.isRegistered<ConversationController>()
        ? Get.find<ConversationController>()
        : null;

    final onActiveChat = channelId.isNotEmpty &&
        Get.currentRoute.contains(RouteHelper.chatScreen) &&
        conversationController != null &&
        conversationController.isViewingChannel(channelId);

    if(onActiveChat) {
      try {
        conversationController.appendIncomingMessageFromPush(message.data);
        await _playForegroundNotificationSound(
          message.data['type']?.toString(),
          message.data,
          inChatThread: true,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Chat push append failed, falling back to banner: $e');
        }
        await NotificationHelper.showNotification(
          message,
          false,
          flutterLocalNotificationsPlugin,
          forceLocalBanner: true,
        );
      }
      unawaited(conversationController.getUnreadChatCount());
      return;
    }

    unawaited(conversationController?.getUnreadChatCount());
    await _presentChatMessageBanner(message, flutterLocalNotificationsPlugin);

    if (channelId.isEmpty || conversationController == null) {
      return;
    }

    if (Get.currentRoute.contains(RouteHelper.chatInbox)) {
      if (message.data['user_type'] == 'customer') {
        conversationController.getChannelList(1, silent: true);
      } else if (AppFeatureFlags.servicemanEnabled) {
        conversationController.getChannelList(1, type: 'serviceman', silent: true);
      }
    } else if (Get.currentRoute.contains(RouteHelper.chatScreen) ||
        !Get.currentRoute.contains(RouteHelper.chatInbox)) {
      conversationController.getChannelList(1, silent: true);
    }
  }

  static String chatSenderDisplayName(NotificationBody body) {
    if (AdminChatBrandingHelper.isSuperAdmin(body.userType)) {
      return AdminChatBrandingHelper.displayName;
    }

    return body.userName ?? '';
  }

  static String chatSenderPhone(NotificationBody body) {
    return AdminChatBrandingHelper.chatPhone(
      userType: body.userType,
      fallback: body.userPhone,
    );
  }

  static void openChatFromNotification(
    NotificationBody notificationBody, {
    bool popExistingChatRoutes = true,
  }) {
    final channelId = notificationBody.channelId?.trim() ?? '';
    if (channelId.isEmpty) {
      Get.toNamed(RouteHelper.getInboxScreenRoute(fromNotification: 'fromNotification'));
      return;
    }

    if (Get.isRegistered<ConversationController>()) {
      final conversationController = Get.find<ConversationController>();
      if (Get.currentRoute.contains(RouteHelper.chatScreen) &&
          conversationController.isViewingChannel(channelId)) {
        return;
      }
    }

    if (popExistingChatRoutes) {
      if (Get.currentRoute.contains(RouteHelper.chatScreen)) {
        Get.back();
        if (Get.currentRoute.contains(RouteHelper.chatInbox)) {
          Get.back();
        }
      } else if (Get.currentRoute.contains(RouteHelper.chatInbox)) {
        Get.back();
      }
    }

    Get.toNamed(RouteHelper.getChatScreenRoute(
      channelId,
      chatSenderDisplayName(notificationBody),
      AdminChatBrandingHelper.chatImageUrl(
        userType: notificationBody.userType,
        fallback: notificationBody.userProfileImage,
      ),
      NotificationHelper.chatSenderPhone(notificationBody),
      notificationBody.userType ?? '',
      fromNotification: 'fromNotification',
    ));
  }

  static void _refreshBookingDataIfPending(Map<String, dynamic> data) {
    final status = data['booking_status']?.toString().toLowerCase() ?? '';
    if (status != 'pending') {
      return;
    }

    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().getDashboardData(reload: true);
    }
    if (Get.isRegistered<BookingRequestController>()) {
      Get.find<BookingRequestController>().getBookingRequestList(
        Get.find<BookingRequestController>().bookingStatus,
        1,
        reload: true,
      );
    }
  }

  static void _openBookingFromNotificationData(Map<String, dynamic> data) {
    final bookingId = data['booking_id']?.toString();
    if (bookingId == null || bookingId.isEmpty) {
      return;
    }

    final bookingType = data['booking_type']?.toString();
    final repeatBookingType = data['repeat_type']?.toString();
    if (bookingType == 'repeat' && repeatBookingType == 'single') {
      Get.toNamed(
        RouteHelper.getBookingDetailsRoute(
          subBookingId: bookingId,
          fromPage: 'fromNotification',
        ),
      );
      return;
    }
    if (bookingType == 'repeat' && repeatBookingType != 'single') {
      Get.toNamed(
        RouteHelper.getRepeatBookingDetailsRoute(
          bookingId: bookingId,
          fromPage: 'fromNotification',
        ),
      );
      return;
    }
    Get.toNamed(
      RouteHelper.getBookingDetailsRoute(
        bookingId: bookingId,
        fromPage: 'fromNotification',
      ),
    );
  }

  static int _notificationIdForMessage(RemoteMessage message) {
    final pushId = message.data['push_notification_id']?.toString();
    if (pushId != null && pushId.isNotEmpty) {
      return pushId.hashCode & 0x7FFFFFFF;
    }

    if (message.data['type']?.toString() == 'chatting') {
      final conversationId = message.data['conversation_id']?.toString();
      if (conversationId != null && conversationId.isNotEmpty) {
        return conversationId.hashCode & 0x7FFFFFFF;
      }

      final channelId = message.data['channel_id']?.toString();
      if (channelId != null && channelId.isNotEmpty) {
        return 'chat:$channelId'.hashCode & 0x7FFFFFFF;
      }
    }

    final bookingId = message.data['booking_id']?.toString();
    if (bookingId != null &&
        bookingId.isNotEmpty &&
        message.data['type']?.toString() == 'booking') {
      return BookingNotificationConstants.notificationIdFor(bookingId);
    }

    return Random().nextInt(100000);
  }

  static Future<void> showNotification(
    RemoteMessage message,
    bool data,
    FlutterLocalNotificationsPlugin fln, {
    bool fromBackgroundHandler = false,
    bool forceLocalBanner = false,
  }) async {
    final title = message.data['title'] ?? message.notification?.title;
    final body = message.data['body'] ?? message.notification?.body ?? '';
    final playLoad = jsonEncode(message.data);
    if (title == null || title.isEmpty) return;

    // iOS foreground: APNS banner is shown via setForegroundNotificationPresentationOptions.
    // A local notification here would duplicate it. Android uses data-only FCM + local banner.
    if (GetPlatform.isIOS && !fromBackgroundHandler && !forceLocalBanner) {
      return;
    }

    final notificationType = message.data['type']?.toString();
    final notificationId = _notificationIdForMessage(message);

    final soundEnabled = _notificationSoundEnabled();

    if (GetPlatform.isIOS) {
      final darwinDetails = NotificationSoundUtil.darwinDetailsForType(
        notificationType,
        withSound: soundEnabled,
      );
      final platformChannelSpecifics = NotificationDetails(iOS: darwinDetails);
      try {
        await fln.show(
          id: notificationId,
          title: title,
          body: body,
          notificationDetails: platformChannelSpecifics,
          payload: playLoad,
        );
        if (kDebugMode) {
          print('NotificationHelper: iOS local banner shown for $notificationType');
        }
      } catch (e, stack) {
        ErrorLogger.record(e, stack, reason: 'NotificationHelper.showNotification.iOS');
      }
      return;
    }

    String? image;
    image = (message.data['image'] != null && message.data['image'].isNotEmpty)
        ? message.data['image'].startsWith('http') ? message.data['image']
        : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}' : null;

    if(image != null && image.isNotEmpty) {
      try{
        await showBigPictureNotificationHiddenLargeIcon(title, body, playLoad, image, fln, notificationType, message.data, notificationId: notificationId);
      }catch(e) {
        await showBigTextNotification(title :title, body: body, payload: playLoad, fln : fln, notificationType: notificationType, messageData: message.data, notificationId: notificationId);
      }
    }else {
      await showBigTextNotification(title :title, body: body, payload: playLoad, fln : fln, notificationType: notificationType, messageData: message.data, notificationId: notificationId);
    }

    if (!fromBackgroundHandler) {
      await _playAndroidForegroundSound(notificationType, message.data);
    }
  }

  static NotificationBody convertNotification(Map<String, dynamic> data){
    return NotificationBody.fromJson(data);

  }

  static void openReviewNotificationTarget() {
    Get.to(() => const ProviderReviewScreen());
  }

  static bool isReviewNotification(NotificationBody? body) {
    return body?.notificationType?.trim().toLowerCase() == 'review';
  }

  static Future<void> showBackgroundNotification(
    RemoteMessage message,
    FlutterLocalNotificationsPlugin fln,
  ) async {
    await createAndroidNotificationChannels(fln);
    await showNotification(message, false, fln, fromBackgroundHandler: true);
  }

  static Future<void> showBigTextNotification({required String title, required String body, required String payload, required FlutterLocalNotificationsPlugin fln, String? notificationType, Map<String, dynamic>? messageData, int? notificationId}) async {
    final resolvedType = notificationType ?? NotificationSoundUtil.typeFromPayload(payload);
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body, htmlFormatBigText: true,
      contentTitle: title, htmlFormatContentTitle: true,
    );

    final androidPlatformChannelSpecifics = messageData != null
        ? NotificationSoundUtil.androidDetailsFromData(
            messageData,
            withSound: _notificationSoundEnabled(),
            styleInformation: bigTextStyleInformation,
          )
        : NotificationSoundUtil.androidDetailsForType(
            resolvedType,
            withSound: _notificationSoundEnabled(),
            styleInformation: bigTextStyleInformation,
          );
    final resolvedId = notificationId ?? Random().nextInt(100000);
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(id: resolvedId, title: title, body: body, notificationDetails: platformChannelSpecifics, payload: payload);
  }
  static Future<void> showBigPictureNotificationHiddenLargeIcon(String title, String body, String payload, String image, FlutterLocalNotificationsPlugin fln, String? notificationType, Map<String, dynamic> messageData, {int? notificationId}) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true,
      contentTitle: title, htmlFormatContentTitle: true,
      summaryText: body, htmlFormatSummaryText: true,
    );
    final androidPlatformChannelSpecifics = NotificationSoundUtil.androidDetailsFromData(
      messageData,
      withSound: _notificationSoundEnabled(),
      styleInformation: bigPictureStyleInformation,
      largeIcon: FilePathAndroidBitmap(largeIconPath),
    );
    final resolvedId = notificationId ?? Random().nextInt(100000);
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(id: resolvedId, title: title, body: body, notificationDetails: platformChannelSpecifics, payload: payload);
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static bool _notificationSoundEnabled() {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>().isNotificationActive();
    }
    return true;
  }

  static Future<void> _playForegroundNotificationSound(
    String? type,
    Map<String, dynamic> data, {
    bool inChatThread = false,
  }) async {
    if (!_notificationSoundEnabled()) return;

    try {
      final player = AudioPlayer();
      if (inChatThread) {
        await player.setVolume(0.85);
        await player.play(AssetSource(NotificationSoundUtil.assetSoundForInChatMessage()));
        return;
      }

      final resolvedType = type ?? data['type']?.toString();
      await player.play(
        AssetSource(NotificationSoundUtil.assetSoundForType(resolvedType)),
      );
    } catch (_) {}
  }

  static Future<void> _playAndroidForegroundSound(
    String? type,
    Map<String, dynamic> data,
  ) async {
    if (!GetPlatform.isAndroid) return;
    await _playForegroundNotificationSound(type, data);
  }

  static bool _isInAppCallEvent(String? type) {
    return const {
      'incoming_call',
      'call_accepted',
      'call_declined',
      'call_ended',
      'call_cancelled',
      'call_missed',
    }.contains(type);
  }
}

@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    print("onBackground: ${message.notification?.title}/${message.notification?.body}/${message.notification?.titleLocKey}");
  }

  // iOS already displays the APNS alert from the backend payload; showing a
  // local notification here would duplicate the banner.
  if (GetPlatform.isIOS) {
    return;
  }

  final fln = FlutterLocalNotificationsPlugin();
  const androidInitialize = AndroidInitializationSettings('notification_icon');
  const iOSInitialize = DarwinInitializationSettings();
  await fln.initialize(
    settings: InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize,
    ),
  );
  await NotificationHelper.createAndroidNotificationChannels(fln);
  await NotificationHelper.showBackgroundNotification(message, fln);
}