import 'package:demandium_provider/util/core_export.dart';

/// Fills a bounded box and shows network or local images with correct aspect ratio.
class ProfileImagePreviewBox extends StatelessWidget {
  final double height;
  final double? width;
  final String? networkUrl;
  final String? localFilePath;
  final VoidCallback? onTap;
  final Widget? overlay;

  const ProfileImagePreviewBox({
    super.key,
    required this.height,
    this.width,
    this.networkUrl,
    this.localFilePath,
    this.onTap,
    this.overlay,
  });

  bool get _hasLocal => localFilePath != null && localFilePath!.isNotEmpty;
  bool get _hasNetwork => networkUrl != null && networkUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final boxWidth = width ?? MediaQuery.sizeOf(context).width;

    return DottedBorderBox(
      height: height,
      width: boxWidth,
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: _hasLocal
                ? Image.file(
                    File(localFilePath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : CustomImage(
                    image: _hasNetwork ? networkUrl! : '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: Images.placeholder,
                  ),
          ),
          if (overlay != null) overlay!,
        ],
      ),
    );
  }
}

/// Circular contact person photo preview.
class ProfileContactPhotoPreview extends StatelessWidget {
  final double size;
  final String? networkUrl;
  final String? localFilePath;
  final VoidCallback onPick;

  const ProfileContactPhotoPreview({
    super.key,
    this.size = 110,
    this.networkUrl,
    this.localFilePath,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocal = localFilePath != null && localFilePath!.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: ClipOval(
            child: hasLocal
                ? Image.file(File(localFilePath!), fit: BoxFit.cover, width: size, height: size)
                : CustomImage(
                    image: networkUrl ?? '',
                    height: size,
                    width: size,
                    fit: BoxFit.cover,
                    placeholder: Images.userPlaceHolder,
                  ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onPick,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}
