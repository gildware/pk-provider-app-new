import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:demandium_provider/common/widgets/demo_reset_dialog_widget.dart';
import 'package:demandium_provider/firebase_options.dart';
import 'package:demandium_provider/helper/booking_notification_constants.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:demandium_provider/helper/notification_sound_util.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class NotificationHelper {

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
    const iOSInitialize = DarwinInitializationSettings();
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(
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

            if(Get.currentRoute.contains(RouteHelper.chatScreen)){
              Get.back();
              Get.back();

            } else if(Get.currentRoute.contains(RouteHelper.chatInbox)){
              Get.back();

            }

            Get.toNamed(RouteHelper.getChatScreenRoute(
              notificationBody.channelId??"",
              notificationBody.userType == "supper-admin" ? "admin" : notificationBody.userName??"",
              notificationBody.userProfileImage??"",
              notificationBody.userPhone??"",
              notificationBody.userType??"",
              fromNotification: "fromNotification",
            ));

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

        if((message.data['channel_id']!="" && message.data['channel_id']!=null)){

          if(Get.currentRoute.contains(RouteHelper.chatScreen) && (message.data['channel_id'] == Get.find<ConversationController>().channelId) ){
            Get.find<ConversationController>().getConversation(message.data['channel_id'], 1);
          }else if(Get.currentRoute.contains(RouteHelper.chatInbox)
              || Get.currentRoute.contains(RouteHelper.chatScreen)){

            NotificationHelper.showNotification(message, false,flutterLocalNotificationsPlugin);
            if(message.data['user_type'] == 'customer'){
              Get.find<ConversationController>().getChannelList(1);
            }else if (AppFeatureFlags.servicemanEnabled) {
              Get.find<ConversationController>().getChannelList(1, type: "serviceman");
            }
          }else{
            NotificationHelper.showNotification(message, false,flutterLocalNotificationsPlugin);
          }

        } else{
          NotificationHelper.showNotification(message, false,flutterLocalNotificationsPlugin);
        }
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

            if(Get.currentRoute.contains(RouteHelper.chatScreen)){
              Get.back();
              Get.back();
            } else if(Get.currentRoute.contains(RouteHelper.chatInbox)){
              Get.back();
            }
            Get.toNamed(RouteHelper.getChatScreenRoute(
              notificationBody.channelId??"",
              notificationBody.userType == "supper-admin" ? "admin" : notificationBody.userName??"",
              notificationBody.userProfileImage??"",
              notificationBody.userPhone??"",
              notificationBody.userType??"",
              fromNotification: "fromNotification"
            ));
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
  }) async {
    final title = message.data['title'] ?? message.notification?.title;
    final body = message.data['body'] ?? message.notification?.body ?? '';
    final playLoad = jsonEncode(message.data);
    if (title == null || title.isEmpty) return;

    final notificationType = message.data['type']?.toString();
    final notificationId = _notificationIdForMessage(message);

    final soundEnabled = _notificationSoundEnabled();

    if (GetPlatform.isIOS) {
      final darwinDetails = NotificationSoundUtil.darwinDetailsForType(
        notificationType,
        withSound: soundEnabled,
      );
      final platformChannelSpecifics = NotificationDetails(iOS: darwinDetails);
      await fln.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: platformChannelSpecifics,
        payload: playLoad,
      );
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

  static Future<void> _playAndroidForegroundSound(
    String? type,
    Map<String, dynamic> data,
  ) async {
    if (!GetPlatform.isAndroid || !_notificationSoundEnabled()) return;

    try {
      final resolvedType = type ?? data['type']?.toString();
      final player = AudioPlayer();
      await player.play(
        AssetSource(NotificationSoundUtil.assetSoundForType(resolvedType)),
      );
    } catch (_) {}
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