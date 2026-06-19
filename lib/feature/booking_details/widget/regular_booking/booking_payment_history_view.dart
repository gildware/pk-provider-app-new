import 'package:demandium_provider/feature/booking_details/model/bookings_details_model.dart';
import 'package:demandium_provider/feature/booking_details/widget/regular_booking/booking_overview_kv_row.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BookingPaymentHistoryView extends StatelessWidget {
  final BookingDetailsContent bookingDetails;

  const BookingPaymentHistoryView({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    var ledger = bookingDetails.paymentLedger;
    var installments = ledger?.installments ?? [];
    final refunds = ledger?.refunds ?? [];

    if (installments.isEmpty) {
      final fallbackLedger = bookingDetails.buildPaymentLedgerFallback();
      if (fallbackLedger != null) {
        ledger = fallbackLedger;
        installments = fallbackLedger.installments ?? [];
      }
    }

    final sortedInstallments = List<BookingPaymentLedgerEntry>.from(installments)
      ..sort((a, b) => (b.date ?? '').compareTo(a.date ?? ''));
    final sortedRefunds = List<BookingRefundLedgerEntry>.from(refunds)
      ..sort((a, b) => (b.date ?? '').compareTo(a.date ?? ''));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BookingOverviewSectionCard(
          title: 'payment_history'.tr,
          icon: Icons.history,
          child: sortedInstallments.isEmpty
              ? _EmptyLedgerMessage()
              : Column(
                  children: sortedInstallments
                      .map((entry) => _InstallmentLedgerCard(entry: entry))
                      .toList(),
                ),
        ),
        if (sortedRefunds.isNotEmpty)
          BookingOverviewSectionCard(
            title: 'refunds_to_customer'.tr,
            icon: Icons.replay_outlined,
            child: Column(
              children: sortedRefunds
                  .map((entry) => _RefundLedgerCard(entry: entry))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _InstallmentLedgerCard extends StatelessWidget {
  final BookingPaymentLedgerEntry entry;

  const _InstallmentLedgerCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${entry.serial ?? ''}',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  PriceConverter.convertPrice(entry.amount ?? 0, isShowLongPrice: true),
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
              ),
            ],
          ),
          if (entry.date != null) ...[
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            _LedgerDetailRow(
              title: 'date'.tr,
              value: DateConverter.dateMonthYearTime(
                DateConverter.isoUtcStringToLocalDate(entry.date!),
              ),
            ),
          ],
          if (entry.receivedByLabel != null && entry.receivedByLabel!.isNotEmpty)
            _LedgerDetailRow(title: 'received_by'.tr, value: entry.receivedByLabel!),
          if ((entry.dueAfterPayment ?? 0) >= 0)
            _LedgerDetailRow(
              title: 'due_after_this_payment'.tr,
              value: PriceConverter.convertPrice(entry.dueAfterPayment ?? 0, isShowLongPrice: true),
            ),
        ],
      ),
    );
  }
}

class _RefundLedgerCard extends StatelessWidget {
  final BookingRefundLedgerEntry entry;

  const _RefundLedgerCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${entry.serial ?? ''}',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  PriceConverter.convertPrice(entry.amount ?? 0, isShowLongPrice: true),
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          if (entry.date != null) ...[
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            _LedgerDetailRow(
              title: 'date'.tr,
              value: DateConverter.dateMonthYearTime(
                DateConverter.isoUtcStringToLocalDate(entry.date!),
              ),
            ),
          ],
          if (entry.referenceNote != null && entry.referenceNote!.isNotEmpty)
            _LedgerDetailRow(title: 'reference_note'.tr, value: entry.referenceNote!),
        ],
      ),
    );
  }
}

class _LedgerDetailRow extends StatelessWidget {
  final String title;
  final String value;

  const _LedgerDetailRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLedgerMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: Center(
        child: Text(
          'no_data_found'.tr,
          style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
        ),
      ),
    );
  }
}
