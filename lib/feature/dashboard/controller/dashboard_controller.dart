import 'package:demandium_provider/feature/custom_post/model/post_model.dart';
import 'package:demandium_provider/feature/dashboard/model/additional_info_count.dart';
import 'package:demandium_provider/feature/dashboard/model/earnig_data_model.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

enum EarningType{monthly, yearly}
class  DashboardController extends GetxController with GetSingleTickerProviderStateMixin implements GetxService {
  final DashBoardRepo dashBoardRepo;

  DashboardController({required this.dashBoardRepo});

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(vsync: this, length: 2);
  }


  TabController? tabController;

  DashboardTopCards? dashboardTopCards;
  AdditionalInfoCount? additionalInfoCount;

  List<DashboardServicemanModel> dashboardServicemanList =[];
  List<DashboardRecentActivityModel> dashboardRecentActivityList=[];
  List<SubscriptionModelData> dashboardSubscriptionList=[];
  List<PostData> dashboardCustomizedPostList = [];
  List<BookingStatusStat> bookingStatusStats = [];
  int totalBookings = 0;

  bool _showNormalBooking = true;
  bool get showNormalBooking => _showNormalBooking;

  bool _showRecentActivityList = true;
  bool get showRecentActivityList => _showRecentActivityList;

  int _paymentMethodIndex = -1;



  int get paymentMethodIndex => _paymentMethodIndex;



  EarningDataModel? _earningDataModel;
  EarningDataModel? get earningDataModel => _earningDataModel;

  bool get isBiddingEnabled =>
      Get.find<SplashController>().configModel.content?.biddingStatus == 1;


  void changeTypeOfShowBookingStatus({required bool status, bool shouldUpdate = true}){
    _showNormalBooking = status;
    if(status){
      tabController?.index = 0;
    }
    if(shouldUpdate){
      update();
    }
  }
  void changeRecentActivityView({bool? status, bool shouldUpdate = true}){
    if(status != null){
      _showRecentActivityList = status;
    }else{
      _showRecentActivityList = !_showRecentActivityList;
    }
    if(shouldUpdate){
      update();
    }
  }


  Future<void> getEarningData() async {
    Response response = await dashBoardRepo.getEarningData();

    if(response.statusCode == 200){
      _earningDataModel = EarningDataModel.fromJson(response.body['content']);

    }else{
      ApiChecker.checkApi(response);
    }
    update();
  }


  Future<void> getDashboardData({bool reload = false}) async {

    if(reload){
      dashboardTopCards = null;
    }

    Response response = await dashBoardRepo.getDashBoardData(
      includeCustomizedPost: isBiddingEnabled,
    );

    if(response.statusCode==200){
      final sections = response.body['content'];
      if (sections is List) {
        applyHomeBundleDashboard(sections);
      }
    }
    else{
      ApiChecker.checkApi(response);
    }

    update();
  }


  void removeSubscriptionItem(String id,{bool shouldUpdate = true}){
    dashboardSubscriptionList.removeWhere((element) => element.subCategoryId == id);
    if(shouldUpdate){
      update();
    }
  }


  void updateIndex (int index, {bool isUpdate = true}) {
    _paymentMethodIndex = index;
    if(isUpdate){
      update();
    }
  }


  void removeServiceman (String id , {bool isUpdate = true}){
    dashboardServicemanList.removeWhere((element) => element.id == id);
    if(isUpdate){
      update();
    }
  }

  void applyHomeBundleDashboard(List<dynamic> sections) {
    for (final section in sections) {
      if (section is! Map) continue;
      final map = Map<String, dynamic>.from(section);

      if (map.containsKey('top_cards')) {
        dashboardTopCards = DashboardTopCards.fromJson(map['top_cards']);
      } else if (map.containsKey('recent_bookings')) {
        dashboardRecentActivityList = [];
        final resentList = map['recent_bookings'] as List<dynamic>? ?? [];
        for (final element in resentList) {
          dashboardRecentActivityList.add(
            DashboardRecentActivityModel.fromJson(element),
          );
        }
      } else if (map.containsKey('subscriptions')) {
        dashboardSubscriptionList = [];
        final subscriptionList = map['subscriptions'] as List<dynamic>? ?? [];
        for (final element in subscriptionList) {
          dashboardSubscriptionList.add(SubscriptionModelData.fromJson(element));
        }
      } else if (map.containsKey('customized_post')) {
        dashboardCustomizedPostList = [];
        final customizedPost = map['customized_post'] as List<dynamic>? ?? [];
        for (final element in customizedPost) {
          dashboardCustomizedPostList.add(PostData.fromJson(element));
        }
      } else if (map.containsKey('booking_stats')) {
        _applyBookingStats(map);
      } else if (map.containsKey('additional_info_count')) {
        additionalInfoCount = AdditionalInfoCount.fromJson(map['additional_info_count']);
      }
    }

    dashboardServicemanList = [];
    _finalizeRecentActivityState();

    update();
  }

  void _applyBookingStats(Map<String, dynamic> map) {
    bookingStatusStats = [];
    final rawStats = map['booking_stats'];
    if (rawStats is List) {
      for (final element in rawStats) {
        if (element is Map) {
          bookingStatusStats.add(
            BookingStatusStat.fromJson(Map<String, dynamic>.from(element)),
          );
        }
      }
    }
    bookingStatusStats = BookingStatusStat.sorted(bookingStatusStats);
    totalBookings = int.tryParse('${map['total_bookings']}') ??
        bookingStatusStats.fold(0, (sum, item) => sum + item.count);
  }

  void _finalizeRecentActivityState() {
    if (!isBiddingEnabled) {
      dashboardCustomizedPostList = [];
      if (additionalInfoCount != null) {
        additionalInfoCount!.customizedPostCount = 0;
      }
      _showNormalBooking = true;
      tabController?.index = 0;
      return;
    }

    if (dashboardRecentActivityList.isEmpty && dashboardCustomizedPostList.isNotEmpty) {
      tabController?.index = 1;
      _showNormalBooking = false;
    } else {
      _showNormalBooking = true;
      tabController?.index = 0;
    }
  }

  void applyHomeBundleEarning(Map<String, dynamic> earning) {
    _earningDataModel = EarningDataModel.fromJson(earning);
    update();
  }

}








