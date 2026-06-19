import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class BookingDetailsScreen extends StatefulWidget {
  final String? bookingId;
  final String? subBookingId;
  final String? fromPage;

  const BookingDetailsScreen( {
    super.key,required this.bookingId,
    this.fromPage,
    this.subBookingId,
  });
  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}
class _BookingDetailsScreenState extends State<BookingDetailsScreen> with SingleTickerProviderStateMixin {
  TabController? controller;

  @override
  void initState() {
    Get.find<BookingDetailsController>().showHideExpandView(0, shouldUpdate: false);
    super.initState();
    controller = TabController(vsync: this, length: 4);
    var bookingDetailsController = Get.find<BookingDetailsController>();
    bool isRegularBooking = widget.bookingId != null && widget.bookingId != "null";
    bookingDetailsController.resetBookingDetailsValue(resetBookingDetails: isRegularBooking);
    if(isRegularBooking){
      bookingDetailsController.getBookingDetails(widget.bookingId!);
    }else{
      bookingDetailsController.getBookingSubDetails(widget.subBookingId!);
    }
    // SERVICEMAN_DISABLED
    if (AppFeatureFlags.servicemanEnabled) {
      Get.find<ServicemanSetupController>().getAllServicemanList(1, reload: false, status: 'active');
    }
  }

  String? _bookingIdSubtitle(BookingDetailsContent? bookingDetailsContent) {
    final readableId = bookingDetailsContent?.readableId;
    if (readableId == null || readableId.isEmpty) return null;
    return '${'booking'.tr} #$readableId';
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
     onPopInvoked: (){
       if(widget.fromPage == 'fromNotification') {
         Get.offAllNamed(RouteHelper.getInitialRoute());
       }
     },
      child: GetBuilder<BookingDetailsController>(
        builder: (bookingDetailsController) {
          bool isSubBooking = widget.subBookingId != null && widget.subBookingId != "null";
          BookingDetailsContent? bookingDetails = bookingDetailsController.bookingDetails?.content;
          BookingDetailsContent? subBookingDetails = bookingDetailsController.subBookingDetails?.content;
          BookingDetailsContent? bookingDetailsContent = isSubBooking ? subBookingDetails : bookingDetails;

          return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: CustomAppBar(
          title: 'booking_details'.tr,
          subtitle: _bookingIdSubtitle(bookingDetailsContent),
          onBackPressed: (){
            if(widget.fromPage == 'fromNotification'){
              Get.offAllNamed(RouteHelper.getInitialRoute());
            }else{
              Get.back();
            }
          },
        ),

        body: SafeArea(
          child: ExpandableBottomSheet(

                expandableContent: !AppFeatureFlags.servicemanEnabled ||
                        bookingDetailsController.bottomSheetHeight == 0
                    ? const SizedBox()
                    : AssignServicemanScreen(
                        servicemanList: Get.find<ServicemanSetupController>().servicemanList ?? [],
                        bookingId: widget.bookingId!,
                        isSubBooking: isSubBooking,
                        reAssignServiceman: isSubBooking
                            ? subBookingDetails?.serviceman != null
                            : bookingDetails?.serviceman != null,
                      ),

                persistentContentHeight: bookingDetailsController.bottomSheetHeight,

                background: Scaffold( backgroundColor: Theme.of(context).colorScheme.surface,
                  body:Column( children: [

                    Container(
                      height: 45,
                      width: Get.width,
                      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        border:  Border(
                          bottom: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha:0.7), width: 1),
                        ),
                      ),
                      child: TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        unselectedLabelColor:Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha:0.5),
                        indicatorColor: Theme.of(context).primaryColor,
                        controller: controller,
                        labelColor: Theme.of(context).primaryColor,
                        labelStyle:  robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                        labelPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                        onTap: (int? index) {
                          switch (index) {
                            case 0:
                              bookingDetailsController.updateServicePageCurrentState(BookingDetailsTabControllerState.bookingDetails);
                              break;
                            case 1:
                              bookingDetailsController.updateServicePageCurrentState(BookingDetailsTabControllerState.payments);
                              bookingDetailsController.showHideExpandView(0);
                              break;
                            case 2:
                              bookingDetailsController.updateServicePageCurrentState(BookingDetailsTabControllerState.history);
                              bookingDetailsController.showHideExpandView(0);
                              break;
                            case 3:
                              bookingDetailsController.updateServicePageCurrentState(BookingDetailsTabControllerState.revenue);
                              bookingDetailsController.showHideExpandView(0);
                              break;
                          }
                        },
                        tabs: [
                          Tab(text: 'booking_overview'.tr),
                          Tab(text: 'payments'.tr),
                          Tab(text: 'history'.tr),
                          Tab(text: 'revenue'.tr),
                        ],
                      ),
                    ),

                    Expanded(
                      child: TabBarView(controller: controller ,children: [
                        BookingDetailsWidget(bookingId: widget.bookingId , subBookingId : widget.subBookingId, isSubBooking: isSubBooking, tabController: controller,),
                        BookingPaymentsTab(bookingId: widget.bookingId, subBookingId: widget.subBookingId, isSubBooking: isSubBooking,),
                        BookingEventHistoryWidget(
                          bookingId: isSubBooking ? widget.subBookingId : widget.bookingId,
                          isSubBooking: isSubBooking,
                        ),
                        BookingRevenueTab(bookingId: widget.bookingId, subBookingId: widget.subBookingId, isSubBooking: isSubBooking,),
                      ]),
                    ),

                  ]),
                ),
              ),
        ),
      );
        },
      ),
    );
  }
}
