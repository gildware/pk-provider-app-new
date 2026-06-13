import 'package:demandium_provider/common/enums/enums.dart';
import 'package:demandium_provider/common/model/api_response_model.dart';
import 'package:demandium_provider/common/repo/provider_cache_repo.dart';
import 'package:demandium_provider/util/app_constants.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class DashboardBundleRepo extends ProviderCacheRepo {
  DashboardBundleRepo({required super.apiClient, required super.sharedPreferences});

  Future<ApiResponseModel<Response>> getDashboardBundle({required DataSourceEnum source}) {
    return fetchData(AppConstants.dashboardBundleUri, source: source);
  }
}
