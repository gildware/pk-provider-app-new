import 'package:demandium_provider/common/widgets/booking_status_tags_widget.dart';
import 'package:demandium_provider/feature/reporting/model/booking_report_model.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BookingReportListView extends StatelessWidget {
  final List<BookingFilterData> bookingFilterData;
  final bool isLoading;
  final String? selectedBookingStatus;
  final Future<void> Function(String value) onStatusChanged;

  const BookingReportListView({
    super.key,
    required this.bookingFilterData,
    required this.isLoading,
    required this.selectedBookingStatus,
    required this.onStatusChanged,
  });

  static const List<String> _bookingStatus = [
    'all',
    'pending',
    'accepted',
    'ongoing',
    'on_hold',
    'completed',
    'canceled',
    'refunded',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeExtraSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('booking_list'.tr, style: robotoMedium),
              PopupMenuButton<String>(
                onSelected: onStatusChanged,
                itemBuilder: (BuildContext context) {
                  return _bookingStatus.map((String value) {
                    return PopupMenuItem<String>(
                      value: value,
                      child: Text(
                        value.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusExtraLarge),
                    border: Border.all(
                      color: (Theme.of(context).textTheme.bodyMedium?.color ??
                              Theme.of(context).hintColor)
                          .withValues(alpha: 0.4),
                      width: 0.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: Dimensions.paddingSizeExtraSmall - 2,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        selectedBookingStatus?.tr ?? 'all'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down_outlined,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (bookingFilterData.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookingFilterData.length,
            itemBuilder: (context, index) {
              return BookingReportListItem(
                bookingFilterData: bookingFilterData[index],
              );
            },
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeLarge,
              horizontal: Dimensions.paddingSizeDefault,
            ),
            child: Center(
              child: Text(
                'no_data_found'.tr,
                style: robotoRegular.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

class BookingReportListItem extends StatelessWidget {
  final BookingFilterData bookingFilterData;
  const BookingReportListItem({super.key, required this.bookingFilterData});

  String get _customerName {
    final first = bookingFilterData.customer?.firstName ?? '';
    final last = bookingFilterData.customer?.lastName ?? '';
    return '$first $last'.trim();
  }

  String? get _serviceAddressText {
    final address = bookingFilterData.serviceAddress?.address?.trim();
    if (address != null && address.isNotEmpty) {
      return address;
    }
    return null;
  }

  String _formatBookingDate(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) {
      return '-';
    }
    final parsed = DateTime.tryParse(createdAt);
    if (parsed == null) {
      return createdAt;
    }
    return DateConverter.dateMonthYearLocalTime(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeExtraSmall,
        horizontal: Dimensions.paddingSizeDefault,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).hintColor.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'booking_id'.tr,
                            style: robotoMedium.copyWith(
                              color: context.adaptivePrimaryColor,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              ' #${bookingFilterData.readableId ?? '-'}',
                              style: robotoMedium.copyWith(
                                color: context.adaptivePrimaryColor,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Align(
                        alignment: Alignment.centerRight,
                        child: BookingStatusAndTagsRow(
                          rawStatus: bookingFilterData.bookingStatus,
                          ui: bookingFilterData.statusUi,
                          alignment: MainAxisAlignment.end,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Row(
                    children: [
                      Text(
                        '${'booking_date'.tr} : ',
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: Dimensions.fontSizeExtraSmall,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          _formatBookingDate(bookingFilterData.createdAt),
                          style: robotoMedium.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeExtraSmall,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (_customerName.isNotEmpty) ...[
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      'customer'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    Text(
                      _customerName,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withValues(alpha: 0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (_serviceAddressText != null) ...[
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      'service_address'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    Text(
                      _serviceAddressText!,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withValues(alpha: 0.8),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeDefault,
                right: Dimensions.paddingSizeDefault,
                bottom: Dimensions.paddingSizeDefault,
              ),
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: context.adaptivePrimaryColor.withValues(alpha: 0.05),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${'total_booking_amount'.tr} (${bookingFilterData.isPaid == 1 ? 'paid'.tr : 'unpaid'.tr})',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    Text(
                      PriceConverter.convertPrice(
                        bookingFilterData.totalBookingAmount ?? 0,
                      ),
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: context.adaptivePrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
