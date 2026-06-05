import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/feature/booking_requests/controller/calendar_controller.dart';

/// Builds PopupMenuItems for day selection
/// Returns a list of `PopupMenuItem<DateTime>` for all 7 days of the current week
List<PopupMenuItem<DateTime>> buildDayPickerItems({
  required DateTime currentSelectedDate,
  required BuildContext context,
}) {
  final List<PopupMenuItem<DateTime>> items = [];
  final controller = Get.find<BookingCalendarController>();
  
  // Get the first day of the week (Monday)
  final firstDayOfWeek = currentSelectedDate.subtract(
    Duration(days: currentSelectedDate.weekday - 1),
  );
  
  // Generate all 7 days of the week
  for (int i = 0; i < 7; i++) {
    final dayDate = firstDayOfWeek.add(Duration(days: i));
    
    final isSelected = dayDate.year == currentSelectedDate.year &&
        dayDate.month == currentSelectedDate.month &&
        dayDate.day == currentSelectedDate.day;

    final isDisabled = controller.isPeriodDisabled(
      dayDate,
      DateTime(dayDate.year, dayDate.month, dayDate.day, 23, 59, 59),
    );
    
    // Format: "Mon, Jan 14"
    final dayLabel = DateConverter.dateStringMonthYear(dayDate, format: 'EEE, MMM d');
    items.add(
      PopupMenuItem<DateTime>(
        value: dayDate,
        padding: EdgeInsets.zero,
        enabled: !isDisabled,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Text(
            dayLabel,
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
  
  return items;
}
