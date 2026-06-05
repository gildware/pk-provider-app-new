import 'package:demandium_provider/feature/booking_requests/controller/calendar_controller.dart';
import 'package:demandium_provider/feature/booking_requests/controller/calender_order_filter_controller.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class CalendarFilterBottomSheet extends StatefulWidget {
  const CalendarFilterBottomSheet({super.key});

  @override
  State<CalendarFilterBottomSheet> createState() => _CalendarFilterBottomSheetState();
}

class _CalendarFilterBottomSheetState extends State<CalendarFilterBottomSheet> {

  @override
  void initState() {
    Get.find<CalenderOrderFilterController>().initFilterState(Get.find<BookingCalendarController>().calendarData!);

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return GetBuilder<CalenderOrderFilterController>(
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Dimensions.radiusDefault),
              topRight: Radius.circular(Dimensions.radiusDefault),
            ),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Flexible(child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Title
                  Center(
                    child: Text(
                      'filter'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // Booking Type Section
                  FilterSectionContainer(
                    title: 'booking_type'.tr,
                    child: BookingTypeOptionsWidget(controller: controller),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // Date Range Section
                  FilterSectionContainer(
                    title: 'date_range'.tr,
                    child: DateRangeSelectorWidget(controller: controller),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // Booking Status Section
                  FilterSectionContainer(
                    title: 'Booking_Status'.tr,
                    child: BookingStatusCheckboxesWidget(controller: controller),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),


                ],
              ),
            )),

            // Action Buttons
            Row(children: [
              Expanded(child: CustomButton(
                btnTxt: 'reset'.tr,
                height: 45,
                radius: Dimensions.radiusDefault,
                color: Theme.of(context).hintColor.withValues(alpha: 0.1),
                textColor: Theme.of(context).textTheme.bodyLarge?.color,
                onPressed: () {
                  Get.back();
                  controller.resetFilter();
                },
              )),
              const SizedBox(width: Dimensions.paddingSizeDefault),

              Expanded(child: CustomButton(
                radius: Dimensions.radiusDefault,
                btnTxt: 'apply'.tr,
                height: 45,
                onPressed: () {
                  Get.back();
                  controller.applyFilter();
                },
              )),
            ]),
          ]),
        );
      },
    );
  }
}

// ========== Widget Classes ==========

/// Reusable container for filter sections with consistent styling
class FilterSectionContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const FilterSectionContainer({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          child,
        ],
      ),
    );
  }
}

class BookingTypeOptionsWidget extends StatelessWidget {
  final CalenderOrderFilterController controller;

  const BookingTypeOptionsWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: size.width,
          child: RadioGroup<ServiceType>(
            groupValue: controller.selectedBookingType,
            onChanged: (value) {
              if (value != null) {
                controller.setBookingType(value);
              }
            },
            child: Row(
              children: ServiceType.values.map((serviceType) {
                return InkWell(
                  onTap: () => controller.setBookingType(serviceType),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<ServiceType>(
                        value: serviceType,
                        activeColor: Theme.of(context).primaryColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),

                      Text(
                        serviceType.translationKey.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: controller.selectedBookingType == serviceType
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Theme.of(context).hintColor,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeLarge),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class DateRangeSelectorWidget extends StatelessWidget {
  final CalenderOrderFilterController controller;

  const DateRangeSelectorWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final dateRangeText = DateConverter.formatDateRangeText(
      startDate: controller.startDate,
      endDate: controller.endDate,
      fallbackText: 'select_date_range'.tr,
    );


    return InkWell(
      onTap: () => _showDateRangePicker(context),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: Theme.of(context).hintColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                dateRangeText,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: (controller.startDate != null || controller.endDate != null)
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Theme.of(context).hintColor,
                ),
              ),
            ),
            Icon(
              Icons.calendar_month_outlined,
              size: 20,
              color: Theme.of(context).hintColor,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: controller.startDate != null && controller.endDate != null
          ? DateTimeRange(start: controller.startDate!, end: controller.endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Theme.of(context).primaryColor,
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setDateRange(picked.start, picked.end);
    }
  }
}

class BookingStatusCheckboxesWidget extends StatelessWidget {
  final CalenderOrderFilterController controller;

  const BookingStatusCheckboxesWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).hintColor.withValues(alpha: 0.2),
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3.5,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
        ),
        itemCount: BookingStatusEnum.values.length,
        itemBuilder: (context, index) {
          final status = BookingStatusEnum.values[index];
          return CheckboxItemWidget(
            controller: controller,
            status: status,
          );
        },
      ),
    );
  }
}

class CheckboxItemWidget extends StatelessWidget {
  final CalenderOrderFilterController controller;
  final BookingStatusEnum status;

  const CheckboxItemWidget({
    super.key,
    required this.controller,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = controller.isStatusSelected(status);
    return InkWell(
      onTap: () => controller.toggleBookingStatus(status),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (checked) {
              controller.toggleBookingStatus(status);
            },
            activeColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: WidgetStateBorderSide.resolveWith((states) => BorderSide(
              width: 1,
              color: states.contains(WidgetState.selected)
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            )),
          ),
          Expanded(
            child: Text(
              status.translationKey.tr,
              style: isSelected ? robotoMedium : robotoRegular,
            ),
          ),
        ],
      ),
    );
  }
}
