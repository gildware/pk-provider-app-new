import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class RegistrationServiceCategoriesStep extends StatefulWidget {
  final SignUpController controller;

  const RegistrationServiceCategoriesStep({super.key, required this.controller});

  @override
  State<RegistrationServiceCategoriesStep> createState() => _RegistrationServiceCategoriesStepState();
}

class _RegistrationServiceCategoriesStepState extends State<RegistrationServiceCategoriesStep> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.controller.registrationCategories.isEmpty &&
          !widget.controller.isRegistrationCategoriesLoading) {
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
              trLabel('zone_no_categories_for_selection'),
              style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(trLabel('select_service_categories_hint'), style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Text(trLabel('categories'), style: robotoBold),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              ...c.registrationCategories.map((category) {
                final id = category.id?.toString() ?? '';
                final selected = id.isNotEmpty && c.selectedCategoryIds.contains(id);
                return _CategorySelectCard(
                  category: category,
                  selected: selected,
                  onTap: () {
                    if (id.isNotEmpty) c.toggleRegistrationCategory(id);
                  },
                );
              }),
              if (c.showRegistrationFieldErrors && !c.hasSelectedCategories)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    trLabel('select_at_least_one_category'),
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

class _CategorySelectCard extends StatelessWidget {
  final ServiceCategoryModel category;
  final bool selected;
  final VoidCallback onTap;

  const _CategorySelectCard({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: selected
                 ? context.tabSelectedColor
                : Theme.of(context).dividerColor.withValues(alpha: 0.4),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              child: CustomImage(
                height: 56,
                width: 56,
                fit: BoxFit.cover,
                image: category.imageFullPath ?? '',
                placeholder: Images.categoryPlaceholder,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(category.name ?? '', style: robotoMedium)),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? context.tabSelectedColor : Theme.of(context).hintColor,
            ),
          ],
        ),
      ),
    );
  }
}
