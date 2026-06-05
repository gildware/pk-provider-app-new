import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class PaymentsRepo {
  final ApiClient apiClient;
  PaymentsRepo({required this.apiClient});

  Future<Response> getOverview() async {
    return apiClient.getData(AppConstants.providerPaymentsOverviewUri);
  }

  Future<Response> getList({
    required String paymentSub,
    required int offset,
    required int limit,
  }) async {
    return apiClient.getData(
      '${AppConstants.providerPaymentsListUri}?payment_sub=$paymentSub&offset=$offset&limit=$limit',
    );
  }
}
