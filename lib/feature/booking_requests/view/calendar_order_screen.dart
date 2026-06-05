import 'package:demandium_provider/common/widgets/circular_icon_button_widget.dart';
import 'package:demandium_provider/common/widgets/loading_overlay_widget.dart';
import 'package:demandium_provider/feature/booking_requests/controller/calendar_controller.dart';
import 'package:demandium_provider/feature/booking_requests/controller/calender_order_filter_controller.dart';
import 'package:demandium_provider/feature/booking_requests/model/booking_appointment_model.dart';
import 'package:demandium_provider/feature/booking_requests/widgets/active_filters_display_widget.dart';
import 'package:demandium_provider/feature/booking_requests/widgets/calendar_filter_bottom_sheet.dart';
import 'package:demandium_provider/feature/booking_requests/widgets/calender_header_widget.dart';
import 'package:demandium_provider/feature/booking_requests/widgets/calender_order_list_dialog_widget.dart';
import 'package:demandium_provider/feature/booking_requests/widgets/month_cell_order_count_widget.dart';
import 'package:demandium_provider/feature/booking_requests/widgets/time_cell_order_count_widget.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';


class CalendarOrderScreen extends StatefulWidget {
  const CalendarOrderScreen({super.key});

  @override
  State<CalendarOrderScreen> createState() => _CalendarOrderScreenState();
}

class _CalendarOrderScreenState extends State<CalendarOrderScreen> {
  @override
  void initState() {
    super.initState();
    final controller = Get.find<BookingCalendarController>();
    
    // Reset to initial state (month view, current date)
    controller.resetToInitialState();
    Get.find<CalenderOrderFilterController>().resetFilter();


    controller.loadBookingsForCurrentView();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "booking_calendar".tr,
        actionWidget: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: GetBuilder<BookingCalendarController>(
            builder: (calendarController) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  CircularIconButtonWidget(
                    icon: Icons.filter_list,
                    showIndicator: calendarController.hasActiveFilters(),
                    onTap: () {
                      showCustomBottomSheet(
                        child: const CalendarFilterBottomSheet(),
                      );
                    },
                  ),

                ],
              );
            },
          ),
        ),
      ),
      body: GetBuilder<BookingCalendarController>(
        builder: (controller) {
          return LoadingOverlayWidget(
            isLoading: controller.isLoading,
            child: Column(
              children: [

                // Active Filters Display
                const ActiveFiltersDisplayWidget(),

                // Calendar Header with Navigation
                const CalenderHeaderWidget(),

                // Calendar View
                Expanded(child: SfCalendar(
                  controller: controller.calendarController,
                  firstDayOfWeek: 1, // Monday
                  minDate: controller.filterStartDate,
                  maxDate: controller.filterEndDate,
                  headerHeight: 0, // Hide the calendar header
                  dataSource: _buildDataSource(controller),
                  onViewChanged: _onCalendarViewChanged,
                  showWeekNumber: true,
                  weekNumberStyle: WeekNumberStyle(backgroundColor: Theme.of(context).cardColor),
                  monthViewSettings: MonthViewSettings(
                    appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                    showAgenda: false,
                    monthCellStyle: MonthCellStyle(
                      textStyle: robotoRegular.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      trailingDatesTextStyle: robotoRegular.copyWith(
                        color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                      ),
                      leadingDatesTextStyle: robotoRegular.copyWith(
                        color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  timeSlotViewSettings: TimeSlotViewSettings(
                    timeFormat: 'h a',
                    timeIntervalHeight: 70,
                    timeTextStyle: robotoRegular.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                  headerStyle: CalendarHeaderStyle(
                    textStyle: robotoBold.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                    backgroundColor: Theme.of(context).cardColor,
                  ),
                  viewHeaderStyle: ViewHeaderStyle(
                    dayTextStyle: robotoMedium.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                    dateTextStyle: robotoRegular.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                  todayHighlightColor: Theme.of(context).primaryColor,
                  selectionDecoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  cellBorderColor: Theme.of(context).hintColor.withValues(alpha: 0.2),
                  onTap: (CalendarTapDetails details) {
                    if (details.targetElement == CalendarElement.calendarCell) {
                      // Month view - tap on cell
                      if (controller.currentViewType == CalendarViewType.month) {
                        _showBookingsForDate(context, details.date!, controller, isForDate: true);
                      }
                    } else if (details.targetElement == CalendarElement.appointment) {
                      // Week/Day view - tap on appointment
                      if (details.appointments != null && details.appointments!.isNotEmpty) {
                        // Show bookings for this time slot
                        if (controller.currentViewType == CalendarViewType.week) {
                          _showBookingsForDate(context, details.date!, controller, isForDate: false);
                        } else if (controller.currentViewType == CalendarViewType.day) {
                          _showBookingsForDate(context, details.date!, controller, isForDate: false);
                        }
                      }
                    }
                  },

                  appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
                    final BookingAppointmentModel appointment = details.appointments.first;
                    return TimeCellOrderCountWidget(
                      appointment: appointment,
                      controller: controller,
                    );
                  },
                  monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                    if (controller.currentViewType == CalendarViewType.month) {
                      int count = controller.getOrderCountForDate(details.date);
                      return MonthCellOrderCountWidget(
                        details: details,
                        count: count,
                      );
                    }
                    return Container();
                  },
                )),
              ],
            ),
          );
        },
      ),
    );
  }



  /// Handle calendar view changes (when user swipes)
  void _onCalendarViewChanged(ViewChangedDetails details) {
    final controller = Get.find<BookingCalendarController>();
    
    // When user swipes, update the selected date and load new data
    if (details.visibleDates.isNotEmpty) {
      // Get the middle date from visible dates to determine the current view
      final DateTime newDate = details.visibleDates[details.visibleDates.length ~/ 2];
      
      // Defer the update to after the current build frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.updateDateIfViewChanged(newDate);
      });
    }
  }




  BookingCalendarDataSource _buildDataSource(BookingCalendarController controller) {
    List<BookingAppointmentModel> appointments = [];

    // Get the appropriate data based on current view type
    List<CalenderData>? calendarDataList;
    
    switch (controller.currentViewType) {
      case CalendarViewType.month:
        calendarDataList = controller.calendarData?.dayGridMonth;
        break;
      case CalendarViewType.week:
        calendarDataList = controller.calendarData?.timeGridWeek;
        break;
      case CalendarViewType.day:
        calendarDataList = controller.calendarData?.timeGridDay;
        break;
    }

    // Create appointments from CalenderData
    if (calendarDataList != null) {
      for (var calenderData in calendarDataList) {
        if (calenderData.count > 0) {

          // For week/day views, create an appointment to show the count
          if (controller.currentViewType == CalendarViewType.week || 
              controller.currentViewType == CalendarViewType.day) {

            // Parse time strings and combine with date
            DateTime? fromDateTime = _addTimeString(calenderData.start, calenderData.startHourTime);
            DateTime toDateTime = _addTimeString(calenderData.end, calenderData.endHourTime);



            appointments.add(
              BookingAppointmentModel(
                eventName: '${calenderData.count}',
                from: fromDateTime,
                to: toDateTime,
                background: Theme.of(context).primaryColor.withValues(alpha: 0.7),
                bookingId: '', // Not a specific booking, represents a group
                bookingStatus: 'group',
              ),
            );
          }
        }
      }
    }

    return BookingCalendarDataSource(appointments);
  }

  DateTime _addTimeString(DateTime dateTime, String? timeString) {
    if(timeString == null) return dateTime ;

    List<String> timeParts = timeString.split(':');
    return dateTime.add(Duration(
      hours: int.parse(timeParts[0]),
      minutes: int.parse(timeParts[1]),
      seconds: int.parse(timeParts[2]),
    ));
  }


  void _showBookingsForDate(BuildContext context, DateTime date, BookingCalendarController controller, {required bool isForDate}) {
    List<CalenderBooking> bookings;
    if(isForDate) {
      bookings = controller.getBookingsForDate(date);

    }else {
      bookings = controller.getBookingsForDateTime(date);
    }


    if (bookings.isEmpty) {
      showCustomSnackBar('no_bookings'.tr);
      return;
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
      ),
      builder: (context) {
        return CalenderOrderListDialogWidget(
          bookings: bookings,
        );
      },
    );
  }

}
