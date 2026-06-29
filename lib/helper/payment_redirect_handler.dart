import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class PaymentRedirectHandler {
  static void handlePaymentResult({
    required String fromPage,
    required String flag,
    String? token,
    bool closeCurrentRoute = false,
  }) {
    final isSuccess = flag.contains('success');
    final isFailed = flag.contains('fail') || flag.contains('cancel');

    if (!isSuccess && !isFailed) {
      return;
    }

    if (isSuccess) {
      _handleSuccess(fromPage, token, closeCurrentRoute);
      return;
    }

    _handleFailure(fromPage, closeCurrentRoute);
  }

  static void handleRedirectUrl({
    required String fromPage,
    required String url,
    bool closeCurrentRoute = false,
  }) {
    if (!url.contains(ApiUrlHelper.resolveBaseUrl()) || !url.contains('flag')) {
      return;
    }

    final isSuccess = url.contains('success');
    final isFailed = url.contains('fail');
    final isCancel = url.contains('cancel');

    if (!isSuccess && !isFailed && !isCancel) {
      return;
    }

    final token = isSuccess ? StringParser.parseString(url, 'token') : null;
    handlePaymentResult(
      fromPage: fromPage,
      flag: isSuccess ? 'success' : 'fail',
      token: token,
      closeCurrentRoute: closeCurrentRoute,
    );
  }

  static void _handleSuccess(
    String fromPage,
    String? token,
    bool closeCurrentRoute,
  ) {
    if (fromPage == 'signUp') {
      Get.offAllNamed(RouteHelper.signIn);
      showCustomBottomSheet(
        child: const WelcomeBottomSheet(fromSignup: true),
      );
      return;
    }

    if (closeCurrentRoute) {
      Get.back();
    }

    Future.delayed(const Duration(seconds: 1), () {
      Get.find<UserProfileController>().getProviderInfo(reload: true);
      showCustomSnackBar(
        'paid_successfully'.tr,
        type: ToasterMessageType.success,
      );
    });
  }

  static void _handleFailure(String fromPage, bool closeCurrentRoute) {
    if (closeCurrentRoute) {
      Get.back();
    }

    if (fromPage == 'signUp') {
      Get.offAllNamed(RouteHelper.signIn);
      showCustomBottomSheet(
        child: const WelcomeBottomSheet(
          fromSignup: true,
          isFromTransactionFailed: true,
        ),
      );
      return;
    }

    showCustomSnackBar('transaction_failed'.tr);
  }
}
