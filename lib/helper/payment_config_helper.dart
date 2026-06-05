import 'package:demandium_provider/common/model/config_model.dart';
import 'package:demandium_provider/feature/splash/controller/splash_controller.dart';
import 'package:get/get.dart';

class PaymentConfigHelper {
  static List<DigitalPaymentMethod> enabledDigitalPaymentGateways() {
    final gateways = Get.find<SplashController>().configModel.content?.paymentMethodList ?? [];
    return gateways.where(_isEnabledOnlineGateway).toList();
  }

  static bool _isEnabledOnlineGateway(DigitalPaymentMethod method) {
    final gateway = (method.gateway ?? '').trim().toLowerCase();
    if (gateway.isEmpty || gateway == 'offline') {
      return false;
    }
    if (method.isActive != null && method.isActive != 1) {
      return false;
    }
    return true;
  }
}
