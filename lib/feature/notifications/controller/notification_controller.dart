import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:demandium_provider/feature/notifications/model/notofication_model.dart';


class NotificationController extends GetxController implements GetxService{
  final NotificationRepo notificationRepo;
  NotificationController({required this.notificationRepo});

  NotificationModel? _notificationModel;
  NotificationModel? get notificationModel => _notificationModel;
  List<String> dateList = [];
  List allNotificationList=[];
  List<dynamic> notificationList=[];


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _paginationLoading = false;
  bool get paginationLoading => _paginationLoading;

  int _unreadNotificationCount = 0;
  int get unseenNotificationCount => _unreadNotificationCount;

  int _totalNumberOfNotification=0;
  int get totalNumberOfNotification => _totalNumberOfNotification;

  int? _pageSize = 1;
  int _offset = 1;

  int get offset => _offset;
  int? get pageSize => _pageSize;

  ScrollController scrollController = ScrollController();

  @override
  void onInit(){
    super.onInit();
    scrollController.addListener(() {
      if(scrollController.position.maxScrollExtent/2 < scrollController.position.pixels) {
        if(_offset < _pageSize! ) {
          getNotifications(offset+1, reload: false);
        }
      }
    });
    getUnreadNotificationCount();
  }

  Future<void> getUnreadNotificationCount() async {
    final response = await notificationRepo.getUnreadCount();
    if (response.statusCode == 200) {
      final count = response.body['content']?['unread_count'];
      _unreadNotificationCount = count is int ? count : int.tryParse('$count') ?? 0;
      update();
    }
  }

  Future<void> refreshInboxFromPush() async {
    await getNotifications(1, reload: true, silent: true);
  }

  Future<void> getNotifications(int offset, {bool reload = true, bool silent = false})async{
    _offset = offset;

    Response response = await notificationRepo.getNotification(offset);

    if(reload){
      dateList =[];
      notificationList =[];
    }
    else {
      _paginationLoading = true;
      if (!silent) {
        update();
      }
    }
    if(response.statusCode == 200){

      allNotificationList =[];
      _totalNumberOfNotification = 0;
     _notificationModel =  NotificationModel.fromJson(response.body);

     _pageSize = response.body['content']['last_page'];

     _totalNumberOfNotification  = notificationModel!.content!.total??0;

      for (var data in notificationModel!.content!.data!) {
        if(!dateList.contains(DateConverter.dateStringMonthYear(DateTime.tryParse(data.createdAt!)))) {
          dateList.add(DateConverter.dateStringMonthYear(DateTime.tryParse(data.createdAt!)));
        }
      }

      for (var data in notificationModel!.content!.data!) {
        allNotificationList.add(data);
      }

      for(int i=0;i< dateList.length;i++){
       notificationList.add([]);
       for (var element in allNotificationList) {
         if(dateList[i]== DateConverter.dateStringMonthYear(DateTime.tryParse(element.createdAt!))){
           notificationList[i].add(element);
         }
       }
     }

      await getUnreadNotificationCount();
    } else{
      ApiChecker.checkApi(response);
    }
    _paginationLoading = false;
    _isLoading =false;
    update();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    if (notificationId.isEmpty) {
      return;
    }
    final response = await notificationRepo.markAsRead(notificationId);
    if (response.statusCode == 200) {
      for (final item in allNotificationList) {
        if (item is Data && item.id == notificationId) {
          item.isRead = true;
        }
      }
      if (_unreadNotificationCount > 0) {
        _unreadNotificationCount--;
      }
      update();
      unawaited(getUnreadNotificationCount());
    }
  }

  Future<void> handleInboxNotificationTap(Data notification) async {
    if (notification.id != null && notification.isRead != true) {
      await markNotificationAsRead(notification.id!);
    }

    final action = _resolveInboxAction(notification);

    Get.dialog(
      ImageDialog(
        imageUrl: notification.coverImageFullPath ?? '',
        title: notification.title?.trim() ?? '',
        subTitle: notification.description ?? '',
        actionButtonText: action?.labelKey.tr,
        onActionPressed: action?.onPressed,
      ),
    );
  }

  _InboxNotificationAction? _resolveInboxAction(Data notification) {
    final type = notification.notificationType?.trim().toLowerCase() ?? '';

    switch (type) {
      case 'booking':
      case 'booking_ignored':
      case 'offline-payment':
        final bookingIdentifier = _resolveBookingIdentifier(notification);
        if (bookingIdentifier != null && bookingIdentifier.isNotEmpty) {
          return _InboxNotificationAction(
            labelKey: 'view_booking',
            onPressed: () => _openBookingFromInbox(notification, bookingIdentifier),
          );
        }
        break;
      case 'review':
        return _InboxNotificationAction(
          labelKey: 'view_review',
          onPressed: () => NotificationHelper.openReviewNotificationTarget(),
        );
      case 'advertisement':
        return _InboxNotificationAction(
          labelKey: 'view_ads',
          onPressed: () => Get.toNamed(RouteHelper.getAdvertisementListScreen(count: 0)),
        );
      case 'withdraw':
        return _InboxNotificationAction(
          labelKey: 'see_transaction_history',
          onPressed: () => Get.toNamed(RouteHelper.getTransactionListRoute(fromPage: 'fromNotification')),
        );
    }

    return null;
  }

  String? _resolveBookingIdentifier(Data notification) {
    if (!_isBookingRelatedNotification(notification)) {
      return null;
    }

    return _bookingIdFromNotification(notification);
  }

  String? _bookingIdFromNotification(Data notification) {
    final bookingId = notification.bookingId?.trim();
    if (bookingId != null && bookingId.isNotEmpty) {
      return bookingId;
    }

    return _extractReadableIdFromText(notification.description)
        ?? _extractReadableIdFromText(notification.title);
  }

  bool _isBookingRelatedNotification(Data notification) {
    final type = notification.notificationType?.trim().toLowerCase() ?? '';
    return type == 'booking' || type == 'booking_ignored' || type == 'offline-payment';
  }

  String? _extractReadableIdFromText(String? text) {
    if (text == null || text.trim().isEmpty) {
      return null;
    }

    final match = RegExp(r'\(\s*([A-Z0-9]+)\s*\)').firstMatch(text);
    return match?.group(1)?.trim();
  }

  void _openBookingFromInbox(Data notification, String bookingIdentifier) {
    if (bookingIdentifier.isEmpty) {
      return;
    }

    final bookingType = notification.bookingType?.trim();
    final repeatType = notification.repeatType?.trim();
    if (bookingType == 'repeat' && repeatType == 'single') {
      Get.toNamed(
        RouteHelper.getBookingDetailsRoute(
          subBookingId: bookingIdentifier,
          fromPage: 'fromNotification',
        ),
      );
      return;
    }
    if (bookingType == 'repeat' && repeatType != 'single') {
      Get.toNamed(
        RouteHelper.getRepeatBookingDetailsRoute(
          bookingId: bookingIdentifier,
          fromPage: 'fromNotification',
        ),
      );
      return;
    }
    Get.toNamed(
      RouteHelper.getBookingDetailsRoute(
        bookingId: bookingIdentifier,
        fromPage: 'fromNotification',
      ),
    );
  }
}

class _InboxNotificationAction {
  const _InboxNotificationAction({required this.labelKey, required this.onPressed});

  final String labelKey;
  final VoidCallback onPressed;
}
