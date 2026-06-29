import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/helper/booking_alert_watcher.dart';
import 'package:demandium_provider/helper/booking_helper.dart';
import 'package:demandium_provider/helper/booking_notification_constants.dart';
import 'package:demandium_provider/util/core_export.dart';

class BookingDetailsController extends GetxController implements GetxService{
  final BookingDetailsRepo bookingDetailsRepo;
  BookingDetailsController({required this.bookingDetailsRepo});

  final List<String> statusTypeList = [
    "accepted",
    "ongoing",
    "completed",
    "canceled",
  ];

  String dropDownValue = '';
  String subBookingDropDownValue = '';

  ScrollController completedServiceImagesScrollController  = ScrollController();

  String _otp = '';
  String get otp => _otp;

  bool _isAcceptButtonLoading = false;
  bool get isAcceptButtonLoading => _isAcceptButtonLoading;

  bool _isIgnoreButtonLoading = false;
  bool get isIgnoreButtonLoading => _isIgnoreButtonLoading;

  bool _isStatusUpdateLoading = false;
  bool get isStatusUpdateLoading => _isStatusUpdateLoading;

  bool _showPhotoEvidenceField = false;
  bool get showPhotoEvidenceField => _showPhotoEvidenceField;

  bool _isWrongOtpSubmitted = false;
  bool get isWrongOtpSubmitted => _isWrongOtpSubmitted;

  List<XFile> _photoEvidence = [];
  List<XFile> get pickedPhotoEvidence => _photoEvidence;

  bool _hideResendButton = false;
  bool get hideResendButton => _hideResendButton;

  String? _lastStatusUpdateMessage;
  String? get lastStatusUpdateMessage => _lastStatusUpdateMessage;

  List<BookingReasonModel> _providerCancellationReasons = [];
  List<BookingReasonModel> get providerCancellationReasons => _providerCancellationReasons;

  bool _isLoadingCancellationReasons = false;
  bool get isLoadingCancellationReasons => _isLoadingCancellationReasons;

  Future<List<BookingReasonModel>>? _providerCancellationReasonsRequest;

  List<BookingReasonModel> _providerHoldReasons = [];
  List<BookingReasonModel> get providerHoldReasons => _providerHoldReasons;

  bool _isLoadingHoldReasons = false;
  bool get isLoadingHoldReasons => _isLoadingHoldReasons;

  Future<List<BookingReasonModel>>? _providerHoldReasonsRequest;


  BookingDetailsModel? _bookingDetails;
  BookingDetailsModel? get bookingDetails => _bookingDetails;

  BookingDetailsModel? _subBookingDetails;
  BookingDetailsModel? get subBookingDetails => _subBookingDetails;

  double _bottomSheetHeight = 0;
  double get bottomSheetHeight => _bottomSheetHeight;

  var bookingPageCurrentState = BookingDetailsTabControllerState.bookingDetails;

  final DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  final TimeOfDay _selectedTimeOfDay = TimeOfDay.now();
  TimeOfDay get selectedTimeOfDay => _selectedTimeOfDay;



  @override
  void onInit() {
    super.onInit();
    if(Get.find<SplashController>().configModel.content?.providerCanCancelBooking == 0 ){
      statusTypeList.remove('canceled');
    }

  }

  Future<void> getBookingDetails(String bookingID,{bool reload = true, bool initEditBooking = true}) async {

    Response response = await bookingDetailsRepo.getBookingDetails(bookingID);

    if(response.statusCode == 200 ){
      _bookingDetails = BookingDetailsModel.fromJson(response.body);

      if(initEditBooking){
        Get.find<BookingEditController>().initializedControllerValue(_bookingDetails?.content);
      }
     dropDownValue = bookingDetails?.content?.bookingStatus ?? "";
      if(response.body["response_code"] == "default_204"){
        Get.find<BookingRequestController>().removeBookingItemFromList(bookingID, bookingStatus: "", shouldUpdate: true);
      }
    }  else{
     ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getBookingSubDetails(String bookingID,{bool reload = true}) async {

    Response response = await bookingDetailsRepo.getSubBookingDetails(bookingID);

    if(response.statusCode == 200 ){
      _subBookingDetails = BookingDetailsModel.fromJson(response.body);
      Get.find<BookingEditController>().initializedControllerValue(_subBookingDetails?.content);
      subBookingDropDownValue = _subBookingDetails?.content?.bookingStatus ?? "";
    } else{
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> acceptBookingRequest(String bookingId) async {
    _isAcceptButtonLoading = true;
    update();
    BookingAlertWatcher.markBookingHandled(bookingId);
    Response response = await bookingDetailsRepo.acceptBookingRequest(bookingId);
    if(response.statusCode==200 && response.body['response_code'] == "status_update_success_200"){
      await getBookingDetails( bookingId, reload: false );
      showCustomSnackBar(response.body["message"],  type: ToasterMessageType.success);
      Get.find<BookingRequestController>().getBookingRequestList(Get.find<BookingRequestController>().bookingStatus, 1);
    }
    else{
     ApiChecker.checkApi(response);
    }
    _isAcceptButtonLoading = false;
    update();
  }

  Future<bool> ignoreBookingRequest(
    String bookingId, {
    int? providerCancellationReasonId,
    String? statusChangeRemarks,
  }) async {
    _isIgnoreButtonLoading = true;
    update();
    Response response = await bookingDetailsRepo.ignoreBookingRequest(
      bookingId,
      providerCancellationReasonId: providerCancellationReasonId,
      statusChangeRemarks: statusChangeRemarks,
    );
    if (response.statusCode == 200) {
      final responseCode = response.body is Map
          ? '${response.body['response_code'] ?? ''}'
          : '';
      final isSuccess = responseCode.isEmpty ||
          responseCode == 'booking_ignore_success_200' ||
          responseCode == 'booking_already_ignore_200' ||
          responseCode == 'status_update_success_200';

      if (!isSuccess) {
        ApiChecker.checkApi(response);
        _isIgnoreButtonLoading = false;
        update();
        return false;
      }

      BookingAlertWatcher.markBookingHandled(bookingId);
      await FlutterLocalNotificationsPlugin().cancel(
        id: BookingNotificationConstants.notificationIdFor(bookingId),
      );
      showCustomSnackBar(response.body["message"],  type: ToasterMessageType.success);
      Get.find<BookingRequestController>().getBookingRequestList(Get.find<BookingRequestController>().bookingStatus, 1);
      _isIgnoreButtonLoading = false;
      update();
      return true;
    }
    else{
      ApiChecker.checkApi(response);
    }
    _isIgnoreButtonLoading = false;
    update();
    return false;
  }

  Future<void> cancelSubBooking({required String bookingId, required String subBookingId}) async {
    _isIgnoreButtonLoading = true;
    update();
    Response response = await bookingDetailsRepo.cancelSubBooking(subBookingId);
    if(response.statusCode==200 ) {
      BookingAlertWatcher.markBookingHandled(bookingId);
      await FlutterLocalNotificationsPlugin().cancel(
        id: BookingNotificationConstants.notificationIdFor(bookingId),
      );
      Get.find<BookingRequestController>().getBookingRequestList(Get.find<BookingRequestController>().bookingStatus, 1);
      final message = response.body is Map
          ? response.body['message']?.toString() ?? ''
          : '';
      _completeBookingWithdrawalUi(
        navigateBack: true,
        successMessage: message.isNotEmpty ? message : 'provider_cancellation_request_received'.tr,
      );
    }
    else{
      ApiChecker.checkApi(response);
    }
    _isIgnoreButtonLoading = false;
    update();
  }



   Future<bool> changeBookingStatus(
    String bookingId, {
    String? bookingStatus,
    bool isBack = false,
    required bool isSubBooking,
    int? providerCancellationReasonId,
    String? statusChangeRemarks,
    int? holdReopenReasonId,
    bool deferUiFeedback = false,
  }) async {
    final targetStatus = isSubBooking ? subBookingDropDownValue : dropDownValue;
    final bookingContent = isSubBooking ? subBookingDetails?.content : bookingDetails?.content;

    if (targetStatus == 'completed' && bookingContent != null && !BookingHelper.canCompleteBooking(bookingContent)) {
      showCustomSnackBar('complete_booking_after_due_cleared'.tr, type: ToasterMessageType.info);
      return false;
    }

    _isStatusUpdateLoading = true;
    update();

    List<MultipartBody> multiParts = [];
    for(XFile file in _photoEvidence) {
      multiParts.add(MultipartBody('evidence_photos[]', file));
    }
    if(bookingStatus != null && targetStatus == 'canceled' && bookingStatus != 'pending' && bookingStatus != 'accepted'){
      showCustomSnackBar('provider_can_only_cancel_pending_or_accepted_booking'.tr, type : ToasterMessageType.info);
      _isStatusUpdateLoading = false;
      update();
      return false;
    }else if(bookingStatus != null && bookingStatus == 'ongoing' && targetStatus == 'canceled'){
      showCustomSnackBar('service_ongoing_can_not_cancel_booking'.tr, type : ToasterMessageType.info);
      _isStatusUpdateLoading = false;
      update();
      return false;
    }else if(bookingStatus != null && bookingStatus == 'ongoing' && targetStatus == 'accepted'){
      showCustomSnackBar('service_is_already_ongoing'.tr, type : ToasterMessageType.info);
      _isStatusUpdateLoading = false;
      update();
      return false;
    }else{
      Response response = await bookingDetailsRepo.changeBookingStatus(
        bookingId,
        targetStatus,
        otp,
        multiParts,
        isSubBooking,
        providerCancellationReasonId: providerCancellationReasonId,
        statusChangeRemarks: statusChangeRemarks,
        holdReopenReasonId: holdReopenReasonId,
      );
      if(response.statusCode==200 && response.body["response_code"]=="status_update_success_200"){
        final isProviderWithdrawal =
            !isSubBooking && targetStatus == 'canceled' && bookingStatus == 'accepted';
        final message = response.body['message']?.toString() ?? '';
        final successMessage = message.isNotEmpty
            ? message.capitalizeFirst!
            : 'provider_cancellation_request_received'.tr;
        _lastStatusUpdateMessage = successMessage;

        if (isProviderWithdrawal) {
          BookingAlertWatcher.markBookingHandled(bookingId);
          await FlutterLocalNotificationsPlugin().cancel(
            id: BookingNotificationConstants.notificationIdFor(bookingId),
          );
          Get.find<BookingRequestController>().getBookingRequestList(
            Get.find<BookingRequestController>().bookingStatus,
            1,
          );
        } else if(isSubBooking){
          await getBookingSubDetails(bookingId,reload: false);
         getBookingDetails(_bookingDetails?.content?.id ?? "",reload: false);
        }else{
          await getBookingDetails(bookingId,reload: false);
          Get.find<BookingRequestController>().getBookingRequestList(Get.find<BookingRequestController>().bookingStatus, 1);
        }

        if (deferUiFeedback) {
          _isStatusUpdateLoading = false;
          update();
          return true;
        }

        if (isProviderWithdrawal) {
          _completeBookingWithdrawalUi(
            navigateBack: isBack,
            successMessage: successMessage,
          );
        } else {
          if(isBack){
            _navigateBackSafely();
          }
          _showSuccessSnackBarDeferred(successMessage);
        }

        _isStatusUpdateLoading = false;
        update();
        return true;
      }
      else if(response.statusCode==200 && response.body["response_code"] == "default_403"){
        if(dropDownValue == "completed" && otp.isNotEmpty){
          _isWrongOtpSubmitted  = true;
        }
      }else{
        ApiChecker.checkApi(response);
      }
    }
    _isStatusUpdateLoading = false;
    update();
    return false;
  }

  bool _isRecordPaymentLoading = false;
  bool get isRecordPaymentLoading => _isRecordPaymentLoading;

  Future<bool> recordCustomerPayment({
    required String bookingId,
    required double amount,
    bool isSubBooking = false,
    String? subBookingId,
    bool closeModalOnSuccess = false,
  }) async {
    _isRecordPaymentLoading = true;
    update();

    final response = await bookingDetailsRepo.recordBookingPayment(bookingId, amount);
    bool isSuccess = false;

    if (response.statusCode == 200 && response.body['response_code'] == 'default_update_200') {
      if (isSubBooking) {
        await getBookingSubDetails(subBookingId ?? bookingId, reload: false);
        await getBookingDetails(bookingId, reload: false);
      } else {
        await getBookingDetails(bookingId, reload: false);
      }
      if (closeModalOnSuccess && (Get.isBottomSheetOpen ?? false)) {
        Get.back();
      }
      showCustomSnackBar(
        response.body['message']?.toString() ?? 'payment_recorded_successfully'.tr,
        type: ToasterMessageType.success,
      );
      isSuccess = true;
    } else {
      ApiChecker.checkApi(response);
    }

    _isRecordPaymentLoading = false;
    update();
    return isSuccess;
  }

  Future<bool> sendBookingOTPNotification(String? bookingId, {bool shouldUpdate = true, bool resend = false}) async {
    if(shouldUpdate){
      _hideResendButton = true;
      update();
    }
    Response response = await bookingDetailsRepo.sendBookingOTPNotification(bookingId);
    bool isSuccess;
    if(response.statusCode == 200) {
      isSuccess = true;
    }else {
      ApiChecker.checkApi(response);
      isSuccess = false;
    }
    _hideResendButton = false;
    update();
    return isSuccess;
  }

  void updateServicePageCurrentState(BookingDetailsTabControllerState bookingDetailsTabControllerState, {bool shouldUpdate = true}){
    bookingPageCurrentState = bookingDetailsTabControllerState;
    if(shouldUpdate){
      update();
    }
  }


  void showHideExpandView(double bottomHeight, {bool shouldUpdate = true}){
    _bottomSheetHeight = bottomHeight;

    if(shouldUpdate){
      update();
    }
  }

  Future<List<BookingReasonModel>> getProviderCancellationReasons({bool forceReload = false}) async {
    if (_providerCancellationReasons.isNotEmpty && !forceReload) {
      return _providerCancellationReasons;
    }

    if (_providerCancellationReasonsRequest != null && !forceReload) {
      return _providerCancellationReasonsRequest!;
    }

    _isLoadingCancellationReasons = true;

    _providerCancellationReasonsRequest = _fetchProviderCancellationReasons();
    try {
      return await _providerCancellationReasonsRequest!;
    } finally {
      _providerCancellationReasonsRequest = null;
    }
  }

  Future<List<BookingReasonModel>> _fetchProviderCancellationReasons() async {
    try {
      final response = await bookingDetailsRepo.getProviderCancellationReasons();
      final body = response.body;
      final responseCode = body is Map ? body['response_code']?.toString() : null;

      if (response.statusCode == 200 && responseCode == 'default_200') {
        final List<dynamic> raw = body is Map && body['content'] is List ? body['content'] : [];
        _providerCancellationReasons = raw
            .whereType<Map>()
            .map((item) => BookingReasonModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        ApiChecker.checkApi(response);
        _providerCancellationReasons = [];
      }
    } catch (_) {
      _providerCancellationReasons = [];
      showCustomSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
    } finally {
      _isLoadingCancellationReasons = false;
    }

    return _providerCancellationReasons;
  }

  Future<List<BookingReasonModel>> getProviderHoldReasons({bool forceReload = false}) async {
    if (_providerHoldReasons.isNotEmpty && !forceReload) {
      return _providerHoldReasons;
    }

    if (_providerHoldReasonsRequest != null && !forceReload) {
      return _providerHoldReasonsRequest!;
    }

    _isLoadingHoldReasons = true;

    _providerHoldReasonsRequest = _fetchProviderHoldReasons();
    try {
      return await _providerHoldReasonsRequest!;
    } finally {
      _providerHoldReasonsRequest = null;
    }
  }

  Future<List<BookingReasonModel>> _fetchProviderHoldReasons() async {
    try {
      final response = await bookingDetailsRepo.getProviderHoldReasons();
      final body = response.body;
      final responseCode = body is Map ? body['response_code']?.toString() : null;

      if (response.statusCode == 200 && responseCode == 'default_200') {
        final List<dynamic> raw = body is Map && body['content'] is List ? body['content'] : [];
        _providerHoldReasons = raw
            .whereType<Map>()
            .map((item) => BookingReasonModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        ApiChecker.checkApi(response);
        _providerHoldReasons = [];
      }
    } catch (_) {
      _providerHoldReasons = [];
      showCustomSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
    } finally {
      _isLoadingHoldReasons = false;
    }

    return _providerHoldReasons;
  }

  void prefetchProviderReasonLists() {
    getProviderCancellationReasons();
    getProviderHoldReasons();
  }

  void changeBookingStatusDropDownValue(String status, bool isSubBooking){
    if(isSubBooking){
      subBookingDropDownValue = status;
    }else{
      dropDownValue = status;

    }

    update();
  }

  void changePhotoEvidenceStatus({bool isUpdate = true , bool status = false}){
    _showPhotoEvidenceField = status;
    if(isUpdate) {
      update();
    }
  }

  Future<void> pickPhotoEvidence({required bool isRemove, required bool isCamera}) async {
  if(isRemove) {
    _photoEvidence = [];
    _showPhotoEvidenceField = false;
  }else {
    ImageSource source = isCamera ? ImageSource.camera : ImageSource.gallery;

    XFile? xFile = await FileValidationHelper.validateAndPickImage(
      source: source,
      imageQuality: isCamera ? 50 : AppConstants.defaultImageQuality,
    );
    if(xFile != null) {
      _photoEvidence.add(xFile);
      if(Get.isBottomSheetOpen!){
        Get.back();
      }
      changePhotoEvidenceStatus(isUpdate: false, status: true);
    }
    update();
  }
}

  void removePhotoEvidence(int index) {
    _photoEvidence.removeAt(index);
    update();
  }

  void setOtp(String otp) {
    _otp = otp;
    resetWrongOtpValue(shouldUpdate: false);
    if(otp != '') {
      update();
    }
  }

  void resetWrongOtpValue({bool shouldUpdate = true}){
    _isWrongOtpSubmitted = false;

    if(shouldUpdate){
      update();
    }
  }

  void resetBookingDetailsValue({bool shouldUpdate = false, bool resetBookingDetails = false}){
    _photoEvidence = [];
    _showPhotoEvidenceField = false;
    bookingPageCurrentState = BookingDetailsTabControllerState.bookingDetails;
    _subBookingDetails = null;
    if(resetBookingDetails){
      _bookingDetails = null;
    }
  }

  void _navigateBackSafely() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen == true) {
        Get.back();
        return;
      }
      if (Get.key.currentState?.canPop() ?? false) {
        Get.back();
      }
    });
  }

  void _showSuccessSnackBarDeferred(String message) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 150), () {
        showCustomSnackBar(message, type: ToasterMessageType.success);
      });
    });
  }

  void _completeBookingWithdrawalUi({
    required bool navigateBack,
    required String successMessage,
  }) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      if (navigateBack) {
        Future<void>.delayed(const Duration(milliseconds: 50), () {
          if (Get.key.currentState?.canPop() ?? false) {
            Get.back();
          }
        });
      }
      Future<void>.delayed(const Duration(milliseconds: 200), () {
        showCustomSnackBar(successMessage, type: ToasterMessageType.success);
      });
    });
  }

  bool isShowChattingButton(BookingDetailsContent? bookingDetails, TabController? tabController){
    return ((bookingDetails != null) && (bookingDetails.bookingStatus == "accepted" || bookingDetails.bookingStatus == "ongoing" )
        && ((bookingDetails.serviceman !=null || bookingDetails.subBooking?.serviceman !=null) || (bookingDetails.customer != null || bookingDetails.subBooking?.customer != null)));
  }

  List<PopupMenuModel> getPopupMenuList({required String status}){
     if( status == "accepted" ){
      return [
        PopupMenuModel(title:  "download_invoice", icon: Icons.file_download_outlined),
        PopupMenuModel(title:  "cancel", icon: Icons.cancel_outlined),
      ];
    } else if(status == "ongoing" || status == "completed" || status == "canceled"){
       return [
         PopupMenuModel(title:  "booking_details", icon: Icons.remove_red_eye_sharp),
         PopupMenuModel(title:  "download_invoice", icon: Icons.file_download_outlined),
       ];
     }
    return [];
  }
}