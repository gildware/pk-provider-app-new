import 'package:demandium_provider/feature/booking_requests/controller/calendar_controller.dart';
import 'package:demandium_provider/feature/booking_requests/model/booking_appointment_model.dart';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/util/core_export.dart';

class TimeCellOrderCountWidget extends StatelessWidget {
  final BookingAppointmentModel appointment;
  final BookingCalendarController controller;

  const TimeCellOrderCountWidget({
    super.key,
    required this.appointment,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: context.customThemeColors.warning.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          int.tryParse(appointment.eventName).toString().padLeft(2, '0'),
          style: robotoMedium.copyWith(
            color: Colors.black,
            fontSize: Dimensions.fontSizeDefault,
          ),
        ),
      ),
    );
  }
}
