import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class ProfileAddressForm extends StatefulWidget {
  const ProfileAddressForm({super.key});

  @override
  State<ProfileAddressForm> createState() => _ProfileAddressFormState();
}

class _ProfileAddressFormState extends State<ProfileAddressForm> {
  late final TextEditingController _mapSearchController;

  @override
  void initState() {
    super.initState();
    _mapSearchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncMapHint());
  }

  @override
  void dispose() {
    _mapSearchController.dispose();
    super.dispose();
  }

  void _syncMapHint() {
    final c = Get.find<UserProfileController>();
    final formatted = c.buildFormattedAddress();
    final company = c.providerModel?.content?.providerInfo?.companyAddress ?? '';
    final hint = formatted.isNotEmpty ? formatted : company;
    if (_mapSearchController.text != hint) {
      _mapSearchController.text = hint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      builder: (userProfileController) {
        return GetBuilder<LocationController>(builder: (locationController) {
          final savedAddress = userProfileController.buildFormattedAddress();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (savedAddress.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.place_outlined, color: Theme.of(context).primaryColor, size: 20),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Text(savedAddress, style: robotoRegular),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
              ],
              GestureDetector(
                onTap: () => _openMap(userProfileController, locationController),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _mapSearchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      hintText: trLabel('search_your_address'),
                      suffixIcon: const Icon(Icons.my_location),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text(trLabel('address_details'), style: robotoBold),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              RegistrationIconField(
                icon: Icons.signpost_outlined,
                titleKey: 'town',
                hintKey: 'town_hint',
                controller: userProfileController.streetController!,
                onValidate: (v) =>
                    (v == null || v.isEmpty) ? trLabel('town_hint') : null,
              ),
              RegistrationIconField(
                icon: Icons.location_city_outlined,
                titleKey: 'city',
                hintKey: 'city_hint',
                controller: userProfileController.cityController!,
                onValidate: (v) =>
                    (v == null || v.isEmpty) ? trLabel('city_hint') : null,
              ),
              RegistrationIconField(
                icon: Icons.pin_outlined,
                titleKey: 'pincode',
                hintKey: 'pincode_hint',
                controller: userProfileController.pincodeController!,
                inputType: TextInputType.number,
                onValidate: (v) =>
                    (v == null || v.isEmpty) ? trLabel('pincode_hint') : null,
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _openMap(
    UserProfileController userProfileController,
    LocationController locationController,
  ) async {
    final defaultLatLng =
        Get.find<SplashController>().configModel.content?.defaultLocation?.defaultLocation;
    await Get.to(() => PickMapScreen(
          initialPosition: LatLng(
            userProfileController.providerModel?.content?.providerInfo?.coordinates?.latitude ??
                defaultLatLng?.lat ??
                23.777176,
            userProfileController.providerModel?.content?.providerInfo?.coordinates?.longitude ??
                defaultLatLng?.lon ??
                -90.399452,
          ),
          initialAddress:
              userProfileController.providerModel?.content?.providerInfo?.companyAddress,
        ));
    final address = locationController.pickAddress.address ?? '';
    if (address.isNotEmpty) {
      userProfileController.syncAddressFromMap(address);
      _mapSearchController.text = address;
    }
  }
}
