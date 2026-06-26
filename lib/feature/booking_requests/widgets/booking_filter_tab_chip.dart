import 'package:demandium_provider/feature/booking_requests/model/booking_count.dart';
import 'package:demandium_provider/helper/booking_list_filter_tabs.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BookingFilterTabChip extends StatelessWidget {
  final String tab;
  final bool isSelected;
  final BookingCount? bookingCount;

  const BookingFilterTabChip({
    super.key,
    required this.tab,
    required this.isSelected,
    this.bookingCount,
  });

  int get _count => bookingCount?.countForTab(tab) ?? 0;

  @override
  Widget build(BuildContext context) {
    final selectedBackground = Theme.of(context).primaryColor;
    final selectedForeground = Colors.white;
    final iconColor = isSelected
        ? selectedForeground
        : context.adaptivePrimaryColor.withValues(alpha: 0.75);
    final textColor = isSelected
        ? selectedForeground
        : context.tabUnselectedColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? selectedBackground
            : Get.isDarkMode
                ? Colors.grey.withValues(alpha: 0.2)
                : Theme.of(context).primaryColor.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(bookingListFilterTabIcon(tab), size: 15, color: iconColor),
          const SizedBox(width: 5),
          Text(
            bookingListFilterTabLabelKey(tab).tr,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: textColor,
            ),
          ),
          const SizedBox(width: 6),
          _TabCountBadge(count: _count, isSelected: isSelected),
        ],
      ),
    );
  }
}

class _TabCountBadge extends StatelessWidget {
  final int count;
  final bool isSelected;

  const _TabCountBadge({required this.count, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? Colors.white.withValues(alpha: 0.25)
            : Theme.of(context).cardColor.withValues(alpha: 0.9),
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: robotoMedium.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall,
          color: isSelected
              ? Colors.white
              : Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}
