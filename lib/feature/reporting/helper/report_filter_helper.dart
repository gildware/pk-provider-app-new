import 'package:demandium_provider/feature/category/controller/service_category_controller.dart';
import 'package:demandium_provider/feature/profile/controller/user_controller.dart';
import 'package:demandium_provider/feature/reporting/model/booking_report_model.dart';
import 'package:demandium_provider/feature/subscriptions/model/subcategory_subscription_model.dart';
import 'package:demandium_provider/feature/subscriptions/repo/subscription_repo.dart';
import 'package:get/get.dart';

class ReportFilterZoneCategoryData {
  final List<ZonesList> zones;
  final List<String> zoneNames;
  final List<Categories> categories;
  final List<String> categoryNames;
  final List<SubscriptionModelData> subscriptions;

  const ReportFilterZoneCategoryData({
    required this.zones,
    required this.zoneNames,
    required this.categories,
    required this.categoryNames,
    required this.subscriptions,
  });
}

class ReportFilterHelper {
  static String normalizeId(dynamic id) {
    if (id == null) return '';
    return id.toString().trim();
  }

  static Future<ReportFilterZoneCategoryData> loadProviderZonesAndSubscriptions() async {
    final zones = <ZonesList>[];
    final zoneNames = <String>[];
    final categories = <Categories>[];
    final categoryNames = <String>[];
    final subscriptions = <SubscriptionModelData>[];

    final profile = Get.find<UserProfileController>();
    if (profile.providerModel == null) {
      await profile.getProviderInfo();
    }
    if (profile.zoneList.isEmpty) {
      await profile.loadZoneTree();
    }

    for (final zone in profile.selectedZones) {
      final id = normalizeId(zone.id);
      final name = zone.name?.trim() ?? '';
      if (id.isEmpty || name.isEmpty) continue;
      zones.add(ZonesList(id: id, name: name));
      zoneNames.add(name);
    }

    if (zones.isEmpty) {
      final info = profile.providerModel?.content?.providerInfo;
      final zoneIds = info?.zoneIds ?? [];
      if (zoneIds.isEmpty && info?.zoneId != null) {
        final id = normalizeId(info!.zoneId);
        final name = profile.selectedZoneName.isNotEmpty
            ? profile.selectedZoneName
            : profile.myZone;
        if (id.isNotEmpty && name.isNotEmpty) {
          zones.add(ZonesList(id: id, name: name));
          zoneNames.add(name);
        }
      } else {
        final byId = {
          for (final z in profile.zoneList)
            if (z.id != null) normalizeId(z.id): z,
        };
        for (final rawId in zoneIds) {
          final id = normalizeId(rawId);
          final zone = byId[id];
          if (zone?.name != null && zone!.name!.isNotEmpty) {
            zones.add(ZonesList(id: id, name: zone.name));
            zoneNames.add(zone.name!);
          }
        }
      }
    }

    final subscriptionRepo = Get.find<SubscriptionRepo>();
    int offset = 1;
    int lastPage = 1;
    do {
      final response = await subscriptionRepo.getSubcategorySubscriptionList(
        offset,
        categoryId: '',
        limit: 100,
      );
      if (response.statusCode != 200 ||
          response.body['response_code']?.toString() != 'default_200') {
        break;
      }
      final list = response.body['content']['data'] as List<dynamic>? ?? [];
      for (final element in list) {
        if (element is Map && element['sub_category'] != null) {
          subscriptions.add(
            SubscriptionModelData.fromJson(Map<String, dynamic>.from(element)),
          );
        }
      }
      lastPage = int.tryParse(response.body['content']['last_page'].toString()) ?? 1;
      offset++;
    } while (offset <= lastPage);

    final categoryController = Get.find<ServiceCategoryController>();
    if (categoryController.serviceCategoryList == null ||
        categoryController.serviceCategoryList!.isEmpty) {
      await categoryController.getCategoryList(shouldUpdate: false);
    }

    final categoriesById = <String, String>{};
    for (final c in categoryController.serviceCategoryList ?? []) {
      final id = normalizeId(c.id);
      final name = c.name?.trim() ?? '';
      if (id.isNotEmpty && name.isNotEmpty) {
        categoriesById[id] = name;
      }
    }

    final categoryNamesById = <String, String>{};
    for (final item in subscriptions) {
      final catId = normalizeId(
        item.categoryId ?? item.subCategory?.parentId,
      );
      if (catId.isEmpty) continue;

      final fromSubscription = item.categoryName?.trim() ?? '';
      final fromCatalog = categoriesById[catId] ?? '';
      final name = fromSubscription.isNotEmpty ? fromSubscription : fromCatalog;
      if (name.isEmpty) continue;

      categoryNamesById.putIfAbsent(catId, () => name);
    }

    for (final catId in categoryNamesById.keys.toList()..sort()) {
      final name = categoryNamesById[catId]!;
      categories.add(Categories(id: catId, name: name));
      categoryNames.add(name);
    }

    return ReportFilterZoneCategoryData(
      zones: zones,
      zoneNames: zoneNames,
      categories: categories,
      categoryNames: categoryNames,
      subscriptions: subscriptions,
    );
  }

  static Future<List<ZonesList>> loadProviderZones() async {
    final data = await loadProviderZonesAndSubscriptions();
    return data.zones;
  }

  static Set<String> providerZoneIds(ReportFilterZoneCategoryData data) {
    return data.zones
        .map((z) => normalizeId(z.id))
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  static Set<String> subscribedCategoryIds(List<SubscriptionModelData> subscriptions) {
    return subscriptions
        .map((s) => normalizeId(s.categoryId))
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  /// Clears dropdown selections that are no longer in the loaded option lists.
  static void sanitizeDropdownSelections({
    required List<String> zoneNameList,
    required List<String> categoryNameList,
    required List<String> subcategoryNameList,
    String? selectedZoneName,
    String? selectedCategoryName,
    String? selectedSubcategoryName,
    required void Function({
      String? zoneName,
      String? categoryName,
      String? subcategoryName,
    }) onClear,
  }) {
    String? zoneName = selectedZoneName;
    String? categoryName = selectedCategoryName;
    String? subcategoryName = selectedSubcategoryName;

    if (zoneName != null && !zoneNameList.contains(zoneName)) {
      zoneName = null;
    }
    if (categoryName != null && !categoryNameList.contains(categoryName)) {
      categoryName = null;
      subcategoryName = null;
    }
    if (subcategoryName != null && !subcategoryNameList.contains(subcategoryName)) {
      subcategoryName = null;
    }

    if (zoneName != selectedZoneName ||
        categoryName != selectedCategoryName ||
        subcategoryName != selectedSubcategoryName) {
      onClear(
        zoneName: zoneName,
        categoryName: categoryName,
        subcategoryName: subcategoryName,
      );
    }
  }

  /// Adds API filter options that match provider zones and subscriptions.
  static void mergeApiFilterOptions({
    required List<ZonesList> zonesList,
    required List<String> zoneNameList,
    required List<Categories> categoriesList,
    required List<String> categoryNameList,
    required List<SubCategories> subcategoriesList,
    required Set<String> allowedZoneIds,
    required Set<String> allowedCategoryIds,
    required List<SubscriptionModelData> subscriptions,
    List<ZonesList>? apiZones,
    List<Categories>? apiCategories,
    List<SubCategories>? apiSubCategories,
  }) {
    final zoneIds = {for (final z in zonesList) normalizeId(z.id)};
    for (final zone in apiZones ?? <ZonesList>[]) {
      final zoneId = normalizeId(zone.id);
      if (zoneId.isEmpty ||
          zone.name == null ||
          !allowedZoneIds.contains(zoneId) ||
          zoneIds.contains(zoneId)) {
        continue;
      }
      zonesList.add(ZonesList(id: zoneId, name: zone.name));
      zoneNameList.add(zone.name!);
      zoneIds.add(zoneId);
    }

    final categoryIds = {for (final c in categoriesList) normalizeId(c.id)};
    for (final category in apiCategories ?? <Categories>[]) {
      final categoryId = normalizeId(category.id);
      if (categoryId.isEmpty ||
          category.name == null ||
          !allowedCategoryIds.contains(categoryId) ||
          categoryIds.contains(categoryId)) {
        continue;
      }
      categoriesList.add(Categories(id: categoryId, name: category.name));
      categoryNameList.add(category.name!);
      categoryIds.add(categoryId);
    }

    final subIds = {for (final s in subcategoriesList) normalizeId(s.id)};
    for (final sub in apiSubCategories ?? <SubCategories>[]) {
      final subId = normalizeId(sub.id);
      final parentId = normalizeId(sub.parentId);
      if (subId.isEmpty ||
          sub.name == null ||
          parentId.isEmpty ||
          !allowedCategoryIds.contains(parentId) ||
          subIds.contains(subId)) {
        continue;
      }
      final isSubscribed = subscriptions.any(
        (item) =>
            (normalizeId(item.subCategoryId) == subId ||
                normalizeId(item.subCategory?.id) == subId) &&
            normalizeId(item.categoryId) == parentId,
      );
      if (!isSubscribed) continue;
      subcategoriesList.add(
        SubCategories(id: subId, parentId: parentId, name: sub.name),
      );
      subIds.add(subId);
    }
  }

  static List<SubCategories> subscribedSubcategoriesForCategory({
    required List<SubscriptionModelData> subscriptions,
    required String categoryId,
  }) {
    final normalizedCategoryId = normalizeId(categoryId);
    final result = <SubCategories>[];
    final seen = <String>{};
    for (final item in subscriptions) {
      if (normalizeId(item.categoryId) != normalizedCategoryId) continue;
      final sub = item.subCategory;
      final id = normalizeId(sub?.id ?? item.subCategoryId);
      final name = sub?.name?.trim() ?? '';
      if (id.isEmpty || name.isEmpty || seen.contains(id)) continue;
      seen.add(id);
      result.add(
        SubCategories(id: id, parentId: normalizedCategoryId, name: name),
      );
    }
    return result;
  }
}
