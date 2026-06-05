import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/util/core_export.dart';

/// Image vs video selector for work showcase (radio-style cards).
class ShowcaseMediaTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const ShowcaseMediaTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldTitle(title: trLabel('media_type'), isPadding: false),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(
          trLabel('showcase_media_type_hint'),
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Row(
          children: [
            Expanded(
              child: _MediaTypeOptionCard(
                icon: Icons.image_outlined,
                title: trLabel('showcase_image_label'),
                subtitle: trLabel('showcase_image_subtitle'),
                isSelected: selectedType == 'image',
                onTap: () => onTypeChanged('image'),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: _MediaTypeOptionCard(
                icon: Icons.videocam_outlined,
                title: trLabel('video'),
                subtitle: trLabel('showcase_video_subtitle'),
                isSelected: selectedType == 'video',
                onTap: () => onTypeChanged('video'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MediaTypeOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _MediaTypeOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
            vertical: Dimensions.paddingSizeDefault,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(
              color: isSelected ? primary : Theme.of(context).hintColor.withValues(alpha: 0.35),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? primary.withValues(alpha: 0.08) : Theme.of(context).cardColor,
            boxShadow: context.customThemeColors.lightShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? primary : Theme.of(context).hintColor,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: primary),
                            ),
                          )
                        : null,
                  ),
                  const Spacer(),
                  if (isSelected) Icon(Icons.check_circle, color: primary, size: 20),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withValues(alpha: 0.12)
                      : Theme.of(context).hintColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: isSelected ? primary : Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                title,
                textAlign: TextAlign.center,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).hintColor,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
