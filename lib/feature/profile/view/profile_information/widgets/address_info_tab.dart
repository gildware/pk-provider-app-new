import 'package:demandium_provider/feature/profile/view/profile_information/widgets/profile_address_form.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class AddressInfoTab extends StatefulWidget {
  const AddressInfoTab({super.key});

  @override
  State<AddressInfoTab> createState() => _AddressInfoTabState();
}

class _AddressInfoTabState extends State<AddressInfoTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<UserProfileController>().syncAddressFieldsFromProvider();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(builder: (c) {
      return Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Form(
          key: c.addressFormKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trLabel('address_information'), style: robotoBold),
                      Text(
                        trLabel('address_hint'),
                        style: robotoLight.copyWith(fontSize: Dimensions.fontSizeSmall),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      const ProfileAddressForm(),
                    ],
                  ),
                ),
              ),
              CustomButton(
                btnTxt: trLabel('save'),
                isLoading: c.isLoading,
                onPressed: () => _save(c),
              ),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom > 0
                    ? MediaQuery.of(context).padding.bottom
                    : 12,
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _save(UserProfileController c) async {
    if (!c.addressFormKey.currentState!.validate()) return;

    final formattedAddress = c.buildFormattedAddress();
    if (formattedAddress.isEmpty) {
      showCustomSnackBar(trLabel('enter_address'));
      return;
    }

    final identityNumber =
        c.providerModel?.content?.providerInfo?.owner?.identificationNumber ?? '';
    final status = await c.updateProfile(
      address: formattedAddress,
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
