import 'package:demandium_provider/util/core_export.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingOverlayWidget extends StatelessWidget {
  /// The content to display beneath the loading overlay
  final Widget child;

  /// Whether to show the loading overlay
  final bool isLoading;

  /// The color of the overlay background
  /// Defaults to semi-transparent black (0.3 opacity)
  final Color? overlayColor;

  /// The color of the loading animation
  /// Defaults to the theme's primary color
  final Color? loaderColor;

  /// The size of the loading animation
  /// Defaults to 50.0
  final double loaderSize;

  /// Optional custom loading widget to display instead of InkDrop animation
  ///
  /// Example:
  /// ```dart
  /// customLoadingWidget: YourCustomLoader()
  /// ```
  final Widget? customLoadingWidget;

  const LoadingOverlayWidget({
    super.key,
    required this.child,
    required this.isLoading,
    this.overlayColor,
    this.loaderColor,
    this.loaderSize = 50.0,
    this.customLoadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        child,

        // Loading overlay
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: overlayColor ?? Theme.of(context).textTheme.titleLarge?.color?.withValues(alpha: 0.1),
              child: Center(
                child: customLoadingWidget ??
                    LoadingAnimationWidget.fourRotatingDots(

                      size: loaderSize, color: Theme.of(context).primaryColor,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}
