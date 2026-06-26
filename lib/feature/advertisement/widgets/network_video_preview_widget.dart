import 'dart:ui';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class NetworkVideoPreviewWidget extends StatefulWidget {
  final String videoFile;
  const NetworkVideoPreviewWidget({super.key, required this.videoFile});

  @override
  State<NetworkVideoPreviewWidget> createState() => _NetworkVideoPreviewWidgetState();
}

class _NetworkVideoPreviewWidgetState extends State<NetworkVideoPreviewWidget> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    final url = widget.videoFile.trim();
    if (url.isEmpty) {
      _loadFailed = true;
      return;
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = controller;
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: controller,
          autoInitialize: true,
          aspectRatio: controller.value.aspectRatio,
        );
      });
    }).catchError((_) {
      controller.dispose();
      if (mounted) {
        setState(() {
          _controller = null;
          _loadFailed = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadFailed) {
      return const SizedBox(
        height: 220,
        width: double.infinity,
        child: VideoPlaceholder(),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized || _chewieController == null) {
      return SizedBox(
        height: 220,
        child: Shimmer(
          duration: const Duration(seconds: 2),
          child: Container(
            width: Get.width,
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: VideoPlayer(_controller!),
            ),
          ),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(
                color: Colors.black.withValues(alpha: 0.85),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: Chewie(controller: _chewieController!),
          ),
        ],
      ),
    );
  }
}
