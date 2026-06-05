import 'package:demandium_provider/util/dimensions.dart';
import 'package:flutter/material.dart';

/// A reusable circular icon button with optional indicator dot
class CircularIconButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final double iconSize;
  final bool showIndicator;
  final Color? indicatorColor;
  final Color? backgroundColor;

  const CircularIconButtonWidget({
    super.key,
    required this.icon,
    this.onTap,
    this.iconColor,
    this.iconSize = 22,
    this.showIndicator = false,
    this.indicatorColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor ?? Colors.white,
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
            ),
            padding: const EdgeInsets.all(5),
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? Theme.of(context).primaryColor,
            ),
          ),
        ),
        if (showIndicator)
          Positioned(
            right: 5,
            top: 5,
            child: Icon(
              Icons.circle,
              size: 10,
              color: indicatorColor ?? Theme.of(context).colorScheme.error,
            ),
          ),
      ],
    );
  }
}
