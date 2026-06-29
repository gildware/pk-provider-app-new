
import 'package:demandium_provider/helper/app_startup.dart';
import 'package:demandium_provider/helper/auth_session_helper.dart';
import 'package:demandium_provider/helper/get_di.dart' as di;
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';
import 'feature/nav/widgets/cash_overflow_overlay.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

AndroidNotificationChannel? channel1;
AndroidNotificationChannel? channel2;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (GetPlatform.isMobile) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  if (GetPlatform.isMobile && AppConstants.sslPinSha256.isNotEmpty) {
    HttpOverrides.global = CertificatePinningHttpOverrides(
      expectedPinSha256: AppConstants.sslPinSha256,
    );
  }

  final languages = await AppStartup.prepareForRunApp();

  if (GetPlatform.isMobile) {
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    await NotificationHelper.createAndroidNotificationChannels(
      flutterLocalNotificationsPlugin,
    );
  }

  runApp(MyApp(languages: languages));
  AppStartup.scheduleDeferredInit(flutterLocalNotificationsPlugin);
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>>? languages;
  const MyApp({super.key, required this.languages});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void reassemble() {
    super.reassemble();
    di.ensureBookingRequestDependencies();
    AuthSessionHelper.syncFromStorage().then((_) {
      AuthSessionHelper.redirectToSignInIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetMaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          navigatorKey: Get.key,
          theme: themeController.darkTheme ? dark : light,
          locale: localizeController.locale,
          translations: Messages(languages: widget.languages),
          initialRoute: RouteHelper.getSplashRoute(body: null),
          getPages: RouteHelper.routes,
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 500),
          builder: (context, widget) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(MediaQuery.sizeOf(context).width < 380 ? 0.9 : 1),
            ),
            child: Material(
              child: SafeArea(
                top: false,
                bottom: GetPlatform.isAndroid,
                child: Stack(
                  children: [
                    widget!,
                    const CashOverflowOverlay(),
                  ],
                ),
              ),
            ),
          ),
        );
      });
    });
  }
}
