import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class ReportRepo{
  final ApiClient apiClient;
  ReportRepo({required this.apiClient});


  Future<Response> getBusinessReportOverviewData(int offset, Map<String,dynamic> body
      ) async {
    return await apiClient.postData(
        "${AppConstants.getBusinessOverviewList}?limit=20&offset=$offset",body
    );
  }

  Future<Response> getBusinessReportEarningData(int offset, Map<String,dynamic> body
      ) async {
    return await apiClient.postData(
        "${AppConstants.getBusinessEarningList}?limit=10&offset=$offset",body
    );
  }
  Future<Response> getBusinessReportExpenseData(int offset, Map<String,dynamic> body
      ) async {
    return await apiClient.postData(
        "${AppConstants.getBusinessExpenseList}?limit=10&offset=$offset",body
    );
  }



  Future<Response> getBookingReportData(int offset, Map<String,dynamic> body
      ) async {
    final requestBody = Map<String, dynamic>.from(body)
      ..['limit'] = 10
      ..['offset'] = offset;
    return await apiClient.postData(
        "${AppConstants.getBookingReportList}?limit=10&offset=$offset", requestBody
    );
  }
}