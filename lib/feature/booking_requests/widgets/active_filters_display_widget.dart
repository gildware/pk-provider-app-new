import 'package:demandium_provider/common/widgets/circular_icon_button_widget.dart';
import 'package:demandium_provider/feature/booking_requests/controller/calendar_controller.dart';
import 'package:demandium_provider/feature/booking_requests/controller/calender_order_filter_controller.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

/// Widget to display active filters as chips with individual clear buttons
class ActiveFiltersDisplayWidget extends StatelessWidget {
  const ActiveFiltersDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final filterController = Get.find<CalenderOrderFilterController>();

    return GetBuilder<BookingCalendarController>(
      builder: (calendarController) {
        final calendarData = calendarController.calendarData;
        
        // Only show when there are active filters in the model
        if (calendarData == null || !_hasActiveFilters(calendarData)) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                // Date Range Filter Chip
                if (calendarData.filterStartDate != null || calendarData.filterEndDate != null)
                  _FilterChip(
                    label: '${'date'.tr} : ',
                    value: DateConverter.formatDateRangeText(startDate: calendarData.filterStartDate, endDate: calendarData.filterEndDate),
                    onClear: () => filterController.clearDateFilter(),
                  ),

                // Booking Type Filter Chip
                if (calendarData.bookingType != null && calendarData.bookingType != ServiceType.all)
                  _FilterChip(
                    label: '${'booking_type'.tr} : ',
                    value: calendarData.bookingType!.translationKey.tr,
                    onClear: () => filterController.clearBookingTypeFilter(),
                  ),

                // Booking Status Filter Chips
                if (calendarData.bookingStatus != null)
                  ...calendarData.bookingStatus!.map((status) {
                    return _FilterChip(
                      value: status.translationKey.tr,
                      onClear: () => filterController.clearStatusFilter(status),
                    );
                  }),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  /// Check if there are any active filters in the model
  bool _hasActiveFilters(CalenderOrderModel calendarData) {
    return (calendarData.filterStartDate != null || calendarData.filterEndDate != null) ||
        (calendarData.bookingType != null && calendarData.bookingType != ServiceType.all) ||
        (calendarData.bookingStatus != null && calendarData.bookingStatus!.isNotEmpty);
  }

}

/// Private widget class for individual filter chip with clear button
class _FilterChip extends StatelessWidget {
  final String? label;
  final String value;
  final VoidCallback onClear;

  const _FilterChip({
    this.label,
    required this.value,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeEight,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),

        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filter label
         if(label != null) Text(
            label!,
            style: robotoRegular.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
          
          Text(
            value,
            style: robotoBold.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeEight),
          
          // Clear button
          CircularIconButtonWidget(
            icon: Icons.clear,
            iconSize: Dimensions.paddingSizeDefault,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            onTap: onClear,
          ),
        ],
      ),
    );
  }
}
