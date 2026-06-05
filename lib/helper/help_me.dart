import 'package:demandium_provider/util/core_export.dart';

const kLogTag = "[demandium]";
const kLogEnable = true;
DateTime? loginClickTime;

void printLog(dynamic data) {
  if (kLogEnable) {
    if (kDebugMode) {
      print("$kLogTag${data.toString()}");
    }
  }
}

bool isRedundentClick(DateTime currentTime){
  if(loginClickTime==null){
    loginClickTime = currentTime;
    return false;
  }
  if(currentTime.difference(loginClickTime!).inSeconds<3){//set this difference time in seconds
    return true;
  }

  loginClickTime = currentTime;
  return false;
}