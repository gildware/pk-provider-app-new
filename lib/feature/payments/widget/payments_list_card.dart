import 'package:get/get.dart';
import 'package:demandium_provider/feature/payments/controller/payments_controller.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:intl/intl.dart';

class PaymentsListCard extends StatelessWidget {
  final ProviderPaymentSubTab subTab;
  final Map<String, dynamic> item;
  const PaymentsListCard({super.key, required this.subTab, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2)),
      ),
      child: switch (subTab) {
        ProviderPaymentSubTab.ledger => _ledgerCard(context),
        ProviderPaymentSubTab.recorded => _recordedCard(context),
        ProviderPaymentSubTab.earning => _earningCard(context, special: false),
        ProviderPaymentSubTab.specialEarning => _earningCard(context, special: true),
        ProviderPaymentSubTab.disputed => _disputedCard(context),
      },
    );
  }

  Widget _ledgerCard(BuildContext context) {
    final isIn = item['type']?.toString() == 'in';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerRow(
          context,
          title: item['readable_id']?.toString() ?? '—',
          amount: _amount(item['amount']),
          amountColor: isIn ? Colors.green : Theme.of(context).colorScheme.error,
        ),
        _row(context, 'date'.tr, _formatDate(item['date'])),
        _row(context, 'type'.tr, isIn ? 'in'.tr : 'out'.tr),
        _row(context, 'payment_type'.tr, item['counterparty_flow_label']?.toString()),
        _row(context, 'payment_method'.tr, item['payment_method']?.toString()),
        if ((item['transaction_id']?.toString() ?? '').isNotEmpty)
          _row(context, 'transaction_id'.tr, item['transaction_id']?.toString()),
        if ((item['reference']?.toString() ?? '').isNotEmpty)
          _row(context, 'reference'.tr, item['reference']?.toString()),
        if ((item['repeat_readable_id']?.toString() ?? '').isNotEmpty)
          _row(context, 'repeat'.tr, item['repeat_readable_id']?.toString()),
        _row(context, 'entry_by'.tr, item['entry_by']?.toString()),
      ],
    );
  }

  Widget _recordedCard(BuildContext context) {
    final providerFlow = item['provider_flow']?.toString() ?? _providerFlowFromCompanyFlow(item['company_flow']?.toString());
    final isIn = providerFlow == 'in';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerRow(
          context,
          title: item['readable_id']?.toString() ?? '—',
          amount: _amount(item['amount']),
          amountColor: isIn ? Colors.green : Theme.of(context).colorScheme.error,
        ),
        _row(context, 'date'.tr, _formatDate(item['date'])),
        _row(context, 'type'.tr, _providerFlowLabel(providerFlow)),
        _row(context, 'payment_type'.tr, item['counterparty_flow_label']?.toString()),
        _row(context, 'channel'.tr, item['channel']?.toString()),
        if ((item['transaction_id']?.toString() ?? '').isNotEmpty)
          _row(context, 'transaction_id'.tr, item['transaction_id']?.toString()),
      ],
    );
  }

  Widget _earningCard(BuildContext context, {required bool special}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerRow(
          context,
          title: item['readable_id']?.toString() ?? '—',
          amount: _amount(item['total_amount']),
        ),
        _row(context, 'provider_earning'.tr, _amount(item['provider_earning'])),
        _row(context, 'admin_commission'.tr, _amount(item['admin_commission'])),
        if (!special) ...[
          _row(context, 'service_charges'.tr, _amount(item['service_charges'])),
          _row(context, 'extra_service_charges'.tr, _amount(item['extra_service_charges'])),
          _row(context, 'parts_charges'.tr, _amount(item['parts_charges'])),
        ] else ...[
          _row(context, 'visiting_charges'.tr, _amount(item['visiting_charges'])),
          _row(context, 'closing_amount'.tr, _amount(item['closing_amount'])),
          if (item['scaled_loss_making_split'] == true) ...[
            _row(context, 'company_loss_absorbed_line'.tr, _amount(item['scaled_company_loss_line'])),
            _row(context, 'provider_loss_absorbed_line'.tr, _amount(item['scaled_provider_loss_line'])),
          ],
        ],
        _row(context, 'earning_report_received_by_company'.tr, _amount(item['amount_received_by_company'])),
        _row(context, 'earning_report_received_by_provider'.tr, _amount(item['amount_received_by_provider'])),
        _row(context, 'earning_report_provider_owes_company'.tr, _amount(item['provider_owes_company'])),
        _row(context, 'earning_report_company_owes_provider'.tr, _amount(item['company_owes_provider'])),
        if ((item['booking_id']?.toString() ?? '').isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Get.toNamed(
                RouteHelper.getBookingDetailsRoute(bookingId: item['booking_id']?.toString(), fromPage: 'payments'),
              ),
              child: Text('view_booking'.tr),
            ),
          ),
      ],
    );
  }

  Widget _disputedCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerRow(
          context,
          title: item['readable_id']?.toString() ?? '—',
          amount: _amount(item['total_booking_amount']),
        ),
        _row(context, 'status'.tr, item['booking_status']?.toString().replaceAll('_', ' ')),
        _row(context, 'refund_paid_from_company_pool'.tr, _amount(item['refund_company_amount'])),
        _row(context, 'refund_paid_from_provider_pool'.tr, _amount(item['refund_provider_amount'])),
        _row(context, 'provider_owes_company_refund_above_pool'.tr, _amount(item['provider_owes_company'])),
        _row(context, 'company_owes_provider_refund_above_pool'.tr, _amount(item['company_owes_provider'])),
        _row(context, 'final_amount_retained_from_customer_after_refunds'.tr, _amount(item['retained_from_customer'])),
        _row(context, 'final_admin_commission_net_basis'.tr, _amount(item['final_admin_commission'])),
        _row(context, 'final_provider_earning_net_basis'.tr, _amount(item['final_provider_earning'])),
        _row(context, 'disputed_recorded_at'.tr, _formatDate(item['disputed_at'])),
        if ((item['booking_id']?.toString() ?? '').isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Get.toNamed(
                RouteHelper.getBookingDetailsRoute(bookingId: item['booking_id']?.toString(), fromPage: 'payments'),
              ),
              child: Text('view_booking'.tr),
            ),
          ),
      ],
    );
  }

  Widget _headerRow(BuildContext context, {required String title, required String amount, Color? amountColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              textAlign: TextAlign.start,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              amount,
              textAlign: TextAlign.start,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: amountColor ?? Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Label in the left column, value in the right column; both left-aligned.
  Widget _row(BuildContext context, String label, String? value, {TextStyle? valueStyle}) {
    if (value == null || value.isEmpty || value == '—') return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              textAlign: TextAlign.start,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.75),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.start,
              style: valueStyle ??
                  robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _amount(dynamic value) => PriceConverter.convertPrice(_toDouble(value));

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  String _formatDate(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) return '—';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return raw.toString();
    }
  }

  String _providerFlowFromCompanyFlow(String? companyFlow) => switch (companyFlow) {
        'in' => 'out',
        'out' => 'in',
        'none' => 'none',
        _ => 'unknown',
      };

  String _providerFlowLabel(String? key) => switch (key) {
        'in' => 'provider_money_flow_in'.tr,
        'out' => 'provider_money_flow_out'.tr,
        'none' => 'provider_money_flow_none'.tr,
        _ => key ?? '—',
      };
}
