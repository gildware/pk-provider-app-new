import 'package:demandium_provider/feature/booking_details/model/bookings_details_model.dart';
import 'package:demandium_provider/feature/location/model/address_format.dart';

class AddressParseHelper {
  static bool _isPlusCode(String value) {
    return RegExp(r'^[A-Z0-9]{4}\+[A-Z0-9]{2,3}$', caseSensitive: false).hasMatch(value.trim());
  }

  static void applyComponents(ServiceAddress address, List<AddressComponents>? components) {
    if (components == null) return;

    String? sublocality;
    String? locality;
    String? adminLevel2;
    String? route;
    String? streetNumber;
    String? postalCode;
    String? country;

    for (final element in components) {
      final types = element.types;
      if (types == null) continue;

      if (types.contains('country')) {
        country = element.longName;
      }
      if (types.contains('postal_code')) {
        postalCode = element.longName;
      }
      if (types.contains('locality') && types.contains('political')) {
        locality = element.longName;
      }
      if (types.contains('administrative_area_level_2') && types.contains('political')) {
        adminLevel2 ??= element.longName;
      }
      if ((types.contains('sublocality') ||
              types.contains('sublocality_level_1') ||
              types.contains('neighborhood')) &&
          types.contains('political')) {
        sublocality ??= element.longName;
      }
      if (types.contains('street_number')) {
        streetNumber = element.longName;
      }
      if (types.contains('route')) {
        route = element.longName;
      }
    }

    if (country?.isNotEmpty == true) address.country = country;
    if (postalCode?.isNotEmpty == true) address.zipCode = postalCode;
    if (locality?.isNotEmpty == true) {
      address.city = locality;
    } else if (adminLevel2?.isNotEmpty == true) {
      address.city = adminLevel2;
    }

    final streetParts = <String>[];
    if (streetNumber?.isNotEmpty == true) streetParts.add(streetNumber!);
    if (route?.isNotEmpty == true) streetParts.add(route!);
    if (streetParts.isEmpty && sublocality?.isNotEmpty == true) {
      streetParts.add(sublocality!);
    }
    if (streetParts.isNotEmpty) {
      address.street = streetParts.join(' ');
    }
  }

  static String resolveTown(ServiceAddress address) {
    final streetParts = <String>[];
    if (address.house?.trim().isNotEmpty == true) streetParts.add(address.house!.trim());
    if (address.street?.trim().isNotEmpty == true) streetParts.add(address.street!.trim());
    if (streetParts.isNotEmpty) return streetParts.join(' ');
    return '';
  }

  static Map<String, String> parseFormattedAddress(String address) {
    final parts = address.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final result = <String, String>{'town': '', 'city': '', 'pincode': ''};
    if (parts.isEmpty) return result;

    if (RegExp(r'^\d{4,10}$').hasMatch(parts.last)) {
      result['pincode'] = parts.removeLast();
    }

    if (parts.isEmpty) return result;

    if (parts.length >= 2) {
      result['city'] = parts.removeLast();
    }

    final townParts = parts.where((part) => !_isPlusCode(part)).toList();
    if (townParts.isNotEmpty) {
      result['town'] = townParts.join(', ');
    }

    return result;
  }

  static void applyToFields({
    required ServiceAddress address,
    required void Function(String town, String city, String pincode, String formatted) onApply,
  }) {
    final formatted = address.address?.trim() ?? '';
    var town = resolveTown(address);
    var city = address.city?.trim() ?? '';
    var pincode = address.zipCode?.trim() ?? '';

    if (formatted.isNotEmpty && (town.isEmpty || city.isEmpty || pincode.isEmpty)) {
      final parsed = parseFormattedAddress(formatted);
      if (town.isEmpty) town = parsed['town'] ?? '';
      if (city.isEmpty) city = parsed['city'] ?? '';
      if (pincode.isEmpty) pincode = parsed['pincode'] ?? '';
    }

    onApply(town, city, pincode, formatted);
  }
}
