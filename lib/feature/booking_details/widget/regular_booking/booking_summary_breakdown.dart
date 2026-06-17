import 'package:demandium_provider/feature/booking_details/model/bookings_details_model.dart';
import 'package:demandium_provider/helper/booking_helper.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BookingSummaryBreakdown extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final bool showSubTotal;

  const BookingSummaryBreakdown({
    super.key,
    required this.bookingDetails,
    this.showSubTotal = true,
  });

  @override
  Widget build(BuildContext context) {
    final summary = BookingHelper.resolveBookingSummary(bookingDetails);

    return Column(
      children: [
        if (showSubTotal)
          _BookingSummaryAmountRow(
            title: 'sub_total',
            amount: BookingHelper.getDiscountedSubTotal(bookingDetails),
            isBold: true,
          ),
        ..._namedLines(summary.additionalChargeLines),
        if (summary.hasTax == true && (summary.tax ?? 0) > 0)
          _BookingSummaryAmountRow(
            title: 'service_vat',
            amount: summary.tax ?? 0,
            prefix: '(+) ',
          ),
      ],
    );
  }

  List<Widget> _namedLines(List<ProviderBookingSummaryLine>? lines) {
    if (lines == null || lines.isEmpty) {
      return [];
    }

    return lines
        .where((line) => (line.amount ?? 0) > 0)
        .map(
          (line) => _BookingSummaryAmountRow(
            title: BookingHelper.additionalChargeLineLabel(line),
            amount: line.amount ?? 0,
            prefix: '(+) ',
            translateTitle: false,
          ),
        )
        .toList();
  }
}

class BookingSummaryGrandTotal extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final bool showDueAmount;

  const BookingSummaryGrandTotal({
    super.key,
    required this.bookingDetails,
    this.showDueAmount = true,
  });

  @override
  Widget build(BuildContext context) {
    final grandTotal = BookingHelper.resolveGrandTotal(bookingDetails);
    final summary = BookingHelper.resolveBookingSummary(bookingDetails);
    final dueAmount = summary.dueAmount ?? bookingDetails.paymentDetails?.dueBalance ?? 0;
    final grandTotalColor = Get.isDarkMode
        ? Theme.of(context).textTheme.bodyLarge?.color
        : Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        const SizedBox(height: Dimensions.paddingSizeSmall),
        const Divider(height: 2, color: Colors.grey),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'grand_total'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: grandTotalColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                PriceConverter.convertPrice(grandTotal, isShowLongPrice: true),
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: grandTotalColor,
                ),
              ),
            ),
          ],
        ),
        if (showDueAmount && dueAmount > 0)
          Padding(
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'due_amount'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    PriceConverter.convertPrice(dueAmount, isShowLongPrice: true),
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class BookingServicePriceColumn extends StatelessWidget {
  final ItemService? bookingService;
  final TextStyle? style;

  const BookingServicePriceColumn({
    super.key,
    required this.bookingService,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final originalPrice = BookingHelper.getBookingServiceLineSubtotal(bookingService);
    final discountedPrice = BookingHelper.getBookingServiceDiscountedTotal(bookingService);
    final hasDiscount = BookingHelper.bookingServiceHasDiscount(bookingService);
    final defaultStyle = style ??
        robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.9),
        );

    if (!hasDiscount || originalPrice <= discountedPrice) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          PriceConverter.convertPrice(originalPrice, isShowLongPrice: true),
          style: defaultStyle,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            PriceConverter.convertPrice(originalPrice, isShowLongPrice: true),
            style: defaultStyle.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              decoration: TextDecoration.lineThrough,
              color: Theme.of(context).hintColor,
            ),
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            PriceConverter.convertPrice(discountedPrice, isShowLongPrice: true),
            style: defaultStyle,
          ),
        ),
      ],
    );
  }
}

class BookingExtraServicePriceColumn extends StatelessWidget {
  final ProviderExtraServiceLine line;
  final TextStyle? style;

  const BookingExtraServicePriceColumn({
    super.key,
    required this.line,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final originalPrice = BookingHelper.getExtraServiceLineSubtotal(line);
    final discountedPrice = BookingHelper.getExtraServiceLineDiscountedTotal(line);
    final hasDiscount = BookingHelper.extraServiceLineHasDiscount(line);
    final defaultStyle = style ??
        robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.9),
        );

    if (!hasDiscount || originalPrice <= discountedPrice) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          PriceConverter.convertPrice(originalPrice, isShowLongPrice: true),
          style: defaultStyle,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            PriceConverter.convertPrice(originalPrice, isShowLongPrice: true),
            style: defaultStyle.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              decoration: TextDecoration.lineThrough,
              color: Theme.of(context).hintColor,
            ),
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            PriceConverter.convertPrice(discountedPrice, isShowLongPrice: true),
            style: defaultStyle,
          ),
        ),
      ],
    );
  }
}

class _BookingSummaryAmountRow extends StatelessWidget {
  final String title;
  final double amount;
  final String prefix;
  final bool isBold;
  final bool translateTitle;

  const _BookingSummaryAmountRow({
    required this.title,
    required this.amount,
    this.prefix = '',
    this.isBold = false,
    this.translateTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              translateTitle ? title.tr : title,
              style: (isBold ? robotoBold : robotoRegular).copyWith(
                fontSize: isBold ? Dimensions.fontSizeDefault : Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.9),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '$prefix${PriceConverter.convertPrice(amount, isShowLongPrice: true)}',
              style: (isBold ? robotoBold : robotoRegular).copyWith(
                fontSize: isBold ? Dimensions.fontSizeDefault : Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
