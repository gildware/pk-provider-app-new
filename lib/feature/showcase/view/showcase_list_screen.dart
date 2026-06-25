import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class ShowcaseListScreen extends StatefulWidget {
  const ShowcaseListScreen({super.key});

  @override
  State<ShowcaseListScreen> createState() => _ShowcaseListScreenState();
}

class _ShowcaseListScreenState extends State<ShowcaseListScreen> {
  @override
  void initState() {
    super.initState();
    final controller = Get.find<ShowcaseController>();
    controller.setApprovalFilter('all');
    controller.getShowcaseList(reload: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'work_showcase'.tr),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.find<ShowcaseController>().resetForm();
          Get.to(() => const ShowcaseFormScreen());
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          GetBuilder<ShowcaseController>(
            builder: (controller) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeSmall,
                  Dimensions.paddingSizeDefault,
                  0,
                ),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'all'.tr,
                      selected: controller.approvalFilter == 'all',
                      onTap: () => controller.setApprovalFilter('all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'pending'.tr,
                      selected: controller.approvalFilter == 'pending',
                      onTap: () => controller.setApprovalFilter('pending'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'approved'.tr,
                      selected: controller.approvalFilter == 'approved',
                      onTap: () => controller.setApprovalFilter('approved'),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: GetBuilder<ShowcaseController>(
              builder: (controller) {
                if (controller.isLoading && controller.items == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.items == null || controller.items!.isEmpty) {
                  return NoDataScreen(
                    text: 'no_showcase_items'.tr,
                    type: NoDataType.service,
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: Dimensions.paddingSizeDefault,
                    mainAxisSpacing: Dimensions.paddingSizeDefault,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: controller.items!.length,
                  itemBuilder: (context, index) {
                    final item = controller.items![index];
                    return ShowcaseGridItem(
                      item: item,
                      onTap: () {
                        controller.initForm(item: item);
                        Get.to(() => const ShowcaseFormScreen());
                      },
                      onDelete: () => _confirmDelete(controller, item.id!),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ShowcaseController controller, String id) {
    showCustomDialog(
      child: ConfirmationDialog(
        icon: Images.servicemanDelete,
        title: 'delete_showcase_item'.tr,
        description: 'delete_showcase_item_hint'.tr,
        onYesPressed: () {
          Get.back();
          controller.deleteItem(id);
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        ),
        child: Text(
          label,
          style: robotoMedium.copyWith(
            color: selected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: Dimensions.fontSizeSmall,
          ),
        ),
      ),
    );
  }
}

class ShowcaseGridItem extends StatelessWidget {
  final ProviderShowcaseItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ShowcaseGridItem({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
                    child: item.isVideo
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(color: Colors.black12),
                              const Center(child: Icon(Icons.play_circle_fill, size: 48)),
                            ],
                          )
                        : CustomImage(
                            image: item.displayMediaUrl ?? '',
                            fit: BoxFit.cover,
                            placeholder: Images.servicePlaceholder,
                          ),
                  ),
                  if (item.isPendingApproval)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: _StatusBadge(label: 'pending'.tr, color: Colors.orange),
                    )
                  else if (item.isApprovedItem)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: _StatusBadge(label: 'approved'.tr, color: Colors.green),
                    )
                  else if (item.isDenied)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: _StatusBadge(label: 'denied'.tr, color: Colors.red),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title?.isNotEmpty == true ? item.title! : (item.isVideo ? 'video'.tr : 'image'.tr),
                      style: robotoMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: onDelete,
                    child: Icon(Icons.delete_outline, size: 20, color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: robotoMedium.copyWith(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
