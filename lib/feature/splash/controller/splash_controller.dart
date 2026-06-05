import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class SplashController extends GetxController implements GetxService {
  final SplashRepo splashRepo;
  SplashController({required this.splashRepo});




  ConfigModel _configModel = ConfigModel();
  bool _firstTimeConnectionCheck = true;
  bool _hasConnection = true;

  ConfigModel get configModel => _configModel;
  DateTime get currentTime => DateTime.now();
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;
  bool get hasConnection => _hasConnection;

  bool _showCustomBookingButton = false;
  bool get showCustomBookingButton => _showCustomBookingButton;

  bool _showRedDotIconForCustomBooking = false;
  bool get showRedDotIconForCustomBooking => _showRedDotIconForCustomBooking;

  Future<bool> getConfigData() async {
    _hasConnection = true;
    Response response = await splashRepo.getConfigData();
    bool isSuccess = false;
    if(response.statusCode == 200) {
      _configModel = ConfigModel.fromJson(response.body);
      if(_configModel.content?.maintenanceMode?.maintenanceStatus == 1 && _configModel.content?.maintenanceMode?.selectedMaintenanceSystem?.providerApp == 1 && !AppConstants.avoidMaintenanceMode){
        if(!Get.currentRoute.contains(RouteHelper.maintenanceRoute)){
          Get.offAllNamed(RouteHelper.getMaintenanceRoute());
          Get.find<AuthController>().unsubscribeToken();
        }
      } else if((Get.currentRoute.contains(RouteHelper.maintenanceRoute) &&  (_configModel.content?.maintenanceMode?.maintenanceStatus == 0 || _configModel.content?.maintenanceMode?.selectedMaintenanceSystem?.providerApp == 0))){
        Get.offAllNamed(RouteHelper.getInitialRoute());
      }
      else if(_configModel.content?.maintenanceMode?.maintenanceStatus == 0){
        if(_configModel.content?.maintenanceMode?.selectedMaintenanceSystem?.providerApp == 1){
          if(_configModel.content?.maintenanceMode?.maintenanceTypeAndDuration?.maintenanceDuration == 'customize'){

            DateTime now = DateTime.now();
            DateTime specifiedDateTime = DateTime.parse(_configModel.content!.maintenanceMode!.maintenanceTypeAndDuration!.startDate!);

            Duration difference = specifiedDateTime.difference(now);

            if(difference.inMinutes > 0 && (difference.inMinutes < 60 || difference.inMinutes == 60)){
              _startTimer(specifiedDateTime);
            }
          }
        }
      }
      isSuccess = true;
    }else {
      ApiChecker.checkApi(response);
      if(response.statusText == ApiClient.noInternetMessage) {
        _hasConnection = false;
      }
      isSuccess = false;
    }
    update();
    return isSuccess;
  }

  void _startTimer (DateTime startTime){
    Timer.periodic(const Duration(seconds: 30), (Timer timer){
      DateTime now = DateTime.now();
      if (now.isAfter(startTime) || now.isAtSameMomentAs(startTime)) {
        timer.cancel();
        Get.offAllNamed(RouteHelper.getMaintenanceRoute());
        Get.find<AuthController>().unsubscribeToken();
      }
    });
  }


  void updateCustomBookingRedDotButtonStatus({required bool status, bool shouldUpdate = true }){
    _showRedDotIconForCustomBooking = status;

    Future.delayed(const Duration(milliseconds: 200), (){
      if(shouldUpdate){
        update();
      }
    });
  }

  void updateCustomBookingButtonStatus({bool shouldUpdate = true, bool fromCustomBookingScreen = false}){

    _showCustomBookingButton = true;
    if(shouldUpdate){
      update();
    }

    
    Future.delayed(const Duration(seconds: 10), (){
      _showCustomBookingButton = false;
      if(shouldUpdate){
        update();
      }
    });


  }

  Future<bool> initSharedData() {
    return splashRepo.initSharedData();
  }

  bool showInitialLanguageScreen() {
    return splashRepo.showInitialLanguageScreen();
  }

  void disableShowInitialLanguageScreen() {
    splashRepo.disableShowInitialLanguageScreen();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

  Future<void> updateLanguage(bool isInitial) async {
    Response response = await splashRepo.updateLanguage();

    if(!isInitial){
     if(response.statusCode == 200 && response.body['response_code'] == "default_200"){

     }else{
       showCustomSnackBar("${response.body['message']}");
     }
   }

  }
}
