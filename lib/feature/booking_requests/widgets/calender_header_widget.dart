import 'package:demandium_provider/feature/booking_requests/controller/calendar_controller.dart';
import 'package:demandium_provider/feature/booking_requests/widgets/day_picker_widget.dart';
import 'package:demandium_provider/feature/booking_requests/widgets/month_picker_widget.dart';
import 'package:demandium_provider/feature/booking_requests/widgets/week_picker_widget.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class CalenderHeaderWidget extends StatelessWidget {
  const CalenderHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingCalendarController>(builder: (controller) {
      return Container(
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Get.isDarkMode
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                  : Theme.of(context).hintColor.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: Dimensions.paddingSizeDefault),

            // Previous Button
            Opacity(
              opacity: controller.canNavigatePrevious() ? 1.0 : 0.3,
              child:  Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  onTap: controller.canNavigatePrevious()
                      ? ()=> controller.navigatePrevious()
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: Dimensions.paddingSizeLarge,
                    ),
                  ),
                ),
              ),
            ),

            // Next Button
            Opacity(
              opacity: controller.canNavigateNext() ? 1.0 : 0.3,
              child:  Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  onTap: controller.canNavigateNext()
                      ? () => controller.navigateNext()
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: Dimensions.paddingSizeLarge,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: Dimensions.paddingSizeSmall),

            // Date Range Display with Pickers
            Expanded(
              child: Center(
                child: _buildDateRangeSelector(context),
              ),
            ),


            // Three-dot Menu
            PopupMenuButton<CalendarViewType>(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              onSelected: (CalendarViewType viewType) {
                controller.changeViewType(viewType);
              },
              offset: Offset(0, 45),
              itemBuilder: (BuildContext context) => [
                _buildPopupMenuItem(
                  context: context,
                  icon: Icons.calendar_month,
                  label: 'month'.tr,
                  value: CalendarViewType.month,
                ),
                _buildPopupMenuItem(
                  context: context,
                  icon: Icons.view_week,
                  label: 'week'.tr,
                  value: CalendarViewType.week,
                ),
                _buildPopupMenuItem(
                  context: context,
                  icon: Icons.calendar_today,
                  label: 'day'.tr,
                  value: CalendarViewType.day,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNavigationButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Icon(
            icon,
            size: Dimensions.paddingSizeLarge,
            color: onTap != null
                ? Theme.of(context).textTheme.bodyLarge?.color
                : Theme.of(context).disabledColor,
          ),
        ),
      ),
    );
  }

  /// Build date range selector with popup menu based on view type
  Widget _buildDateRangeSelector(BuildContext context) {
    final controller = Get.find<BookingCalendarController>();
    
    return PopupMenuButton<DateTime>(
      onSelected: (DateTime selectedDate) {
        switch (controller.currentViewType) {
          case CalendarViewType.month:
            controller.navigateToMonth(selectedDate);
            break;
          case CalendarViewType.week:
            controller.navigateToWeek(selectedDate);
            break;
          case CalendarViewType.day:
            controller.navigateToDay(selectedDate);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        switch (controller.currentViewType) {
          case CalendarViewType.month:
            return buildMonthPickerItems(
              currentSelectedDate: controller.selectedDate,
              context: context,
            );
          case CalendarViewType.week:
            return buildWeekPickerItems(
              currentSelectedDate: controller.selectedDate,
              context: context,
            );
          case CalendarViewType.day:
            return buildDayPickerItems(
              currentSelectedDate: controller.selectedDate,
              context: context,
            );
        }
      },
      offset: const Offset(0, 40),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2)),
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: Dimensions.paddingSizeExtraSmall,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.getFormattedDateRange(),
              style: robotoRegular.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: Dimensions.fontSizeLarge,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  /// Build popup menu item with icon and label
  PopupMenuItem<CalendarViewType> _buildPopupMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required CalendarViewType value,
  }) {
    final controller = Get.find<BookingCalendarController>();
    final bool isSelected = controller.currentViewType == value;
    final Color color = isSelected
        ? Theme.of(context).primaryColor
        : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return PopupMenuItem<CalendarViewType>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Text(
            label,
            style: robotoMedium.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
