import 'package:demandium_provider/api/api_client.dart';
import 'package:demandium_provider/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class TutorialRepo {
  final ApiClient apiClient;
  TutorialRepo({required this.apiClient});


  Future<Response> updateTutorial({Map<String, String>? options}) async {
    return await apiClient.postData(AppConstants.updateTutorialUrl, options);
  }

}