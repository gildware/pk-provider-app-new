import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

/// A reusable widget that displays image validation text with format, size, and ratio information.
/// 
/// This widget can be configured for different alignments, separators, and styling options
/// to handle various use cases across the application.
class ImageValidationTextWidget extends StatelessWidget {
  /// The text alignment for the validation text
  final TextAlign textAlign;
  
  /// The separator to use between validation items (e.g., '\n' for newline, '. ' for period)
  final String separator;
  
  /// Optional opacity value for the hint color (0.0 to 1.0)
  final double? colorOpacity;
  
  /// Optional custom text style to override the default
  final TextStyle? customStyle;
  
  /// Whether to show the extension text with a smaller font size
  final bool useSmallExtensionFont;
  
  /// Whether to show the image ratio validation text
  final bool showRatioValidation;
  
  /// The image ratio to display (e.g., "1:1", "3:1", "16:9")
  final String ratio;

  /// When set, overrides config max size for display (e.g. registration 5 MB).
  final int? maxSizeInBytes;
  
  const ImageValidationTextWidget({
    super.key,
    this.textAlign = TextAlign.start,
    this.separator = '\n',
    this.colorOpacity,
    this.customStyle,
    this.useSmallExtensionFont = false,
    this.showRatioValidation = true,
    this.ratio = '1:1',
    this.maxSizeInBytes,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).hintColor;
    final color = colorOpacity != null 
        ? baseColor.withValues(alpha: colorOpacity!) 
        : baseColor;
    
    final defaultStyle = robotoRegular.copyWith(
      color: color,
      fontSize: Dimensions.fontSizeSmall,
    );
    
    final style = customStyle ?? defaultStyle;
    
    // Generate the allowed extensions string
    final extensionsText = AppConstants.allowedImageExtensions.join(', ').toUpperCase();
    
    // Get max image size from config
    final maxSize = FileValidationHelper.formatFileSize(
      maxSizeInBytes ??
          Get.find<SplashController>().configModel.content?.maxImageUploadSize ??
          0,
    );

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: "${"image_format".tr} "),
          
          // Extensions with optional custom font size
          TextSpan(
            text: extensionsText,
            style: useSmallExtensionFont
                ? robotoRegular.copyWith(
                    color: color,
                    fontSize: Dimensions.fontSizeExtraSmall,
                  )
                : null,
          ),
          
          TextSpan(text: separator),
          TextSpan(text: "image_size_validation".tr),
          TextSpan(text: ' $maxSize'),
          
          // Conditionally show ratio validation
          ...showRatioValidation ? [
            TextSpan(text: separator),
            TextSpan(text: "image_ratio_validation".tr),
            TextSpan(text: ' $ratio'),
          ] : <TextSpan>[],
        ],
      ),
      textAlign: textAlign,
    );
  }
}
