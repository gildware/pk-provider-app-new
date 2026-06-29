import 'package:flutter/material.dart';

/// Keeps dialog content visible above the software keyboard.
class KeyboardAwareDialogShell extends StatelessWidget {
  final Widget child;

  const KeyboardAwareDialogShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewInsets = mediaQuery.viewInsets;
    final padding = mediaQuery.padding;
    const horizontalInset = 20.0;
    const verticalInset = 24.0;
    final keyboardOpen = viewInsets.bottom > 0;

    final maxHeight = mediaQuery.size.height
        - viewInsets.bottom
        - padding.top
        - padding.bottom
        - (verticalInset * 2);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        left: horizontalInset + padding.left,
        right: horizontalInset + padding.right,
        top: verticalInset + padding.top,
        bottom: verticalInset + viewInsets.bottom + padding.bottom,
      ),
      child: MediaQuery.removeViewInsets(
        removeBottom: true,
        context: context,
        child: Align(
          alignment: keyboardOpen ? Alignment.topCenter : Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: maxHeight > 0 ? maxHeight : mediaQuery.size.height * 0.9,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
