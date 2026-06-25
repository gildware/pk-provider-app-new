import 'package:demandium_provider/util/core_export.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

class RegistrationZoneDropdown extends StatefulWidget {
  final SignUpController controller;

  const RegistrationZoneDropdown({super.key, required this.controller});

  @override
  State<RegistrationZoneDropdown> createState() => _RegistrationZoneDropdownState();
}

class _RegistrationZoneDropdownState extends State<RegistrationZoneDropdown> {
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
    return GetBuilder<SignUpController>(
      init: widget.controller,
      builder: (c) {
        final selected = c.selectedZonesForDisplay;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trLabel('zone_search_hint_multi'),
              style: robotoRegular.copyWith(
                color: Theme.of(context).hintColor,
                fontSize: Dimensions.fontSizeSmall,
                height: 1.4,
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
              itemBuilder: (context, ZoneData zone) => _ZoneSuggestionTile(zone: zone),
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
                (zone) => Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: _SelectedZoneCard(
                    zone: zone,
                    descendantCount: c.countDescendantZones(zone.id ?? ''),
                    onRemove: () => c.removeSelectedZone(zone.id!),
                  ),
                ),
              ),
            ],
            if (c.showRegistrationFieldErrors && c.selectedZoneIds.isEmpty)
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

class _ZoneSuggestionTile extends StatelessWidget {
  final ZoneData zone;

  const _ZoneSuggestionTile({required this.zone});

  @override
  Widget build(BuildContext context) {
    final indent = zone.depth * 14.0;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12 + indent, 12, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.adaptivePrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Icon(
                zone.isParent ? Icons.map_outlined : Icons.location_on_outlined,
                size: 20,
                color: context.adaptivePrimaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zone.name ?? '',
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (zone.isParent) ...[
                    const SizedBox(height: 4),
                    Text(
                      trLabel('zone_parent_includes_children'),
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: context.adaptivePrimaryColor,
                      ),
                    ),
                  ],
                  if (zone.hasDescription) ...[
                    const SizedBox(height: 4),
                    Text(
                      zone.description!.trim(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor,
                        height: 1.35,
                      ),
                    ),
                  ] else if (!zone.isParent)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        trLabel('no_zone_description'),
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).disabledColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.add_circle_outline, color: context.adaptivePrimaryColor, size: 22),
          ],
        ),
      ),
    );
  }
}

class _SelectedZoneCard extends StatelessWidget {
  final ZoneData zone;
  final int descendantCount;
  final VoidCallback onRemove;

  const _SelectedZoneCard({
    required this.zone,
    required this.descendantCount,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: context.adaptivePrimaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: context.adaptivePrimaryColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: context.adaptivePrimaryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.name ?? '',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
                if (descendantCount > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    trLabel('zone_sub_areas_included').replaceAll('{count}', '$descendantCount'),
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: context.adaptivePrimaryColor,
                    ),
                  ),
                ],
                if (zone.hasDescription) ...[
                  const SizedBox(height: 6),
                  Text(
                    zone.description!.trim(),
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 20),
            tooltip: trLabel('remove'),
          ),
        ],
      ),
    );
  }
}
