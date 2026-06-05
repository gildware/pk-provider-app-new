import 'package:demandium_provider/feature/profile/view/profile_information/widgets/profile_zone_dropdown.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class ServiceZoneTabItemWidget extends StatefulWidget {
  const ServiceZoneTabItemWidget({super.key});

  @override
  State<ServiceZoneTabItemWidget> createState() => _ServiceZoneTabItemWidgetState();
}

class _ServiceZoneTabItemWidgetState extends State<ServiceZoneTabItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: GetBuilder<UserProfileController>(builder: (c) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trLabel('service_zones'), style: robotoBold),
            Text(
              trLabel('select_service_zones_hint'),
              style: robotoLight.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Expanded(child: SingleChildScrollView(child: const ProfileZoneDropdown())),
            CustomButton(
              btnTxt: trLabel('save'),
              isLoading: c.isLoading,
              onPressed: () => _save(c),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 12),
          ],
        );
      }),
    );
  }

  Future<void> _save(UserProfileController c) async {
    if (c.selectedZoneIds.isEmpty) {
      c.onProfileChangeValidationCheck();
      showCustomSnackBar(trLabel('select_at_least_one_zone'));
      return;
    }
    final address = c.buildFormattedAddress().isNotEmpty
        ? c.buildFormattedAddress()
        : (c.providerModel?.content?.providerInfo?.companyAddress ?? '');
    final identityNumber =
        c.providerModel?.content?.providerInfo?.owner?.identificationNumber ?? '';
    final status = await c.updateProfile(
      address: address,
      identityNumber: identityNumber,
      validateContactIdentity: false,
      requireContactPhoto: false,
    );
    if (status.isSuccess!) {
      showCustomSnackBar(trLabel('profile_updated_successfully'), type: ToasterMessageType.success);
    } else {
      showCustomSnackBar(status.message);
    }
  }
}
