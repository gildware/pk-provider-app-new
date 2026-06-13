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

  bool _showNormalBooking = true;
  bool get showNormalBooking => _showNormalBooking;

  bool _showRecentActivityList = true;
  bool get showRecentActivityList => _showRecentActivityList;

  int _paymentMethodIndex = -1;



  int get paymentMethodIndex => _paymentMethodIndex;



  EarningDataModel? _earningDataModel;
  EarningDataModel? get earningDataModel => _earningDataModel;


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

    Response response = await dashBoardRepo.getDashBoardData();

    if(response.statusCode==200){
      dashboardTopCards = DashboardTopCards.fromJson(response.body['content'][0]['top_cards']);

      dashboardRecentActivityList = [];
      List<dynamic> resentList = response.body['content'][3]['recent_bookings'];
      for (var element in resentList) {
        dashboardRecentActivityList.add(DashboardRecentActivityModel.fromJson(element));
      }


      dashboardSubscriptionList=[];
      List<dynamic> subscriptionList = response.body['content'][4]['subscriptions'];
      for (var element in subscriptionList) {
        dashboardSubscriptionList.add(SubscriptionModelData.fromJson(element));
      }

      // SERVICEMAN_DISABLED: serviceman_list section removed from dashboard API request
      dashboardServicemanList = [];

      dashboardCustomizedPostList = [];
      List<dynamic> customizedPost = response.body['content'][5]['customized_post'];
      for (var element in customizedPost) {
        dashboardCustomizedPostList.add(PostData.fromJson(element));
      }

      additionalInfoCount = AdditionalInfoCount.fromJson(response.body['content'][6]['additional_info_count']);

      if(dashboardRecentActivityList.isEmpty && dashboardCustomizedPostList.isNotEmpty){
        tabController?.index = 1;
        _showNormalBooking = false;
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
      } else if (map.containsKey('additional_info_count')) {
        additionalInfoCount = AdditionalInfoCount.fromJson(map['additional_info_count']);
      }
    }

    dashboardServicemanList = [];

    if (dashboardRecentActivityList.isEmpty && dashboardCustomizedPostList.isNotEmpty) {
      tabController?.index = 1;
      _showNormalBooking = false;
    }

    update();
  }

  void applyHomeBundleEarning(Map<String, dynamic> earning) {
    _earningDataModel = EarningDataModel.fromJson(earning);
    update();
  }

}








