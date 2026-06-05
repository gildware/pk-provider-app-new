import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class  SubcategorySubscriptionController extends GetxController implements GetxService{
  final SubscriptionRepo subscriptionRepo;
  SubcategorySubscriptionController({required this.subscriptionRepo});

  bool _isLoading= false;
  bool get isLoading => _isLoading;

  bool _isPaginationLoading= false;
  bool get isPaginationLoading => _isPaginationLoading;

  bool _isSubscribeButtonLoading= false;
  bool get isSubscribeButtonLoading => _isSubscribeButtonLoading;

  int _subscriptionIndex =- 1;
  int get  selectedSubscriptionIndex => _subscriptionIndex;

  List<SubscriptionModelData> _subscriptionList=[];
  List<SubscriptionModelData> get subscriptionList=> _subscriptionList;

  int? _pageSize;
  int? get pageSize => _pageSize;

  int _offset = 1;
  int get offset => _offset;

  int _totalSubscription = 0;
  int? get totalSubscription => _totalSubscription;

  final Set<String> _subscribedCategoryIds = {};
  Set<String> get subscribedCategoryIds => _subscribedCategoryIds;

  ScrollController scrollController = ScrollController();

  @override
  void onInit(){
    super.onInit();
    scrollController.addListener(() {
      int selectedSubCategory =  Get.find<ServiceCategoryController>().selectedSubsCategoryIndex;
      List<ServiceCategoryModel> ? serviceCategoryList = Get.find<ServiceCategoryController>().serviceCategoryList;

      if(scrollController.position.maxScrollExtent == scrollController.position.pixels) {
        if(_offset < _pageSize! ) {
          getMySubscriptionData(offset+1, true, categoryId : selectedSubCategory == 0 ? '' : serviceCategoryList?[selectedSubCategory].id.toString());
        }
      }
    });
  }

  Future<void> getMySubscriptionData(int offset, bool isFormPagination, {String? categoryId}) async {
    _offset = offset;
    if(!isFormPagination){
      _subscriptionList =[];
      _isLoading = true;
      update();
    }
    else{
      _isPaginationLoading = true;
      update();
    }
      Response response = await subscriptionRepo.getSubcategorySubscriptionList(offset, categoryId: categoryId);
      if(response.statusCode==200 && response.body['response_code']=="default_200"){
        List<dynamic> list =response.body['content']['data'];
        for (var element in list) {
          if(element['sub_category']!=null){
            _subscriptionList.add(SubscriptionModelData.fromJson(element));
          }
        }
        _pageSize  = response.body['content']['last_page'];
        if(categoryId == null){
          _totalSubscription = response.body['content']['total'];
        }
      } else if(response.statusCode== 401){
        ApiChecker.checkApi(response);
      }
      else{
        // showCustomSnackBar(response.statusText);
      }
    _isPaginationLoading = false;
    _isLoading = false;
    update();
  }

  Future<void> refreshSubscribedCategoryIds() async {
    _subscribedCategoryIds.clear();
    int offset = 1;
    int? lastPage;

    do {
      final response = await subscriptionRepo.getSubcategorySubscriptionList(offset, categoryId: '');
      if (response.statusCode != 200 || response.body['response_code'] != 'default_200') {
        break;
      }
      final list = response.body['content']['data'] as List<dynamic>;
      for (final element in list) {
        if (element['sub_category'] != null && element['category_id'] != null) {
          _subscribedCategoryIds.add(element['category_id'].toString());
        }
      }
      lastPage = response.body['content']['last_page'];
      offset++;
    } while (offset <= (lastPage ?? 1) && lastPage != null);

    update();
  }

  void _removeCategoryIdIfNoSubscriptions(String? categoryId) {
    if (categoryId == null) return;
    final hasRemaining = _subscriptionList.any((s) => s.categoryId == categoryId);
    if (!hasRemaining) {
      _subscribedCategoryIds.remove(categoryId);
    }
  }

  void removeSubscriptionItem(String id, {bool shouldUpdate = true}){

    for (var element in _subscriptionList) {
      if(element.subCategoryId == id){
        final categoryId = element.categoryId;
        _subscriptionList.remove(element);
        _totalSubscription --;
        _removeCategoryIdIfNoSubscriptions(categoryId);
        break;
      }
    }

    if(shouldUpdate){
      update();
    }
  }

  Future<void> unsubscribeCategory(String id,int index) async {
    _isSubscribeButtonLoading = true;
    update();
    Response response = await subscriptionRepo.changeSubscriptionStatus(id);
    if(response.statusCode==200){
      final categoryId = subscriptionList[index].categoryId;
      subscriptionList.removeAt(index);
      _totalSubscription--;
      _removeCategoryIdIfNoSubscriptions(categoryId);
    }
    _isSubscribeButtonLoading = false;
    update();
  }

  void changeSubscriptionIndex(int subscriptionIndex){
    _subscriptionIndex = subscriptionIndex;
    update();
  }
}