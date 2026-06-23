import 'package:get/get.dart';
import 'package:demandium_provider/helper/booking_list_filter_tabs.dart';
import 'package:demandium_provider/util/core_export.dart';


class BookingRequestController extends GetxController implements GetxService {
  static const String bookingTabsUpdateId = 'booking_tabs';
  static const String bookingListUpdateId = 'booking_list';

  final BookingRequestRepo bookingRequestRepo;
  BookingRequestController({required this.bookingRequestRepo});


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isTabLoading = false;
  bool get isTabLoading => _isTabLoading;

  int get currentIndex {
    final visible = bookingRequestStatusList;
    if (visible.isEmpty) return 0;
    final idx = visible.indexOf(_selectedBookingStatus);
    return idx >= 0 ? idx : 0;
  }

  int _apiHitCount = 0;

  int? _pageSize;
  int _offset = 1;

  int get offset => _offset;
  int? get pageSize => _pageSize;

  List <BookingRequestModel>? _bookingRequestList;
  List <BookingRequestModel>? get bookingRequestList=> _bookingRequestList;

  ServiceType selectedServiceType = ServiceType.all;

  BookingCount? _bookingCount;
  BookingCount? get bookingCount => _bookingCount;

  AutoScrollController? menuScrollController;

  String _selectedBookingStatus = 'pending';

  List<String> get bookingRequestStatusList =>
      visibleBookingListFilterTabsOrDefault(_bookingCount);

  String get bookingStatus => _selectedBookingStatus;

  final ScrollController scrollController = ScrollController();


  @override
  void onInit(){
    super.onInit();
    scrollController.addListener(() {
      if(scrollController.position.maxScrollExtent == scrollController.position.pixels) {
        if(_offset < _pageSize! ) {
          getBookingRequestList(bookingStatus, offset+1, paginationLoading: true);
        }
      }

    });
  }

  void _ensureSelectedTabVisible() {
    final visible = bookingRequestStatusList;
    if (visible.isEmpty) return;
    if (!visible.contains(_selectedBookingStatus)) {
      _selectedBookingStatus = visible.first;
    }
  }

  Future<void> switchBookingTab(String tab) async {
    if (!bookingFilterTabShouldShow(tab, _bookingCount)) return;
    if (_selectedBookingStatus == tab) return;

    _selectedBookingStatus = tab;
    update([bookingTabsUpdateId]);

    await getBookingRequestList(tab, 1, reload: true, tabSwitch: true);
  }


  Future<void> getBookingRequestList(String requestType,int offset, {bool reload = false, int index = 0, bool isFirst = false,bool paginationLoading = false, bool tabSwitch = false}) async {
    if (Get.find<UserProfileController>().isPendingAdminVerification) {
      _bookingRequestList = [];
      _bookingCount = BookingCount(
        all: 0,
        pending: 0,
        accepted: 0,
        ongoing: 0,
        onHold: 0,
        completed: 0,
        canceled: 0,
        reopened: 0,
        resolved: 0,
        disputedCancelled: 0,
        disputedCompleted: 0,
        holdAfterVisit: 0,
        completedNoOrLittle: 0,
        cancelledAfterVisit: 0,
        lossMakingPending: 0,
        lossRecovered: 0,
        lossSettled: 0,
      );
      _ensureSelectedTabVisible();
      _isLoading = false;
      _isTabLoading = false;
      update([bookingTabsUpdateId, bookingListUpdateId]);
      return;
    }

    _offset = offset;
    _apiHitCount ++;
    try {
      if (tabSwitch) {
        _isTabLoading = true;
        update([bookingListUpdateId]);
      } else if(reload){
        _bookingRequestList = null;
        update([bookingListUpdateId]);
      }
      if(paginationLoading){
        _isLoading = true;
        update([bookingListUpdateId]);
      }

      Response response = await bookingRequestRepo.getBookingRequestData(requestType.toLowerCase(), offset, selectedServiceType);

      if(response.statusCode == 200){

        _bookingCount = BookingCount.fromJson(
          Map<String, dynamic>.from(response.body['content']['bookings_count'] ?? {}),
        );
        _ensureSelectedTabVisible();

        if (requestType.toLowerCase() != bookingStatus && _offset == 1 && !paginationLoading) {
          await getBookingRequestList(bookingStatus, 1, reload: true, tabSwitch: tabSwitch);
          return;
        }

        if(_offset == 1){
          _bookingRequestList = [];
          List<dynamic> bookingList = response.body['content']['bookings']['data'];
          for (var bookingRequest in bookingList) {
            bookingRequestList!.add(BookingRequestModel.fromJson(bookingRequest));
          }
        }else{
          List<dynamic> bookingList = response.body['content']['bookings']['data'];
          for (var bookingRequest in bookingList) {
            bookingRequestList!.add(BookingRequestModel.fromJson(bookingRequest));
          }
        }
        _pageSize = response.body['content']['bookings']['last_page'];
      }
      else{
       ApiChecker.checkApi(response);
      }
    } finally {
      _apiHitCount--;
      _isLoading = false;
      _isTabLoading = false;

      if(_apiHitCount==0){
        update([bookingListUpdateId, bookingTabsUpdateId]);
      }
    }
  }

  void resetOnAuthChange() {
    _bookingRequestList = null;
    _bookingCount = null;
    _selectedBookingStatus = 'pending';
    _offset = 1;
    _pageSize = null;
    update([bookingListUpdateId, bookingTabsUpdateId]);
  }

  void removeBookingItemFromList(String bookingId,  {bool shouldUpdate = false, required String bookingStatus}){

    if(bookingStatus != "all"){
      _bookingRequestList?.removeWhere((element) => element.id == bookingId);
    }
    if(shouldUpdate){
      update([bookingListUpdateId]);
    }
  }

  void updateSelectedServiceType({ServiceType? type}){
    if(type!=null){
      selectedServiceType = type;
      update([bookingTabsUpdateId]);
      getBookingRequestList(bookingStatus, 1, reload: true);
    }else{
      selectedServiceType = ServiceType.all;
    }
  }

  List<PopupMenuModel> getPopupMenuList({String status = "", bool isRepeatBooking = false, RepeatBooking? ongoingRepeatBooking}){
    if(status == "pending"){
      return [
        PopupMenuModel(title: "booking_details", icon: Icons.remove_red_eye_sharp),
        PopupMenuModel(title: "accept", icon: Icons.check),
        PopupMenuModel(title: "ignore", icon: Icons.close),
      ];
    } else if(status == "accepted" || status == "ongoing" ){
      return [
        PopupMenuModel(title: isRepeatBooking ? "full_booking_details" : "booking_details", icon: Icons.remove_red_eye_sharp),
        if(isRepeatBooking && ongoingRepeatBooking !=null)  PopupMenuModel(title: ongoingRepeatBooking.bookingStatus == "ongoing" ?  "ongoing_booking_details" : "upcoming_booking_details" , icon: Icons.remove_red_eye_sharp),
        PopupMenuModel(title: isRepeatBooking ? "download_full_invoice" : "download_invoice", icon: Icons.file_download_outlined),
        if(isRepeatBooking && ongoingRepeatBooking !=null) PopupMenuModel(title:   ongoingRepeatBooking.bookingStatus == "ongoing" ? "download_ongoing_invoice" : "download_upcoming_invoice", icon: Icons.file_download_outlined),
      ];
    }
    else if( status == "completed" || status == "canceled"){
      return [
        PopupMenuModel(title: isRepeatBooking ? "full_booking_details" : "booking_details", icon: Icons.remove_red_eye_sharp),
        PopupMenuModel(title: isRepeatBooking ? "download_full_invoice" : "download_invoice", icon: Icons.file_download_outlined),
      ];
    }
    return [];
  }

}
