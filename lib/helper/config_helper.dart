import 'package:country_code_picker/country_code_picker.dart';
import 'package:demandium_provider/common/model/config_model.dart';
import 'package:demandium_provider/feature/splash/controller/splash_controller.dart';
import 'package:get/get.dart';

class ConfigHelper {
  static ConfigContent? get content => Get.find<SplashController>().configModel.content;

  static String get defaultCountryDialCode {
    final countryCode = content?.countryCode ?? 'BD';
    return CountryCode.fromCountryCode(countryCode).dialCode ?? '+880';
  }

  static String get logoFullPath => content?.logoFullPath ?? '';

  static int get paginationLimit {
    final limit = content?.paginationLimit;
    return (limit != null && limit > 0) ? limit : 10;
  }

  static int get currencyDecimalPoint {
    return int.tryParse(content?.currencyDecimalPoint ?? '2') ?? 2;
  }

  static String get defaultCommission => content?.defaultCommission ?? '0';

  static String? get maintenanceStartDate =>
      content?.maintenanceMode?.maintenanceTypeAndDuration?.startDate;
}
