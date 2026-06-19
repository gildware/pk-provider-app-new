import 'package:demandium_provider/helper/booking_status_variant_colors.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BookingStatusButtonWidget extends StatelessWidget {
  final String? bookingStatus;
  final String? displayKey;
  final String? badgeVariant;

  const BookingStatusButtonWidget({
    super.key,
    this.bookingStatus,
    this.displayKey,
    this.badgeVariant,
  });

  String get _labelKey {
    if (displayKey != null && displayKey!.isNotEmpty) {
      return displayKey!;
    }
    return bookingStatus ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (_labelKey.isEmpty) {
      return const SizedBox.shrink();
    }

    final variant = BookingStatusVariantColors.resolveBadgeVariant(
      badgeVariant: badgeVariant,
      rawStatus: bookingStatus,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: BookingStatusVariantColors.softBadgeBackground(variant),
      ),
      child: Text(
        _labelKey.tr,
        style: robotoRegular.copyWith(
          color: BookingStatusVariantColors.softBadgeForeground(variant),
          fontSize: Dimensions.fontSizeSmall,
        ),
      ),
    );
  }
}
