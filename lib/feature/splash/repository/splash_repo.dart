import 'package:demandium_provider/common/enums/enums.dart';
import 'package:demandium_provider/common/model/api_response_model.dart';
import 'package:demandium_provider/common/repo/provider_cache_repo.dart';
import 'package:demandium_provider/util/app_constants.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class SplashRepo {
  final ProviderCacheRepo cacheRepo;
  final SharedPreferences sharedPreferences;
  final ApiClient apiClient;

  SplashRepo({
    required this.sharedPreferences,
    required this.apiClient,
    required this.cacheRepo,
  });

  Future<ApiResponseModel<Response>> getConfigData({required DataSourceEnum source}) {
    return cacheRepo.fetchData(AppConstants.configUri, source: source);
  }

  Future<bool> initSharedData() async {
    if (!sharedPreferences.containsKey(AppConstants.theme)) {
      sharedPreferences.setBool(AppConstants.theme, false);
    }
    if (!sharedPreferences.containsKey(AppConstants.countryCode)) {
      sharedPreferences.setString(
        AppConstants.countryCode,
        AppConstants.languages[0].countryCode!,
      );
    }
    if (!sharedPreferences.containsKey(AppConstants.languageCode)) {
      sharedPreferences.setString(
        AppConstants.languageCode,
        AppConstants.languages[0].languageCode!,
      );
    }
    if (!sharedPreferences.containsKey(AppConstants.notification)) {
      sharedPreferences.setBool(AppConstants.notification, true);
    }
    if (!sharedPreferences.containsKey(AppConstants.notificationCount)) {
      sharedPreferences.setInt(AppConstants.notificationCount, 0);
    }
    if (!sharedPreferences.containsKey(AppConstants.initialLanguage)) {
      sharedPreferences.setBool(AppConstants.initialLanguage, true);
    }

    return true;
  }

  bool showInitialLanguageScreen() {
    return sharedPreferences.getBool(AppConstants.initialLanguage) ?? false;
  }

  void disableShowInitialLanguageScreen() {
    sharedPreferences.setBool(AppConstants.initialLanguage, false);
  }

  Future<Response> updateLanguage() async {
    return apiClient.postData(AppConstants.changeLanguage, {});
  }
}
