class ProviderPaymentsOverview {
  final ProviderPaymentsNetBalance? netBalance;
  final double? totalRevenue;
  final double? providerNetEarning;
  final double? totalCompanyCommission;
  final double? providerLossAbsorbedTotal;
  final double? companyLossAbsorbedTotal;
  final ProviderPaymentsCompensation? compensation;
  final ProviderPaymentsReceipts? receipts;
  final double? customerRefundDueTotal;

  ProviderPaymentsOverview({
    this.netBalance,
    this.totalRevenue,
    this.providerNetEarning,
    this.totalCompanyCommission,
    this.providerLossAbsorbedTotal,
    this.companyLossAbsorbedTotal,
    this.compensation,
    this.receipts,
    this.customerRefundDueTotal,
  });

  factory ProviderPaymentsOverview.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProviderPaymentsOverview();
    return ProviderPaymentsOverview(
      netBalance: json['net_balance'] != null
          ? ProviderPaymentsNetBalance.fromJson(json['net_balance'])
          : null,
      totalRevenue: _toDouble(json['total_revenue']),
      providerNetEarning: _toDouble(json['provider_net_earning']),
      totalCompanyCommission: _toDouble(json['total_company_commission']),
      providerLossAbsorbedTotal: _toDouble(json['provider_loss_absorbed_total']),
      companyLossAbsorbedTotal: _toDouble(json['company_loss_absorbed_total']),
      compensation: json['compensation'] != null
          ? ProviderPaymentsCompensation.fromJson(json['compensation'])
          : null,
      receipts: json['receipts'] != null
          ? ProviderPaymentsReceipts.fromJson(json['receipts'])
          : null,
      customerRefundDueTotal: _toDouble(json['customer_refund_due_total']),
    );
  }
}

class ProviderPaymentsNetBalance {
  final double? amount;
  final String? direction;
  final bool canRequestAmount;
  final double? requestMaxAmount;
  final bool canPay;
  final double? payMaxAmount;

  ProviderPaymentsNetBalance({
    this.amount,
    this.direction,
    this.canRequestAmount = false,
    this.requestMaxAmount,
    this.canPay = false,
    this.payMaxAmount,
  });

  factory ProviderPaymentsNetBalance.fromJson(Map<String, dynamic> json) {
    return ProviderPaymentsNetBalance(
      amount: _toDouble(json['amount']),
      direction: json['direction']?.toString(),
      canRequestAmount: json['can_request_amount'] == true,
      requestMaxAmount: _toDouble(json['request_max_amount']),
      canPay: json['can_pay'] == true,
      payMaxAmount: _toDouble(json['pay_max_amount']),
    );
  }
}

class ProviderPaymentsCompensation {
  final double? providerCompensatedToCustomers;
  final double? companyCompensatedToProvider;

  ProviderPaymentsCompensation({this.providerCompensatedToCustomers, this.companyCompensatedToProvider});

  factory ProviderPaymentsCompensation.fromJson(Map<String, dynamic> json) {
    return ProviderPaymentsCompensation(
      providerCompensatedToCustomers: _toDouble(json['provider_compensated_to_customers']),
      companyCompensatedToProvider: _toDouble(json['company_compensated_to_provider']),
    );
  }
}

class ProviderPaymentsReceipts {
  final double? fromCompany;
  final double? fromCustomer;
  final double? total;

  ProviderPaymentsReceipts({this.fromCompany, this.fromCustomer, this.total});

  factory ProviderPaymentsReceipts.fromJson(Map<String, dynamic> json) {
    return ProviderPaymentsReceipts(
      fromCompany: _toDouble(json['from_company']),
      fromCustomer: _toDouble(json['from_customer']),
      total: _toDouble(json['total']),
    );
  }
}

class ProviderPaymentsListResponse {
  final String? paymentSub;
  final List<Map<String, dynamic>> data;
  final Map<String, dynamic>? totals;
  final int total;
  final int currentPage;
  final int lastPage;

  ProviderPaymentsListResponse({
    this.paymentSub,
    required this.data,
    this.totals,
    this.total = 0,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  factory ProviderPaymentsListResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ProviderPaymentsListResponse(data: []);
    }
    final raw = json['data'];
    final List<Map<String, dynamic>> rows = [];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          rows.add(Map<String, dynamic>.from(item));
        }
      }
    }
    return ProviderPaymentsListResponse(
      paymentSub: json['payment_sub']?.toString(),
      data: rows,
      totals: json['totals'] is Map ? Map<String, dynamic>.from(json['totals']) : null,
      total: int.tryParse('${json['total'] ?? 0}') ?? 0,
      currentPage: int.tryParse('${json['current_page'] ?? 1}') ?? 1,
      lastPage: int.tryParse('${json['last_page'] ?? 1}') ?? 1,
    );
  }
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
