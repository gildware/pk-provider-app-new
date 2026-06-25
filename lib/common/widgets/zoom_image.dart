import 'package:demandium_provider/util/core_export.dart';
import 'package:photo_view/photo_view.dart';

class ZoomImage extends StatefulWidget {
  final String appbarTitle;
  final String imagePath;
  final String? appbarSubtitle;
  const ZoomImage({super.key, required this.appbarTitle, required this.imagePath, this.appbarSubtitle});

  @override
  State<ZoomImage> createState() => _ZoomImageState();
}

class _ZoomImageState extends State<ZoomImage> {
  bool isZoomed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isZoomed ? null : CustomAppBar(
        title: widget.appbarTitle,
        subtitle: widget.appbarSubtitle,
      ),
      body: Stack(children: [
        PhotoView.customChild(
          scaleStateChangedCallback: (value) {
            setState(() {
              isZoomed = value != PhotoViewScaleState.initial;
            });
          },
          minScale: PhotoViewComputedScale.contained,
          child: CachedNetworkImage(
            imageUrl: widget.imagePath,
            fit: BoxFit.contain,
            placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
            errorWidget: (_, __, ___) => MediaPlaceholder(fit: BoxFit.contain),
          ),
        ),
      ]),
    );
  }
}
