import 'dart:convert';
import 'package:demandium_provider/common/widgets/maintenance_screen.dart';
import 'package:demandium_provider/feature/advertisement/view/advertisement_list_screen.dart';
import 'package:demandium_provider/feature/booking_details/view/repeat_booking_details_screen.dart';
import 'package:demandium_provider/feature/payement_information/view/add_payment_info_screen.dart';
import 'package:demandium_provider/feature/payement_information/view/payment_information_screen.dart';
import 'package:demandium_provider/feature/settings/notification/view/notification_settings_screen.dart';
import 'package:demandium_provider/feature/subscriptions/view/business/business_plan_screen.dart';
import 'package:demandium_provider/feature/support/support_screen.dart';
import 'package:demandium_provider/feature/booking_requests/view/calendar_order_screen.dart';
import 'package:demandium_provider/feature/payments/view/payments_screen.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';


class RouteHelper {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String language = '/language';
  static const String languageScreen = '/language-screen';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String update = '/update';
  static const String profile = '/profile';
  static const String bankInfo = '/bank-info';
  static const String mySubscription = '/my-subscription';
  static const String html = '/html';
  static const String serviceDetails = '/service-details';
  static const String bookingDetails = '/booking-details';
  static const String repeatBookingDetails = '/repeat-booking-details';
  static const String serviceManSetup = '/serviceManSetup';
  static const String addNewServicemanScreen = '/addNewServicemanScreen';
  static const String chatScreen = '/chat-screen';
  static const String chatInbox = '/chat-inbox';
  static const String serviceScreen = '/service-screen';
  static const String sendOtpScreen = '/send-otp';
  static const String verification = '/otp-verification';
  static const String changePassword = '/change-password';
  static const String notification = '/notification';
  static const String profileInformation = '/profile-information';
  static const String transactions = '/transactions';
  static const String reporting = '/reporting';
  static const String suggestService = '/suggest-service';
  static const String advertisementList = '/advertisement-list';
  static const String advertisementDetails = '/advertisement-details';
  static const String businessPlan = '/business-plan';
  static const String maintenanceRoute = '/maintenance-screen';
  static const String notificationSetup = '/notification-screen';
  static const String reviewReply = '/review-reply';
  static const String rateCustomer = '/rate-customer';
  static const String helpAndSupport = '/help-and-support';
  static const String paymentInformation = '/payment-information';
  static const String addPaymentInfo = '/add-payment-information';
  static const String calendarOrder = '/calendar-order';
  static const String payments = '/payments';
  static const String allServices = '/all-services';



  static String getInitialRoute({int pageIndex = 0}) => '$initial?pageIndex=$pageIndex';
  static String getSplashRoute({NotificationBody? body}) {
    String data = 'null';
    if(body != null) {
      List<int> encoded = utf8.encode(jsonEncode(body));
      data = base64Encode(encoded);
    }
    return '$splash?data=$data';
  }
  static String getLanguageBottomSheet(String page) => '$language?page=$page';
  static String getLanguageScreenRoute() => languageScreen;
  static String getReportingPageRoute(String page) => '$reporting?page=$page';
  static String getSignInRoute(String page) => '$signIn?page=$page';
  static String getUpdateRoute(bool isUpdate) => '$update?update=${isUpdate.toString()}';

  static String getSendOtpScreen() => sendOtpScreen;
  static String getVerificationRoute({required String identity,required String identityType, required  String fromPage, String? firebaseSession, bool? showSignUpDialog}) {

    String showDialog = showSignUpDialog !=null && showSignUpDialog ? "showDialog":"";
    String data = Uri.encodeComponent(jsonEncode(identity));
    String session = base64Url.encode(utf8.encode(firebaseSession ?? ''));

    return '$verification?identity=$data&identity_type=$identityType&fromPage=$fromPage&session=$session&showSignUpDialog=$showDialog';
  }
  static String getChangePasswordRoute(String identity,String identityType ,String otp, int isFirebaseOtp) {
    String identity0 = Uri.encodeComponent(jsonEncode(identity));
    String otp0 = Uri.encodeComponent(jsonEncode(otp));
   return '$changePassword?identity=$identity0&identity_type=$identityType&otp=$otp0&is_firebase_otp=$isFirebaseOtp';
  }
  static String getProfileRoute() => profile;
  static String getBankInfoRoute() => bankInfo;
  static String getMySubscriptionRoute() => mySubscription;
  static String getHtmlRoute(String page, {String? title}) => '$html?page=$page${title != null ? '&title=$title' : ''}';

  static String getServiceDetailsRoute(String serviceId,Discount discount) => '$serviceDetails?service_id=$serviceId';
  static String getBookingDetailsRoute({String? bookingId,  String? fromPage, String? subBookingId}) =>
      '$bookingDetails?booking_id=$bookingId&sub_booking_id=$subBookingId&fromPage=$fromPage';
  static String getRepeatBookingDetailsRoute({String? bookingId,  String? fromPage, String? subBookingId}) =>
      '$repeatBookingDetails?booking_id=$bookingId&sub_booking_id=$subBookingId&fromPage=$fromPage';
  static String getChatScreenRoute(String channelId,String name,String image,String phone,String userType, {String? fromNotification}) {
    final query = Uri(queryParameters: {
      'channelID': channelId,
      'name': name,
      'image': image,
      'phone': phone,
      'userType': userType,
      'fromNotification': fromNotification ?? '',
    });
    return '$chatScreen?${query.query}';
  }

  static String getInboxScreenRoute({String? fromNotification}) => '$chatInbox?fromNotification=$fromNotification';
  static String getNotificationRoute({String? fromPage}) {
    if (fromPage == null || fromPage.isEmpty) {
      return notification;
    }
    return '$notification?page=$fromPage';
  }
  static String getTransactionListRoute({String? fromPage}) => '$transactions?page=$fromPage';
  static String getAdvertisementListScreen({required int count}) => '$advertisementList?count=$count';
  static String getAdvertisementDetailsScreen({String? advertisementId, String? fromNotification}) => '$advertisementDetails?advertisementId=$advertisementId&fromNotification=$fromNotification';
  static String getBusinessPlanScreen() => businessPlan;
  static String getMaintenanceRoute() => maintenanceRoute;
  static String getNotificationScreen() => notificationSetup;

  static String getReviewReplyScreen({Review? review, String? fromPage}) {
    String data = 'null';
    if(review!= null) {
      List<int> encoded = utf8.encode(jsonEncode(review));
      data = base64Encode(encoded);
    }
    return '$reviewReply?data=$data&from-page=$fromPage';
  }

  static String getRateCustomerRoute({required String bookingId, required String customerName}) {
    return '$rateCustomer?booking_id=$bookingId&customer_name=${Uri.encodeComponent(customerName)}';
  }

  static String getHelpAndSupportScreen() => helpAndSupport;
  static String getPaymentInformationRoute() => paymentInformation;
  static String getAddPaymentInformationRoute({int? index, String? methodName, String? methodId, bool? isActive, bool? isDefault}) => "$addPaymentInfo?index=$index&method_name=$methodName&method_id=$methodId&is_active=${isActive ?? false}&is_default=${isDefault ?? false}";
  static String getCalendarOrderRoute() => calendarOrder;
  static String getPaymentsRoute() => payments;
  static String getAllServicesRoute({bool formTutorial = false}) => '$allServices?formTutorial=$formTutorial';


  static List<GetPage> routes = [
    GetPage(
      name: initial,
      page: () {
        int pageIndex = int.tryParse(Get.parameters['pageIndex'] ?? "0") ?? 0;
        return BottomNavScreen(pageIndex: pageIndex);
      },
      middlewares: [AuthMiddleware()],
    ),
    GetPage(name: splash, page: () {
      NotificationBody? data;
      if(Get.parameters['data'] != 'null') {
        List<int> decode = base64Decode(Get.parameters['data']!.replaceAll(' ', '+'));
        data = NotificationBody.fromJson(jsonDecode(utf8.decode(decode)));
      }
      return SplashScreen(body: data);
    }),
    GetPage(name: profile, page: () => const ProfileScreen()),
    // SERVICEMAN_DISABLED — restore when AppFeatureFlags.servicemanEnabled
    // GetPage(name: serviceManSetup, page: () => const ServicemanSetupScreen()),
    // GetPage(name: addNewServicemanScreen, page: () => const AddNewServicemanScreen(),),
    GetPage(binding: BankInfoBinding(),name: profile, page: () => const ProfileScreen()),
    GetPage(name: bookingDetails,
        page: () => getRoute(BookingDetailsScreen(
          bookingId: Get.parameters['booking_id'],
          subBookingId: Get.parameters['sub_booking_id'],
          fromPage: Get.parameters['fromPage'],
        ))
    ),
    GetPage(name: repeatBookingDetails,
        page: () => getRoute(RepeatBookingDetailsScreen(
          bookingId: Get.parameters['booking_id'].toString(),
          fromPage: Get.parameters['fromPage'],
        ))
    ),
    GetPage(name: notification, page: () => NotificationScreen(
        fromNotificationPage: Get.parameters['fromPage'],
    )),
    GetPage( name: mySubscription, page: () => const SubscriptionScreen()),
    GetPage(name: allServices, page: () {
      final formTutorial = Get.parameters['formTutorial'] == 'true';
      return ShowCaseWidget(
        builder: (context) => AllServicesScreen(isTutorialActive: formTutorial),
      );
    }),
    GetPage(
      transition: Transition.fadeIn,
      name: signIn,
      page: () => const SignInScreen(exitFromApp: false,),
      middlewares: [RedirectToHomeMiddleware()],
    ),
    GetPage(binding: SignupBinding(), name: signUp, page: () => const SignUpScreen()),

    GetPage(
      name: html,
      page: () => HtmlViewerScreen(
        type: HtmlType.fromValue(Get.parameters['page'] ?? ''),
        pageKey: HtmlType.fromValue(Get.parameters['page'] ?? '') == HtmlType.others ? Get.parameters['page'] : null,
      ),
    ),

    GetPage( name: chatScreen, page: () => getRoute(ConversationDetailsScreen(
      channelID: Get.parameters['channelID']!,
      name: Get.parameters['name']!,
      phone: Get.parameters['phone']!,
      image: Get.parameters['image']!,
      userType: Get.parameters['userType']!,
      formNotification: Get.parameters['fromNotification'] ?? "",
    ))),

    GetPage(name: chatInbox, page: () =>  ConversationListScreen(
      fromNotification: Get.parameters['fromNotification'],
    )),
    GetPage(name: language, page: () => const ChooseLanguageBottomSheet()),
    GetPage(transition: Transition.fadeIn , name: languageScreen, page: () => const ChooseLanguageScreen()),
    GetPage(name: reporting, page: () => const ReportNavigationView()),
    GetPage(name: bankInfo,binding: BankInfoBinding(), page: () => const BankInformation()),
    GetPage(name: sendOtpScreen, page:() =>  const ForgetPassScreen()),
    GetPage(name: verification, page:() {
      String data = Uri.decodeComponent(jsonDecode(Get.parameters['identity']!));
      return VerificationScreen(
        identity: data,
        identityType: Get.parameters['identity_type']!,
        fromPage: Get.parameters['fromPage']!,
        firebaseSession: Get.parameters['session'] == 'null' ? null
            : utf8.decode(base64Url.decode(Get.parameters['session'] ?? '')),
        showSignUpDialog: Get.parameters["showSignUpDialog"] == "showDialog",
        );
    }),

    GetPage(name: changePassword, page:() {
      String identity0 = Uri.decodeComponent(jsonDecode(Get.parameters['identity']!));
      String otp0 = Uri.decodeComponent(jsonDecode(Get.parameters['otp']!));

      return NewPassScreen(
        identity: identity0, identityType:  Get.parameters['identity_type']!, otp: otp0,
        isFirebaseOtp: Get.parameters['is_firebase_otp'] == "1" ? 1 : 0,
      );
    }),

    GetPage(name: profileInformation, page:() => getRoute(const ProfileInformationScreen(),)),
    GetPage(name:transactions, page:() => getRoute( TransactionScreen(
      fromNotification: Get.parameters['page'],
    ),)),
    GetPage(name:suggestService, page:() => getRoute(const SuggestServiceScreen(),)),
    GetPage(name: update, page: () => UpdateScreen(isUpdate: Get.parameters['update'] == 'true')),
    GetPage(name: advertisementList, page: () =>  AdvertisementListScreen(
      isDataAvailable: Get.parameters['count'] != "0",
    )),
    GetPage(name: advertisementDetails, page: () =>
    AdvertisementDetailsScreen(
      id: Get.parameters['advertisementId'],
      fromNotification: Get.parameters['fromNotification'],
    )),
    GetPage(name: businessPlan, page: () => const BusinessPlanScreen()),
    GetPage(name: maintenanceRoute, page: () => const MaintenanceScreen()),
    GetPage(name: notificationSetup, page: () => const NotificationSettingScreen()),

    GetPage(name: reviewReply, page: () {
      Review? data;
      if(Get.parameters['data'] != 'null') {
        List<int> decode = base64Decode(Get.parameters['data']!.replaceAll(' ', '+'));
        data = Review.fromJson(jsonDecode(utf8.decode(decode)));
      }
      return  ReviewReplyScreen(
        review: data,
        fromPage: Get.parameters['from-page'],
      );
    }),

    GetPage(name: rateCustomer, page: () => RateCustomerScreen(
      bookingId: Get.parameters['booking_id'] ?? '',
      customerName: Uri.decodeComponent(Get.parameters['customer_name'] ?? ''),
    )),

    GetPage(name: helpAndSupport, page: () => SupportScreen()),

    GetPage(name: paymentInformation, page: ()=>const PaymentInformationScreen()),
    GetPage(name: addPaymentInfo, page: ()=> AddPaymentInfoScreen(
        index: Get.parameters['index'] != "null" ? int.parse(Get.parameters["index"]!) : null,
        methodName: Get.parameters['method_name'] != "null" ? Get.parameters["method_name"] : null,
        methodId: Get.parameters['method_id'] != "null" ? Get.parameters["method_id"] : null,
        isActive: Get.parameters['is_active'] != "null" ? Get.parameters["is_active"] == "true" : false,
        isDefault: Get.parameters['is_default'] != "null" ? Get.parameters["is_default"] == "true" : false,
    )),

    GetPage(name: calendarOrder, page: () => const CalendarOrderScreen()),

    GetPage(name: payments, page: () => const PaymentsScreen()),

  ];
  static Widget getRoute(Widget navigateTo) {
    return  navigateTo;
  }
}

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.find<AuthController>().isLoggedIn()) {
      return RouteSettings(name: RouteHelper.getSignInRoute('LogIn'));
    }
    return null;
  }
}

class RedirectToHomeMiddleware extends GetMiddleware {
  @override
  int? get priority => 0;

  @override
  RouteSettings? redirect(String? route) {
    if (Get.find<AuthController>().isLoggedIn()) {
      return RouteSettings(name: RouteHelper.getInitialRoute());
    }
    return null;
  }
}