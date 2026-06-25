
import 'package:demandium_provider/util/core_export.dart';

class CustomImage extends StatelessWidget {
  final String? image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String? placeholder;
  final Widget? errorWidget;

  const CustomImage({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  String get _placeholderAsset => placeholder ?? Images.placeholder;

  Widget _placeholderWidget() {
    return Image.asset(
      _placeholderAsset,
      height: height,
      width: width,
      fit: fit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = image?.trim() ?? '';
    if (url.isEmpty) {
      return _placeholderWidget();
    }

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
