
import 'package:demandium_provider/util/core_export.dart';

class CustomImage extends StatelessWidget {
  final String? image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final BoxFit? placeHolderBoxFit;
  final String? placeholder;
  final Widget? errorWidget;

  const CustomImage({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.placeHolderBoxFit,
    this.placeholder,
    this.errorWidget,
  });

  String _resolvePlaceholderAsset() => Images.resolvePlaceholder(placeholder);

  Widget _placeholderWidget() {
    return Image.asset(
      _resolvePlaceholderAsset(),
      height: height,
      width: width,
      fit: placeHolderBoxFit ?? fit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawUrl = image?.trim() ?? '';
    if (rawUrl.isEmpty) {
      return _placeholderWidget();
    }

    final url = MobileAppIconHelper.normalizeMediaUrl(rawUrl) ?? rawUrl;

    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, _) => _placeholderWidget(),
      errorWidget: (context, url, error) =>
          errorWidget ?? _placeholderWidget(),
    );
  }
}
