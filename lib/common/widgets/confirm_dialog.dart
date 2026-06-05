import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class ConfirmationDialog extends StatelessWidget {
  final String? icon;
  final double iconSize;
  final Icon? iconWidget;
  final String? title;
  final String? description;
  final Color? yesButtonColor;
  final Function()? onYesPressed;
  final String? noButtonText;
  final String? yesButtonText;
  final Color? noTextColor;
  final Color? yesTextColor;
  final Color? noButtonColor;
  final Widget? customButton;

  final Function? onNoPressed;
  final bool isLoading;
  const ConfirmationDialog({super.key,  this.icon, this.iconSize = 50, this.title,  this.description,  this.onYesPressed, this.onNoPressed, this.yesButtonColor=const Color(0xFFF24646),
    this.isLoading=false, this.iconWidget, this.noTextColor, this.yesTextColor, this.noButtonColor, this.noButtonText, this.yesButtonText, this.customButton});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,  insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      backgroundColor: Theme.of(context).cardColor,
      clipBehavior: Clip.antiAliasWithSaveLayer,

      child: SizedBox(width: 400, child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: iconWidget ?? Image.asset(icon!, width: iconSize),
          ),

          title != null ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            child: Text(
              trLabel(title),
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeLarge,
              ),
            ),
          ) : const SizedBox(),

          (description!=null) ? Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Text(
              trLabel(description),
              style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).hintColor,
                  height: 1.35),
              textAlign: TextAlign.center,
            ),
          ) : const SizedBox(height: Dimensions.paddingSizeDefault,),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          customButton ?? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            const SizedBox(width: Dimensions.paddingSizeLarge),

            Expanded(child: TextButton(
              onPressed: () =>  onNoPressed != null ? onNoPressed!() : Get.back(),
              style: TextButton.styleFrom(
                backgroundColor: noButtonColor ??  Theme.of(context).hintColor.withValues(alpha:0.3),
                minimumSize: const Size(Dimensions.webMaxWidth, 40),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
              ),
              child: Text(trLabel(noButtonText, fallback: 'No'), textAlign: TextAlign.center,
                style: robotoBold.copyWith(color: noTextColor ?? Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            )),

            const SizedBox(width: Dimensions.paddingSizeLarge),


            Expanded(
              child:  CustomButton(
                color: yesButtonColor,
                textColor: yesTextColor,
                btnTxt: trLabel(yesButtonText, fallback: 'Yes'),
                onPressed: () =>  onYesPressed != null ? onYesPressed!() : Get.back(),
                radius: Dimensions.radiusSmall, height: 40,

              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeLarge),

          ]),

        ]),
      )),
    );
  }
}