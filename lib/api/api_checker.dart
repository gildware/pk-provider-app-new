import 'package:get/get.dart';
import '../util/core_export.dart';

class ApiChecker {
  static void checkApi(Response response) {

    bool isAppNotActive = response.statusCode == 503 && '${response.body['code']}'.contains('activation-503');

    if(response.statusCode == 401 || isAppNotActive) {
      _executeUnAuthorized(response, isAppNotActive ? response.body['message'] : response.statusText);

    }else if(response.statusCode == 500){
      showCustomSnackBar(response.statusText);

    }else {
      if( response.body != null && response.body['message'] !=null){
        showCustomSnackBar(response.body['message']);
      }else{
        showCustomSnackBar(response.statusText);
      }
    }
  }

  static void _executeUnAuthorized(Response response, String? errorMessage) {
    Get.find<AuthController>().clearSharedData();
    Get.find<UserProfileController>().clearUserProfileData();
    if(Get.currentRoute!=RouteHelper.getSignInRoute('splash')){
      Get.offAllNamed(RouteHelper.getSignInRoute('splash'));
      Get.find<AuthController>().clearSharedData();

      showCustomSnackBar(errorMessage);

    }
  }
}