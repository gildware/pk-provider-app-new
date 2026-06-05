import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:demandium_provider/util/core_export.dart';

class BookingCalendarDataSource extends CalendarDataSource {
  BookingCalendarDataSource(List<BookingAppointmentModel> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class BookingAppointmentModel {
  BookingAppointmentModel({
    required this.eventName,
    required this.from,
    required this.to,
    required this.background,
    required this.bookingId,
    required this.bookingStatus,
    this.isAllDay = false,
  });

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  String bookingId;
  String bookingStatus;
  bool isAllDay;
}
