
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  final Function()? onPressed;
  final bool? transparent;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final double? radius;
  final IconData? icon;
  final Color? color;
  final String btnTxt;
  final bool isLoading;
  final bool isShowLoadingButton;
  final bool showBorder;
  final Color? textColor;
  const CustomButton({super.key, this.onPressed, this.transparent = false, this.margin, this.width, this.height,this.color,
    this.fontSize, this.radius = 5, this.icon,required this.btnTxt, this.isLoading = false,
    this.isShowLoadingButton = true,
    this.showBorder = false, this.textColor
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      elevation: 0,
      backgroundColor: onPressed == null ? Theme.of(context).disabledColor : transparent!
          ? Colors.transparent :color ?? Theme.of(context).primaryColor,
      minimumSize: Size(width != null ? width! : Dimensions.webMaxWidth, height != null ? height! : 45),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius!),
        side: showBorder ? BorderSide(color: Theme.of(context).primaryColor.withValues(alpha:0.6)) : BorderSide.none,
      ),
    );

    return Center(child: SizedBox(width: width ?? Dimensions.webMaxWidth, child: Padding(
      padding: margin == null ? const EdgeInsets.all(0) : margin!,
      child: ElevatedButton(
        onPressed: !isLoading? onPressed : null,
        style: flatButtonStyle,
        child: Padding(
          padding: isLoading ? const EdgeInsets.only(right: Dimensions.paddingSizeSmall):
          EdgeInsets.zero,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [

            isShowLoadingButton ? isLoading ?
            Padding( padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: SizedBox(height: fontSize ?? Dimensions.fontSizeDefault , width: fontSize ?? Dimensions.fontSizeDefault,
                child: CircularProgressIndicator(color: transparent! ? Theme.of(context).primaryColor : textColor ?? Colors.white, strokeWidth: 2,),
              ),
            ): const SizedBox() : const SizedBox(),

            icon != null && !isLoading ? Padding(
              padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
              child: Icon(icon, color: transparent! ? Theme.of(context).primaryColor : textColor ?? Colors.white, size: fontSize ?? Dimensions.fontSizeLarge,),
            ) : const SizedBox(),

            Flexible(
              child: Text( isLoading ? "loading".tr : btnTxt, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: robotoMedium.copyWith(
                color: transparent! ? Theme.of(context).primaryColor : textColor ?? Colors.white, fontSize: fontSize ?? Dimensions.fontSizeLarge,
              )),
            ),
          ]),
        ),
      ),
    )));
  }
}