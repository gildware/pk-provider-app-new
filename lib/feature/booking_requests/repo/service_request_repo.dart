import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class BookingRequestRepo{
  final ApiClient apiClient;

  BookingRequestRepo({required this.apiClient});

  Future<Response> getBookingRequestData(String requestType, int offset, ServiceType serviceType) async {
    return await apiClient.postData(AppConstants.bookingListUrl,
        {"limit" : 10, "offset" : offset, "booking_status" : requestType, "service_type" : serviceType.name});
  }

  Future<Response> getBookingCalendarData({
    required String mode,
    int? month,
    int? year,
    String? startDate,
    String? endDate,
    String? date,
    // Filter parameters
    String? filterStartDate,
    String? filterEndDate,
    List<String>? bookingStatus,
    String? bookingType,
  }) async {
    Map<String, dynamic> params = {
      'mode': mode,
    };
    
    // Date range parameters for view navigation
    if (month != null) params['month'] = month;
    if (year != null) params['year'] = year;
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    if (date != null) params['date'] = date;
    
    // Filter parameters
    if (filterStartDate != null) params['filter_start_date'] = filterStartDate;
    if (filterEndDate != null) params['filter_end_date'] = filterEndDate;
    if (bookingType != null && bookingType != 'all') params['booking_type'] = bookingType;
    
    // Build query string with array support for booking_status
    String queryString = _buildQueryString(params);
    
    // Add booking status array parameters
    if (bookingStatus != null && bookingStatus.isNotEmpty) {
      final statusParams = bookingStatus.map((status) => 
        'booking_status[]=${Uri.encodeComponent(status)}'
      ).join('&');
      queryString = queryString.isEmpty ? statusParams : '$queryString&$statusParams';
    }
    
    return await apiClient.getData('${AppConstants.bookingCalenderList}?$queryString');
  }

  String _buildQueryString(Map<String, dynamic> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
  }
}