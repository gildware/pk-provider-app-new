import 'package:demandium_provider/feature/booking_details/widget/repeat_booking/repeat_booking_details.dart';
import 'package:demandium_provider/feature/booking_details/widget/repeat_booking/repeat_booking_service_log.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class RepeatBookingDetailsScreen extends StatefulWidget {
  final String bookingId;
  final String? fromPage;
  const RepeatBookingDetailsScreen( {
    super.key,required this.bookingId,
    this.fromPage});
  @override
  State<RepeatBookingDetailsScreen> createState() => _RepeatBookingDetailsScreenState();
}
class _RepeatBookingDetailsScreenState extends State<RepeatBookingDetailsScreen> with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    Get.find<BookingDetailsController>().showHideExpandView(0, shouldUpdate: false);
    super.initState();
    tabController = TabController(vsync: this, length: 5);
    Get.find<BookingDetailsController>().resetBookingDetailsValue(resetBookingDetails: true);
    Get.find<BookingDetailsController>().getBookingDetails(widget.bookingId);
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
          final bookingDetailsContent = bookingDetailsController.bookingDetails?.content;

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
          bottom: false,
          child: ExpandableBottomSheet(

                  expandableContent: !AppFeatureFlags.servicemanEnabled ||
                          bookingDetailsController.bottomSheetHeight == 0
                      ? const SizedBox()
                      : AssignServicemanScreen(
                          servicemanList: Get.find<ServicemanSetupController>().servicemanList ?? [],
                          bookingId: widget.bookingId,
                          isSubBooking: true,
                          reAssignServiceman:
                              bookingDetailsController.bookingDetails?.content?.serviceman != null,
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
                            bottom: BorderSide(color: context.adaptivePrimaryColor.withValues(alpha:0.7), width: 1),
                          ),
                        ),
                        child: TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          unselectedLabelColor:Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha:0.5),
                          indicatorColor: context.tabIndicatorColor,
                          controller: tabController,
                          labelColor: context.tabSelectedColor,
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
                                bookingDetailsController.updateServicePageCurrentState(BookingDetailsTabControllerState.status);
                                bookingDetailsController.showHideExpandView(0);
                                break;
                              case 3:
                                bookingDetailsController.updateServicePageCurrentState(BookingDetailsTabControllerState.history);
                                bookingDetailsController.showHideExpandView(0);
                                break;
                              case 4:
                                bookingDetailsController.updateServicePageCurrentState(BookingDetailsTabControllerState.revenue);
                                bookingDetailsController.showHideExpandView(0);
                                break;
                            }
                          },
                          tabs: [
                            Tab(text: 'booking_overview'.tr),
                            Tab(text: 'payments'.tr),
                            Tab(text: 'service_log'.tr),
                            Tab(text: 'history'.tr),
                            Tab(text: 'revenue'.tr),
                          ],
                        ),
                      ),

                      Expanded(
                        child: TabBarView(controller: tabController ,children: [
                          RepeatBookingDetailsWidget(
                            bookingId: widget.bookingId,
                            tabController: tabController,
                            isSubBooking: true,
                          ),
                          BookingPaymentsTab(bookingId: widget.bookingId, isSubBooking: false),
                          RepeatBookingServiceLogWidget(bookingId: widget.bookingId,),
                          BookingEventHistoryWidget(bookingId: widget.bookingId, isSubBooking: false),
                          BookingRevenueTab(bookingId: widget.bookingId, isSubBooking: false),
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
