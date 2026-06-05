import 'package:demandium_provider/common/model/booking_status_ui_model.dart';
import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

Color bookingStatusTagBackgroundColor(BuildContext context, String variant) {
  final colors = context.customThemeColors;
  return switch (variant) {
    'success' => colors.success.withValues(alpha: 0.15),
    'danger' => colors.error.withValues(alpha: 0.15),
    'warning' || 'warning_dark' => colors.warning.withValues(alpha: 0.2),
    'info' => colors.info.withValues(alpha: 0.15),
    'primary' => Theme.of(context).primaryColor.withValues(alpha: 0.12),
    'secondary' => Theme.of(context).hintColor.withValues(alpha: 0.2),
    'light' => Theme.of(context).cardColor,
    'dark' => Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.12),
    _ => Theme.of(context).primaryColor.withValues(alpha: 0.1),
  };
}

Color bookingStatusTagTextColor(BuildContext context, String variant) {
  final colors = context.customThemeColors;
  return switch (variant) {
    'success' => colors.success,
    'danger' => colors.error,
    'warning' || 'warning_dark' => colors.warning,
    'info' => colors.info,
    'primary' => Theme.of(context).primaryColor,
    'secondary' => Theme.of(context).hintColor,
    'light' => Theme.of(context).textTheme.bodyLarge!.color!,
    'dark' => Theme.of(context).textTheme.bodyLarge!.color!,
    _ => Theme.of(context).primaryColor,
  };
}

Color bookingStatusBadgeBackgroundColor(
  BuildContext context, {
  required String? rawStatus,
  required String? badgeVariant,
}) {
  if (badgeVariant != null && badgeVariant.isNotEmpty) {
    return bookingStatusTagBackgroundColor(context, badgeVariant);
  }
  return context.customThemeColors.buttonBackgroundColorMap[rawStatus]
          ?.withValues(alpha: 0.12) ??
      Theme.of(context).primaryColor.withValues(alpha: 0.1);
}

Color bookingStatusBadgeTextColor(
  BuildContext context, {
  required String? rawStatus,
  required String? badgeVariant,
}) {
  if (badgeVariant != null && badgeVariant.isNotEmpty) {
    return bookingStatusTagTextColor(context, badgeVariant);
  }
  return context.customThemeColors.buttonTextColorMap[rawStatus] ??
      Theme.of(context).primaryColor;
}

class BookingStatusBadge extends StatelessWidget {
  final String? rawStatus;
  final String? displayKey;
  final String? badgeVariant;

  const BookingStatusBadge({
    super.key,
    required this.rawStatus,
    this.displayKey,
    this.badgeVariant,
  });

  String get _labelKey {
    if (displayKey != null && displayKey!.isNotEmpty) {
      return displayKey!;
    }
    return rawStatus ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (_labelKey.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      decoration: BoxDecoration(
        color: bookingStatusBadgeBackgroundColor(
          context,
          rawStatus: rawStatus,
          badgeVariant: badgeVariant,
        ),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Text(
        _labelKey.tr,
        style: robotoMedium.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: bookingStatusBadgeTextColor(
            context,
            rawStatus: rawStatus,
            badgeVariant: badgeVariant,
          ),
        ),
      ),
    );
  }
}

class BookingStatusTagsWrap extends StatelessWidget {
  final List<BookingStatusTag> tags;
  final double spacing;
  final double runSpacing;

  const BookingStatusTagsWrap({
    super.key,
    required this.tags,
    this.spacing = Dimensions.paddingSizeExtraSmall,
    this.runSpacing = Dimensions.paddingSizeExtraSmall,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeExtraSmall,
              ),
              decoration: BoxDecoration(
                color: bookingStatusTagBackgroundColor(context, tag.variant),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Text(
                tag.label.tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: bookingStatusTagTextColor(context, tag.variant),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class BookingStatusAndTagsRow extends StatelessWidget {
  final String? rawStatus;
  final BookingStatusUiFields? ui;
  final MainAxisAlignment alignment;

  const BookingStatusAndTagsRow({
    super.key,
    required this.rawStatus,
    this.ui,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment == MainAxisAlignment.end
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        BookingStatusBadge(
          rawStatus: rawStatus,
          displayKey: ui?.displayKey,
          badgeVariant: ui?.badgeVariant,
        ),
        if (ui != null && ui!.tags.isNotEmpty) ...[
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          BookingStatusTagsWrap(tags: ui!.tags),
        ],
      ],
    );
  }
}
