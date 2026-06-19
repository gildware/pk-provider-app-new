import 'package:demandium_provider/feature/booking_requests/model/booking_count.dart';
import 'package:demandium_provider/feature/booking_requests/widgets/booking_filter_tab_chip.dart';
import 'package:demandium_provider/util/core_export.dart';

class BookingRequestMenuItem extends StatelessWidget {
  const BookingRequestMenuItem({
    super.key,
    required this.title,
    required this.isSelected,
    required this.bookingCount,
  });

  final String title;
  final bool isSelected;
  final BookingCount? bookingCount;

  @override
  Widget build(BuildContext context) {
    return BookingFilterTabChip(
      tab: title,
      isSelected: isSelected,
      bookingCount: bookingCount,
    );
  }
}
