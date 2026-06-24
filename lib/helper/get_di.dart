import 'dart:convert';
import 'package:demandium_provider/feature/payement_information/controller/payment_info_controller.dart';
import 'package:demandium_provider/feature/payement_information/repository/payment_info_repo.dart';
import 'package:demandium_provider/feature/payments/controller/payments_controller.dart';
import 'package:demandium_provider/feature/payments/repo/payments_repo.dart';
import 'package:demandium_provider/feature/settings/business/controller/company_identity_controller.dart';
import 'package:demandium_provider/feature/settings/business/controller/identity_controller.dart';
import 'package:demandium_provider/feature/tutorial/controller/tutorial_controller.dart';
import 'package:demandium_provider/feature/tutorial/repo/tutorial_repo.dart';
import 'package:demandium_provider/feature/booking_requests/controller/calendar_controller.dart';
import 'package:demandium_provider/feature/booking_requests/controller/calender_order_filter_controller.dart';
import 'package:demandium_provider/common/repo/provider_cache_repo.dart';
import 'package:demandium_provider/feature/dashboard/repo/dashboard_bundle_repo.dart';
import 'package:demandium_provider/helper/booking_alert_watcher.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';


Future<Map<String, Map<String, String>>> init() async{

  /// Core
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);
  await SecureTokenStorage.preload(sharedPreferences);
  Get.lazyPut(() => ApiClient(appBaseUrl: AppConstants.baseUrl, sharedPreferences: Get.find()));


  /// Repository
  Get.lazyPut(() => PostRepo(apiClient: Get.find()));
  Get.lazyPut(() => ConversationRepo(apiClient: Get.find()));
  Get.lazyPut(() => SuggestServiceRepo(apiClient: Get.find()));
  Get.lazyPut(() => ReviewRepo(apiClient: Get.find()));
  Get.lazyPut(() => CustomerReviewRepo(apiClient: Get.find()));
  Get.lazyPut(() => ProviderCacheRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => DashboardBundleRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => SplashRepo(sharedPreferences: Get.find(), apiClient: Get.find(), cacheRepo: Get.find()));
  Get.lazyPut(() => NotificationRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => AuthRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => LocationRepo(apiClient: Get.find(),sharedPreferences: Get.find()));
  Get.lazyPut(() => DashBoardRepo(apiClient: Get.find(),sharedPreferences: Get.find()));
  Get.lazyPut(() => ServicemanRepo(apiClient: Get.find()));
  Get.lazyPut(() => BookingDetailsRepo(apiClient: Get.find()));
  Get.lazyPut(() => ReportRepo(apiClient: Get.find()));
  Get.lazyPut(() => UserRepo(Get.find(), apiClient: Get.find()));
  Get.lazyPut(() => BookingRequestRepo(apiClient: Get.find()));
  Get.lazyPut(() => AdvertisementRepo(apiClient: Get.find()));
  Get.lazyPut(() => ShowcaseRepo(apiClient: Get.find()));
  Get.lazyPut(() => SubscriptionRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => BusinessSettingRepo(apiClient: Get.find()));
  Get.lazyPut(() => NotificationSetupRepo(apiClient: Get.find()));
  Get.lazyPut(() => TransactionRepo(apiClient: Get.find()));
  Get.lazyPut(() => HtmlRepository(apiClient: Get.find()));
  Get.lazyPut(() => BankInfoRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => ServiceDetailsRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => TutorialRepo(apiClient: Get.find()));
  Get.lazyPut(() => PaymentInfoRepo(apiClient: Get.find()));
  Get.lazyPut(() => PaymentsRepo(apiClient: Get.find()));


  /// Controller
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(() => ReviewController(reviewRepo: Get.find()));
  Get.lazyPut(
    () => CustomerReviewController(customerReviewRepo: Get.find<CustomerReviewRepo>()),
    fenix: true,
  );
  Get.lazyPut(() => SplashController(splashRepo: Get.find()));
  Get.lazyPut(() => AuthController(authRepo: Get.find()));
  Get.lazyPut(() => PostController(postRepo: Get.find()));
  Get.lazyPut(() => LocationController(locationRepo: Get.find()));
  Get.lazyPut(() => UserProfileController( userRepo: Get.find()));
  Get.lazyPut(() => DashboardController(dashBoardRepo: Get.find()));
  Get.lazyPut(() => BookingReportController(reportRepo: Get.find()));
  Get.lazyPut(() => BusinessReportController(reportRepo: Get.find()));
  Get.lazyPut(() => ServiceCategoryController(serviceRepo:ServiceRepo(apiClient: Get.find())));
  Get.lazyPut(() => TransactionController(transactionRepo: Get.find()));
  Get.lazyPut(() => BookingDetailsController(bookingDetailsRepo: BookingDetailsRepo(apiClient: Get.find())));
  Get.lazyPut(() => BookingRequestController(bookingRequestRepo: Get.find()));
  Get.lazyPut(() => AdvertisementController(advertisementRepo: Get.find()));
  Get.lazyPut(() => ShowcaseController(showcaseRepo: Get.find()));
  Get.lazyPut(() => ServicemanDetailsController(servicemanRepo: Get.find()));
  Get.lazyPut(() => ConversationController(conversationRepo: Get.find()));
  Get.lazyPut(() => SuggestServiceController(suggestServiceRepo: Get.find()));
  Get.lazyPut(() => NotificationController(notificationRepo: Get.find()));
  Get.lazyPut(() => BusinessSubscriptionController(subscriptionRepo: SubscriptionRepo(apiClient: Get.find(), sharedPreferences: Get.find())));
  Get.lazyPut(() => BusinessSettingController(businessSettingRepo: Get.find()));
  Get.lazyPut(() => NotificationSetupController(notificationSetupRepo: Get.find()));
  Get.lazyPut(() => LocalizationController(apiClient: Get.find(),sharedPreferences: Get.find()));
  Get.lazyPut(() => BookingEditController(serviceRepo: ServiceRepo(apiClient: Get.find()), bookingDetailsRepo: BookingDetailsRepo(apiClient: Get.find())));
  Get.lazyPut(() => SubcategorySubscriptionController(subscriptionRepo:SubscriptionRepo(apiClient: Get.find(), sharedPreferences: Get.find())));
  Get.lazyPut(() => HtmlViewController(htmlRepository: Get.find()));
  Get.lazyPut(() => BankInfoController(bankInfoRepo: Get.find()));
  Get.lazyPut(() => ServicemanSetupController(servicemanRepo: Get.find()));
  Get.lazyPut(() => ServiceDetailsController(serviceDetailsRepo: Get.find()));
  Get.lazyPut(() => TutorialController(tutorialRepo: Get.find()));
  Get.lazyPut(() => IdentityController());
  Get.lazyPut(() => CompanyIdentityController());
  Get.lazyPut(() => PaymentInfoController(paymentInfoRepo: Get.find()));
  Get.lazyPut(() => PaymentsController(paymentsRepo: Get.find()));
  Get.lazyPut(() => BookingCalendarController(bookingRequestRepo: Get.find()));
  Get.lazyPut(() => CalenderOrderFilterController());

  Get.put(BookingAlertWatcher(), permanent: true);



  Map<String, Map<String, String>> languages = {};
  for(LanguageModel languageModel in AppConstants.languages) {
    String jsonStringValues =  await rootBundle.loadString('assets/language/${languageModel.languageCode}.json');
    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
    Map<String, String> jsonValue = {};
    mappedJson.forEach((key, value) {
      jsonValue[key] = value.toString();
    });
    languages['${languageModel.languageCode}_${languageModel.countryCode}'] = jsonValue;
  }
  return languages;
}
