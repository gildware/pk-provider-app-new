import 'package:demandium_provider/util/core_export.dart';

class ValidationHelper {

  /// Returns a validated phone for display, or the raw value when parsing fails.
  static String getDisplayPhone(String number, {bool withCountryCode = false}) {
    final valid = getValidPhone(number, withCountryCode: withCountryCode);
    if (valid.isNotEmpty) return valid;
    return number.trim();
  }

  static String getValidPhone(String number, {bool withCountryCode = false}) {
    bool isValid = false;
    String phone = "";

    try{
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      isValid = phoneNumber.isValid(type: PhoneNumberType.mobile);
      if(isValid){
        phone =  withCountryCode ? "+${phoneNumber.countryCode}${phoneNumber.nsn}" : phoneNumber.nsn.toString();
        if (kDebugMode) {
          print("Phone Number : $phone");
        }
      }
    }catch(e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return phone;
  }

  static String getCountryCode(String number, {bool withCountryCode = false}) {
    bool isValid = false;
    String countryCode = "";

    try{
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      isValid = phoneNumber.isValid(type: PhoneNumberType.mobile);
      if(isValid){
        countryCode = "+${phoneNumber.countryCode}";
        if (kDebugMode) {
          print("Country Code : $countryCode");
        }
      }
    }catch(e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return countryCode;
  }

  static String getValidCountryCode(String number, {bool withCountryCode = false}) {
    bool isValid = false;
    String countryCode = "";

    try{
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      isValid = phoneNumber.isValid(type: PhoneNumberType.mobile);
      if(isValid){
        countryCode = "+${phoneNumber.countryCode.toString()}";
      }
    }catch(e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return countryCode;
  }


}
