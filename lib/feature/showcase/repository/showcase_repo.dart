import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class ShowcaseRepo {
  final ApiClient apiClient;
  ShowcaseRepo({required this.apiClient});

  Future<Response> getShowcaseList({String? approvalStatus}) async {
    final query = approvalStatus != null && approvalStatus.isNotEmpty
        ? '?approval_status=$approvalStatus'
        : '';
    return await apiClient.getData('${AppConstants.getShowcaseList}$query');
  }

  Future<Response> addShowcaseItem(Map<String, String> body, MultipartBody media) async {
    return await apiClient.postMultipartData(
      AppConstants.addShowcaseItem,
      body,
      [media],
      null,
    );
  }

  Future<Response> updateShowcaseItem(String id, Map<String, String> body, {MultipartBody? media}) async {
    return await apiClient.postMultipartData(
      '${AppConstants.updateShowcaseItem}/$id',
      body,
      media != null ? [media] : null,
      null,
    );
  }

  Future<Response> deleteShowcaseItem(String id) async {
    return await apiClient.deleteData('${AppConstants.deleteShowcaseItem}/$id');
  }
}
