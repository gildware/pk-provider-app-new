import 'package:demandium_provider/common/model/api_response_model.dart';
import 'package:demandium_provider/helper/error_logger.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class DataSyncHelper {
  static Future<void> fetchAndSyncData({
    required Future<ApiResponseModel<Response>> Function() fetchFromLocal,
    required Future<ApiResponseModel<Response>> Function() fetchFromClient,
    required Function(dynamic body, DataSourceEnum source) onResponse,
    bool suppressErrorWhenLocalSucceeded = false,
  }) async {
    final localResponse = await fetchFromLocal();
    final loadedFromLocal = localResponse.isSuccess;

    if (loadedFromLocal) {
      try {
        onResponse(localResponse.response?.body, DataSourceEnum.local);
      } catch (e, stack) {
        if (GetPlatform.isMobile) {
          ErrorLogger.record(e, stack, reason: 'DataSyncHelper local onResponse');
        }
      }
    }

    final clientResponse = await fetchFromClient();
    if (clientResponse.isSuccess && clientResponse.response?.statusCode == 200) {
      try {
        onResponse(clientResponse.response?.body, DataSourceEnum.client);
      } catch (e, stack) {
        if (GetPlatform.isMobile) {
          ErrorLogger.record(e, stack, reason: 'DataSyncHelper client onResponse');
        }
      }
    } else if (!suppressErrorWhenLocalSucceeded || !loadedFromLocal) {
      ApiChecker.checkApi(clientResponse.response ?? Response(statusCode: 1));
    }
  }
}
