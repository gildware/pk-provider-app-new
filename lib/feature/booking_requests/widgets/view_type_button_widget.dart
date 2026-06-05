import 'package:demandium_provider/feature/booking_requests/controller/calendar_controller.dart';
import 'package:demandium_provider/util/core_export.dart';

class ViewTypeButtonWidget extends StatelessWidget {
  final String label;
  final CalendarViewType viewType;
  final BookingCalendarController controller;

  const ViewTypeButtonWidget({
    super.key,
    required this.label,
    required this.viewType,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = controller.currentViewType == viewType;
    return InkWell(
      onTap: () => controller.changeViewType(viewType),
      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).hintColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: robotoMedium.copyWith(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
        ),
      ),
    );
  }
}
