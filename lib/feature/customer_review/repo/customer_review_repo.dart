import 'package:demandium_provider/feature/customer_review/model/customer_review_body.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class CustomerReviewRepo {
  final ApiClient apiClient;

  CustomerReviewRepo({required this.apiClient});

  Future<Response> getCustomerReview({required String bookingId}) async {
    return apiClient.getData('${AppConstants.customerReview}?booking_id=$bookingId');
  }

  Future<Response> submitCustomerReview({required CustomerReviewBody reviewBody}) async {
    return apiClient.postData(AppConstants.submitCustomerReview, reviewBody.toJson());
  }
}
