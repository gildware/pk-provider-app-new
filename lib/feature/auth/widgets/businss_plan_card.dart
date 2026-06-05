import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BusinessPlanCard extends StatelessWidget {
  final String? icon;
  final String? title;
  final String? subtitle;
  final bool? isSelected;
  final Color ? cardColor;
  final bool showBorder;
  final Function() ? onTap;
  const BusinessPlanCard({super.key, this.icon, this.title, this.subtitle, this.isSelected, this.cardColor, this.showBorder = true, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: showBorder? Border.all(color: isSelected !=null && isSelected! ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withValues(alpha:0.5), width: 0.6) : null,
            color: cardColor ?? Theme.of(context).cardColor,
            boxShadow: cardColor == null ? context.customThemeColors.cardShadow : null
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Row(children: [
                  icon !=null ? Image.asset(icon!, width: 30,) : const SizedBox(),
                  icon !=null ? const SizedBox(width: Dimensions.paddingSizeSmall,) : const SizedBox(),
                  title !=null ? Flexible(child: Text(trLabel(title!), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, overflow: TextOverflow.ellipsis),)) : const SizedBox()
                ]),

                const SizedBox(height: Dimensions.paddingSizeDefault,),

                subtitle !=null ? Text(trLabel(subtitle!), style: robotoRegular.copyWith(color: Theme.of(context).hintColor),) : const SizedBox()
              ]),
            ),
             SizedBox(width: Get.width * 0.15,),
            isSelected !=null ? Icon(isSelected! ? Icons.check_circle : Icons.circle_outlined, color: Theme.of(context).primaryColor, size: 27,) : const SizedBox(),
          ],),

        ),

        Positioned.fill(child: CustomInkWell(
          onTap: onTap,
        ))
      ],
    );
  }
}
