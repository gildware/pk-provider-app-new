import 'package:demandium_provider/feature/settings/business/widget/business_info_tab_item_widget.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class CompanyInfoTab extends StatefulWidget {
  const CompanyInfoTab({super.key});

  @override
  State<CompanyInfoTab> createState() => _CompanyInfoTabState();
}

class _CompanyInfoTabState extends State<CompanyInfoTab> {
  final FocusNode _companyNameFocus = FocusNode();
  final FocusNode _companyPhoneFocus = FocusNode();
  final FocusNode _companyEmailFocus = FocusNode();
  final TextEditingController _unusedAddressController = TextEditingController();

  @override
  void dispose() {
    _unusedAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(builder: (c) {
      return Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Form(
          key: c.companyInfoFormKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trLabel('company_information'), style: robotoBold),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      BasicInfoWidget(
                        companyNameFocus: _companyNameFocus,
                        companyPhoneFocus: _companyPhoneFocus,
                        companyEmailFocus: _companyEmailFocus,
                        companyAddressFocus: FocusNode(),
                        companyAddressController: _unusedAddressController,
                        showZonePicker: false,
                        showAddressSection: false,
                        companyEmailOptional: true,
                      ),
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
    if (!c.companyInfoFormKey.currentState!.validate()) return;

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
