import 'dart:convert';

import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class BookingDetailsRepo{
  final ApiClient apiClient;

  BookingDetailsRepo({required this.apiClient});

  Future<Response> getBookingDetails(String bookingID) async {
    return await apiClient.getData("${AppConstants.bookingDetailsUrl}$bookingID");
  }

  Future<Response> getSubBookingDetails(String bookingID) async {
    return await apiClient.getData("${AppConstants.subBookingDetailsUrl}$bookingID");
  }

  Future<Response> acceptBookingRequest(String bookingID) async {
    return await apiClient.putData("${AppConstants.acceptBookingRequestUrl}/$bookingID",{'method':'put'});
  }

  Future<Response> ignoreBookingRequest(
    String bookingID, {
    int? providerCancellationReasonId,
    String? statusChangeRemarks,
  }) async {
    final Map<String, dynamic> body = {};
    if (providerCancellationReasonId != null) {
      body['booking_provider_cancellation_reason_id'] = providerCancellationReasonId;
    }
    if (statusChangeRemarks != null && statusChangeRemarks.trim().isNotEmpty) {
      body['status_change_remarks'] = statusChangeRemarks.trim();
    }
    return await apiClient.postData("${AppConstants.ignoreBookingRequestUrl}/$bookingID", body);
  }

  Future<Response> cancelSubBooking(String subBookingId) async {
    return await apiClient.postData("${AppConstants.cancelSubBookingUrl}$subBookingId", {});
  }

  Future<Response> changeSchedule(String bookingID,String schedule) async {
    return await apiClient.putData("${AppConstants.changeScheduleUrl}/$bookingID",{'schedule': schedule});
  }

  Future<Response> getProviderCancellationReasons() async {
    return await apiClient.getData(AppConstants.providerCancellationReasonsUrl);
  }

  Future<Response> getProviderHoldReasons() async {
    return await apiClient.getData(AppConstants.providerHoldReasonsUrl);
  }

  Future<Response> changeBookingStatus(
    String bookingID,
    String status,
    String otp,
    List<MultipartBody>? photoEvidence,
    bool isSubBooking, {
    int? providerCancellationReasonId,
    String? statusChangeRemarks,
    int? holdReopenReasonId,
  }) async {
    final Map<String, String> body = {
      'booking_status': status,
      '_method': 'put',
      'booking_otp': otp,
    };
    if (status == 'completed') {
      body['payment_received_confirmed'] = '1';
    }
    if (providerCancellationReasonId != null) {
      body['booking_provider_cancellation_reason_id'] = '$providerCancellationReasonId';
    }
    if (holdReopenReasonId != null) {
      body['booking_hold_reopen_reason_id'] = '$holdReopenReasonId';
    }
    if (statusChangeRemarks != null && statusChangeRemarks.trim().isNotEmpty) {
      body['status_change_remarks'] = statusChangeRemarks.trim();
    }

    final url =
        '${isSubBooking ? AppConstants.changeSubBookingStatus : AppConstants.changeBookingStatus}/$bookingID';

    if (photoEvidence != null && photoEvidence.isNotEmpty) {
      return await apiClient.postMultipartData(url, body, photoEvidence, null);
    }

    return await apiClient.putData(url, body);
  }

  Future<Response> recordBookingPayment(String bookingId, double amount) async {
    return await apiClient.postData(
      '${AppConstants.recordBookingPaymentUrl}/$bookingId',
      {'amount': amount},
    );
  }

  Future<Response> sendBookingOTPNotification(String? bookingId) {
    return apiClient.getData("${AppConstants.bookingOTPNotificationUri}?booking_id=$bookingId");
  }

  Future<Response> getBookingPriceList(String zoneId , String serviceInfo){
    return apiClient.getData("${AppConstants.getBookingPriceList}?zone_id=$zoneId&service_info=$serviceInfo");
  }

  Future<Response> changeServiceLocation({
    required BookingEditType bookingEditType,ServiceAddress? address, required serviceLocation ,String? bookingId, String? subBookingId,
    bool? changeNextAllBooking,
  }){
    return apiClient.postData(AppConstants.changeServiceLocation, {
      "service_address" : jsonEncode(address),
      "service_location" : serviceLocation,
      "booking_id" : bookingId,
      "next_all_booking_change" : changeNextAllBooking == true && bookingEditType == BookingEditType.repeat ? "1": "0",
      "booking_repeat_id" : subBookingId
    });
  }

  Future<Response> removeCartServiceFromServer({CartModel? cart , String? bookingId, String? zoneId}){
    return apiClient.postData(AppConstants.removeCartServiceFromServer, {
      "_method" : "put",
      "booking_id" : bookingId,
      "zone_id" : zoneId,
      "variant_key" : cart?.variantKey,
      "service_id" : cart?.serviceId
    });
  }

  Future<Response> updateBooking({required BookingEditType bookingEditType,String? bookingId, String? subBookingId , String? zoneId, String? paymentStatus, String? servicemanId, String? bookingStatus, String? serviceSchedule, String? serviceInfo, bool? changeNextAllBooking }){
    return apiClient.postData( bookingEditType == BookingEditType.regular ? AppConstants.updateRegularBooking : AppConstants.updateRepeatBooking, {
      "_method" : "put",
      "booking_id" : bookingId,
      "zone_id" : zoneId,
      "payment_status" : paymentStatus,
      "serviceman_id" : servicemanId,
      "booking_status" : bookingStatus,
      "service_schedule" : serviceSchedule,
      "service_info" : serviceInfo,
      "booking_repeat_id" : subBookingId,
      "next_all_booking_change" : changeNextAllBooking == true && bookingEditType == BookingEditType.repeat ? "1": "0"
    });
  }
}