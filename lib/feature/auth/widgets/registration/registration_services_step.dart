import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class RegistrationServicesStep extends StatefulWidget {
  final SignUpController controller;

  const RegistrationServicesStep({super.key, required this.controller});

  @override
  State<RegistrationServicesStep> createState() => _RegistrationServicesStepState();
}

class _RegistrationServicesStepState extends State<RegistrationServicesStep> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.controller.registrationCategories.isEmpty && !widget.controller.isRegistrationCategoriesLoading) {
        widget.controller.loadRegistrationCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignUpController>(
      init: widget.controller,
      builder: (c) {
        if (c.selectedZoneIds.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Text(
              trLabel('select_zone_before_services'),
              style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        if (c.isRegistrationCategoriesLoading && c.registrationCategories.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (c.registrationCategories.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Text(
              trLabel(c.selectedZoneIds.isEmpty ? 'select_zone_before_services' : 'zone_no_categories_for_selection'),
              style: robotoRegular.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trLabel('registration_services_hint'),
                style: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: Dimensions.fontSizeSmall,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Text(trLabel('categories'), style: robotoBold),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: c.registrationCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = c.registrationCategories[index];
                    final selected = c.registrationCategoryIndex == index;
                    return ChoiceChip(
                      label: Text(category.name ?? ''),
                      selected: selected,
                      onSelected: (_) => c.selectRegistrationCategory(index),
                      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                      labelStyle: robotoMedium.copyWith(
                        color: selected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Row(
                children: [
                  Expanded(child: Text(trLabel('sub_category'), style: robotoBold)),
                  if (c.hasSelectedSubCategories)
                    Text(
                      '${c.selectedSubCategoryIds.length} ${trLabel('subscribed')}',
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              if (c.isRegistrationSubCategoriesLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (c.registrationSubCategories.isEmpty)
                Text(trLabel('no_sub_category_found'), style: robotoRegular.copyWith(color: Theme.of(context).hintColor))
              else
                ...c.registrationSubCategories.map((sub) => _RegistrationSubCategoryCard(
                      subCategory: sub,
                      onToggle: () {
                        if (sub.id != null) {
                          c.toggleRegistrationSubCategory(sub.id!);
                        }
                      },
                    )),
              if (!c.hasSelectedSubCategories)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    trLabel('select_at_least_one_subcategory'),
                    style: robotoRegular.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RegistrationSubCategoryCard extends StatelessWidget {
  final ServiceSubCategoryModel subCategory;
  final VoidCallback onToggle;

  const _RegistrationSubCategoryCard({
    required this.subCategory,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final subscribed = subCategory.isSubscribed == 1;
    final serviceCount = subCategory.servicesCount ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: subscribed
              ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
              : Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
        boxShadow: context.customThemeColors.lightShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: CustomImage(
              height: 64,
              width: 64,
              fit: BoxFit.cover,
              image: subCategory.imageFullPath ?? '',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subCategory.name ?? '', style: robotoMedium),
                if ((subCategory.description ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subCategory.description!.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  '${trLabel('services')} ($serviceCount)',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              backgroundColor: subscribed
                  ? Theme.of(context).colorScheme.onSecondaryContainer.withValues(alpha: 0.3)
                  : Theme.of(context).primaryColor,
              disabledBackgroundColor: Theme.of(context).colorScheme.onSecondaryContainer.withValues(alpha: 0.3),
            ),
            onPressed: onToggle,
            child: Text(
              subscribed ? trLabel('subscribed') : trLabel('subscribe'),
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: subscribed ? Theme.of(context).hintColor : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
