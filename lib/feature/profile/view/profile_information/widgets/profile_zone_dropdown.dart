import 'package:demandium_provider/util/core_export.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

class ProfileZoneDropdown extends StatefulWidget {
  const ProfileZoneDropdown({super.key});

  @override
  State<ProfileZoneDropdown> createState() => _ProfileZoneDropdownState();
}

class _ProfileZoneDropdownState extends State<ProfileZoneDropdown> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (c) {
        if (c.isZoneTreeLoading && c.zoneList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final selected = c.selectedZonesForDisplay;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trLabel('select_service_zones_hint'),
              style: robotoRegular.copyWith(
                color: Theme.of(context).hintColor,
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            TypeAheadField<ZoneData>(
              controller: _searchController,
              hideOnEmpty: c.filterZonesForDropdown('').isEmpty,
              hideOnLoading: true,
              suggestionsCallback: (pattern) => c.filterZonesForDropdown(pattern),
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: trLabel('search_service_areas'),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: controller.clear,
                          )
                        : const Icon(Icons.keyboard_arrow_down),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                );
              },
              decorationBuilder: (context, child) {
                return Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).cardColor,
                  child: child,
                );
              },
              constraints: const BoxConstraints(maxHeight: 320),
              itemBuilder: (context, ZoneData zone) {
                final indent = zone.depth * 14.0;
                return Padding(
                  padding: EdgeInsets.only(left: indent),
                  child: ListTile(
                    title: Text(zone.name ?? ''),
                    subtitle: zone.hasDescription
                        ? Text(zone.description!, maxLines: 2, overflow: TextOverflow.ellipsis)
                        : null,
                  ),
                );
              },
              onSelected: (ZoneData zone) {
                c.addSelectedZone(zone);
                _searchController.clear();
              },
              emptyBuilder: (_) => Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Text(
                  trLabel('no_zone_found'),
                  style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                ),
              ),
            ),
            if (selected.isNotEmpty) ...[
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${trLabel('selected_zones')} (${selected.length})',
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                    ),
                  ),
                  TextButton(
                    onPressed: c.clearSelectedZones,
                    child: Text(trLabel('clear_all')),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              ...selected.map(
                (zone) => Card(
                  margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: ListTile(
                    title: Text(zone.name ?? ''),
                    subtitle: zone.hasDescription ? Text(zone.description!) : null,
                    trailing: IconButton(
                      icon: Icon(Icons.close, color: Theme.of(context).colorScheme.error),
                      onPressed: () => c.removeSelectedZone(zone.id!),
                    ),
                  ),
                ),
              ),
            ],
            if (!c.isZoneValid)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  trLabel('select_at_least_one_zone'),
                  style: robotoRegular.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
