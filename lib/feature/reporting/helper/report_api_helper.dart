import 'package:get/get.dart';

class ReportApiHelper {
  static bool isSuccess(Response response) {
    return response.statusCode == 200 &&
        response.body != null &&
        response.body is Map &&
        response.body['response_code']?.toString() == 'default_200';
  }

  static Map<String, dynamic> baseFilterBody({
    String? dateRange,
    String? from,
    String? to,
    String? zoneId,
    String? categoryId,
    String? subCategoryId,
    String? bookingStatus,
    String? transactionType,
  }) {
    final Map<String, dynamic> body = {
      'date_range': dateRange ?? 'all_time',
    };
    if (from != null && from.isNotEmpty) {
      body['from'] = from;
    }
    if (to != null && to.isNotEmpty) {
      body['to'] = to;
    }
    if (zoneId != null) {
      body['zone_ids'] = [zoneId];
    }
    if (categoryId != null) {
      body['category_ids'] = [categoryId];
    }
    if (subCategoryId != null) {
      body['sub_category_ids'] = [subCategoryId];
    }
    if (bookingStatus != null) {
      body['booking_status'] = bookingStatus;
    }
    if (transactionType != null) {
      body['transaction_type'] = transactionType;
    }
    return body;
  }
}
