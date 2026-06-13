import 'dart:convert';

import 'package:demandium_provider/common/enums/enums.dart';
import 'package:demandium_provider/feature/custom_post/model/post_model.dart';
import 'package:demandium_provider/feature/dashboard/model/additional_info_count.dart';
import 'package:demandium_provider/feature/dashboard/model/earnig_data_model.dart';
import 'package:demandium_provider/feature/dashboard/repo/dashboard_bundle_repo.dart';
import 'package:demandium_provider/helper/data_sync_helper.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class DashboardBundleHelper {
  static bool _bundleApplied = false;

  static bool get bundleApplied => _bundleApplied;

  static Future<bool> loadAndApply({required bool reload}) async {
    if (!reload && _bundleApplied) {
      return true;
    }

    var applied = false;
    await DataSyncHelper.fetchAndSyncData(
      fetchFromLocal: () => Get.find<DashboardBundleRepo>().getDashboardBundle(
        source: DataSourceEnum.local,
      ),
      fetchFromClient: () => Get.find<DashboardBundleRepo>().getDashboardBundle(
        source: DataSourceEnum.client,
      ),
      onResponse: (body, source) {
        final map = _responseMap(body);
        if (map == null) return;

        final content = map['content'];
        if (content is Map) {
          _apply(Map<String, dynamic>.from(content));
          applied = true;
          _bundleApplied = true;
        }
      },
      suppressErrorWhenLocalSucceeded: true,
    );
    return applied;
  }

  static void reset() {
    _bundleApplied = false;
  }

  static Map<String, dynamic>? _responseMap(dynamic body) {
    if (body is Map) {
      return Map<String, dynamic>.from(body);
    }
    if (body is String && body.isNotEmpty) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }
    return null;
  }

  static void _apply(Map<String, dynamic> content) {
    final dashboardController = Get.find<DashboardController>();

    final dashboard = content['dashboard'];
    if (dashboard is List) {
      dashboardController.applyHomeBundleDashboard(dashboard);
    }

    final earning = content['earning'];
    if (earning is Map) {
      dashboardController.applyHomeBundleEarning(Map<String, dynamic>.from(earning));
    }
  }
}
