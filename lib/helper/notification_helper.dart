import 'dart:convert';
import 'dart:math';
import 'package:demandium_provider/common/widgets/demo_reset_dialog_widget.dart';
import 'package:demandium_provider/firebase_options.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class NotificationHelper {

  static Future<void> createAndroidNotificationChannels(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    if (!GetPlatform.isAndroid) return;

    const withSound = AndroidNotificationChannel(
      'demandium',
      'demandium with sound',
      description: 'Notifications with sound',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    const withoutSound = AndroidNotificationChannel(
      'demandiumWithoutsound',
      'demandium without sound',
      description: 'Notifications without sound',
      importance: Importance.max,
      playSound: false,
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(withSound);
    await androidPlugin?.createNotificationChannel(withoutSound);
  }

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    await createAndroidNotificationChannels(flutterLocalNotificationsPlugin);
    var androidInitialize = const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(settings: initializationsSettings, onDidReceiveNotificationResponse: (NotificationResponse? notificationResponse) async {
      try{
        if(notificationResponse!.payload!=null && notificationResponse.payload!=''){
          NotificationBody notificationBody = NotificationBody.fromJson(jsonDecode(notificationResponse.payload!));
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
          else{
            Get.toNamed(RouteHelper.getNotificationRoute(fromPage: "notification"));

          }
        }
      }catch (e) {
        if (kDebugMode) {
          print("");
        }
          }
          return;
        });

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
        Get.find<NotificationController>().getNotifications(1, saveNotificationCount: false);
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
      else{
        NotificationHelper.showNotification(message, false,flutterLocalNotificationsPlugin);
      }
    });


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      try{
        if(message!=null && message.data.isNotEmpty) {
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



  static Future<void> showNotification(RemoteMessage message,bool data,FlutterLocalNotificationsPlugin fln) async {
    final title = message.data['title'] ?? message.notification?.title;
    final body = message.data['body'] ?? message.notification?.body ?? '';
    final playLoad = jsonEncode(message.data);
    if (title == null || title.isEmpty) return;

    if (GetPlatform.isIOS) {
      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const platformChannelSpecifics = NotificationDetails(iOS: darwinDetails);
      await fln.show(
        id: Random().nextInt(100000),
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
        await showBigPictureNotificationHiddenLargeIcon(title, body, playLoad, image, fln);
      }catch(e) {
        await showBigTextNotification(title :title, body: body, payload: playLoad, fln : fln);
      }
    }else {
      await showBigTextNotification(title :title, body: body, payload: playLoad, fln : fln);
    }
  }

  static Future<void> showBackgroundNotification(
    RemoteMessage message,
    FlutterLocalNotificationsPlugin fln,
  ) async {
    await createAndroidNotificationChannels(fln);
    await showNotification(message, false, fln);
  }

  static Future<void> showBigTextNotification({required String title, required String body, required String payload, required FlutterLocalNotificationsPlugin fln}) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body, htmlFormatBigText: true,
      contentTitle: title, htmlFormatContentTitle: true,
    );

    if(!_notificationSoundEnabled()){
      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "demandiumWithoutsound","${AppConstants.appName} without sound", channelDescription:"description",
        playSound: false,
        importance: Importance.max,
        styleInformation: bigTextStyleInformation, priority: Priority.max,

      );
      int randomNumber = Random().nextInt(100);
      NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      await fln.show(id: randomNumber, title: title, body: body, notificationDetails: platformChannelSpecifics, payload: payload);
    }
    else {
      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "demandium", '${AppConstants.appName} with sound', channelDescription:"description",
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('notification'),
        importance: Importance.max,
        styleInformation: bigTextStyleInformation, priority: Priority.max,
      );
      int randomNumber = Random().nextInt(100);
      NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      await fln.show(id: randomNumber, title: title, body: body, notificationDetails: platformChannelSpecifics, payload: payload);
    }

  }
  static Future<void> showBigPictureNotificationHiddenLargeIcon(String title, String body, String payload, String image, FlutterLocalNotificationsPlugin fln) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true,
      contentTitle: title, htmlFormatContentTitle: true,
      summaryText: body, htmlFormatSummaryText: true,
    );

    if(!_notificationSoundEnabled()){
      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "demandiumWithoutsound","${AppConstants.appName} without sound", channelDescription:"description",
        playSound: false,
          largeIcon: FilePathAndroidBitmap(largeIconPath), priority: Priority.max,
          styleInformation: bigPictureStyleInformation, importance: Importance.max,
      );
      int randomNumber = Random().nextInt(100);
      NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      await fln.show(id: randomNumber, title: title, body: body, notificationDetails: platformChannelSpecifics, payload: payload);

    }else{
      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "demandium", '${AppConstants.appName} with sound', channelDescription:"description",
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('notification'),
        largeIcon: FilePathAndroidBitmap(largeIconPath), priority: Priority.max,
        styleInformation: bigPictureStyleInformation, importance: Importance.max,
      );
      int randomNumber = Random().nextInt(100);
      NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      await fln.show(id: randomNumber, title: title, body: body, notificationDetails: platformChannelSpecifics, payload: payload);
    }
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

  static NotificationBody convertNotification(Map<String, dynamic> data){
    return NotificationBody.fromJson(data);

  }
}

@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    print("onBackground: ${message.notification?.title}/${message.notification?.body}/${message.notification?.titleLocKey}");
  }

  if (message.notification != null) {
    return;
  }

  final fln = FlutterLocalNotificationsPlugin();
  const androidInitialize = AndroidInitializationSettings('notification_icon');
  const iOSInitialize = DarwinInitializationSettings();
  await fln.initialize(
    settings: const InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize,
    ),
  );
  await NotificationHelper.showBackgroundNotification(message, fln);
}