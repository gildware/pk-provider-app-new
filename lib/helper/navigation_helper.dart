import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/helper/route_helper.dart';

/// Defers [action] until after the current frame so Navigator is not locked.
void runAfterFrame(void Function() action) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    action();
  });
}

bool canPopRoute([BuildContext? context]) {
  final navContext = context ?? Get.context;
  return navContext != null && Navigator.canPop(navContext);
}

/// Pops the current route when possible; otherwise runs [whenCannotPop].
void popRouteOr(void Function() whenCannotPop, {BuildContext? context}) {
  if (canPopRoute(context)) {
    Get.back();
    return;
  }
  whenCannotPop();
}

/// Pops the current route when possible; otherwise returns to the app home.
void popRouteOrGoHome({BuildContext? context}) {
  popRouteOr(
    () => Get.offAllNamed(RouteHelper.getInitialRoute()),
    context: context,
  );
}

/// Handles notification deep-links: [whenFromNotification] when opened from a push.
void handleNotificationBack({
  required bool fromNotification,
  required VoidCallback whenFromNotification,
  BuildContext? context,
  VoidCallback? whenCannotPop,
}) {
  if (fromNotification) {
    whenFromNotification();
    return;
  }
  popRouteOr(
    whenCannotPop ?? () => Get.offAllNamed(RouteHelper.getInitialRoute()),
    context: context,
  );
}
