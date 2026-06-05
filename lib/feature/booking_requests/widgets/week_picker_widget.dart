import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/feature/booking_requests/controller/calendar_controller.dart';

/// Builds PopupMenuItems for week selection
/// Returns a list of `PopupMenuItem<DateTime>` for all weeks of the given month
List<PopupMenuItem<DateTime>> buildWeekPickerItems({
  required DateTime currentSelectedDate,
  required BuildContext context,
}) {
  final List<PopupMenuItem<DateTime>> items = [];
  final controller = Get.find<BookingCalendarController>();
  
  // Get the first day of the month
  final firstDayOfMonth = DateTime(currentSelectedDate.year, currentSelectedDate.month, 1);
  final lastDayOfMonth = DateTime(currentSelectedDate.year, currentSelectedDate.month + 1, 0);
  
  // Find the first Monday on or before the first day of the month
  DateTime currentWeekStart = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
  
  // Get the first day of the selected week for comparison
  final selectedWeekStart = currentSelectedDate.subtract(Duration(days: currentSelectedDate.weekday - 1));
  
  while (currentWeekStart.isBefore(lastDayOfMonth.add(const Duration(days: 1)))) {
    final weekEnd = currentWeekStart.add(const Duration(days: 6));
    
    // Only add weeks that overlap with the current month
    if (weekEnd.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
        currentWeekStart.isBefore(lastDayOfMonth.add(const Duration(days: 1)))) {
      
      final isSelected = currentWeekStart.year == selectedWeekStart.year &&
          currentWeekStart.month == selectedWeekStart.month &&
          currentWeekStart.day == selectedWeekStart.day;

      final isDisabled = controller.isPeriodDisabled(
        currentWeekStart,
        DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59),
      );
      
      // Format week range
      String weekLabel;
      if (currentWeekStart.month == weekEnd.month) {
        // Same month: "Jan 1-7"
        String monthAbbrev = DateConverter.dateStringMonthYear(currentWeekStart, format: 'MMM');
        weekLabel = '$monthAbbrev ${currentWeekStart.day}-${weekEnd.day}';
      } else {
        // Different months: "Dec 29 - Jan 4"
        String startMonth = DateConverter.dateStringMonthYear(currentWeekStart, format: 'MMM d');
        String endMonth = DateConverter.dateStringMonthYear(weekEnd, format: 'MMM d');
        weekLabel = '$startMonth - $endMonth';
      }
      
      items.add(
        PopupMenuItem<DateTime>(
          value: currentWeekStart,
          padding: EdgeInsets.zero,
          enabled: !isDisabled,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Text(
              weekLabel,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: isDisabled
                    ? Theme.of(context).disabledColor
                    : isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      );
    }
    
    currentWeekStart = currentWeekStart.add(const Duration(days: 7));
  }
  
  return items;
}
