import 'dart:convert';

import 'package:demandium_provider/common/enums/enums.dart';
import 'package:demandium_provider/common/model/api_response_model.dart';
import 'package:demandium_provider/util/app_constants.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class ProviderCacheRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  ProviderCacheRepo({required this.apiClient, required this.sharedPreferences});

  String _cacheKeyFor(String uri) {
    final languageCode = sharedPreferences.getString(AppConstants.languageCode) ?? 'en';
    return '$uri::lang:$languageCode';
  }

  Future<ApiResponseModel<Response>> fetchData(
    String uri, {
    required DataSourceEnum source,
    ApiMethodType method = ApiMethodType.get,
    dynamic body,
  }) async {
    final cacheKey = _cacheKeyFor(uri);

    try {
      if (source == DataSourceEnum.local) {
        if (_isCacheDisabled()) {
          return ApiResponseModel.withError('No local data found for $uri');
        }
        return _fetchFromLocalCache(cacheKey, uri);
      }
      return _fetchFromClient(cacheKey, uri, method: method, body: body);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProviderCacheRepo: $source $e ($uri)');
      }
      return ApiResponseModel.withError(e);
    }
  }

  Future<ApiResponseModel<Response>> _fetchFromClient(
    String cacheKey,
    String uri, {
    ApiMethodType method = ApiMethodType.get,
    dynamic body,
  }) async {
    final Response response = method == ApiMethodType.get
        ? await apiClient.getData(uri)
        : await apiClient.postData(uri, body);

    if (response.statusCode == 200 && !_isCacheDisabled()) {
      try {
        sharedPreferences.setString(
          cacheKey,
          jsonEncode({
            'body': response.body,
            'statusCode': response.statusCode,
          }),
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('ProviderCacheRepo: cache write skipped for $uri ($e)');
        }
      }
    }

    return ApiResponseModel.withSuccess(response);
  }

  Future<ApiResponseModel<Response>> _fetchFromLocalCache(String cacheKey, String uri) async {
    try {
      final cachedJson = sharedPreferences.getString(cacheKey);
      if (cachedJson != null) {
        final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
        return ApiResponseModel.withSuccess(
          Response(
            body: decoded['body'],
            statusCode: decoded['statusCode'] ?? 200,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProviderCacheRepo: local cache read skipped for $uri ($e)');
      }
    }

    return ApiResponseModel.withError('No local data found for $uri');
  }

  bool _isCacheDisabled() => AppConstants.cachesType == LocalCachesTypeEnum.none;

  Future<void> clearProviderApiCache() async {
    final keys = sharedPreferences.getKeys().where(
      (key) => key.startsWith('/api/v1/provider') && key.contains('::lang:'),
    );
    for (final key in keys) {
      await sharedPreferences.remove(key);
    }
  }
}
