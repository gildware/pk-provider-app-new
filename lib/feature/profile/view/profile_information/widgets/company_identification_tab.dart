import 'package:demandium_provider/feature/profile/view/profile_information/widgets/company_identity_info_widget.dart';
import 'package:demandium_provider/feature/settings/business/controller/company_identity_controller.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class CompanyIdentificationTab extends StatefulWidget {
  const CompanyIdentificationTab({super.key});

  @override
  State<CompanyIdentificationTab> createState() => _CompanyIdentificationTabState();
}

class _CompanyIdentificationTabState extends State<CompanyIdentificationTab> {
  final FocusNode _identityNumberFocus = FocusNode();
  String? _lastSyncedProviderId;

  void _syncFieldsFromProvider() {
    final info = Get.find<UserProfileController>().providerModel?.content?.providerInfo;
    if (info == null) return;
    Get.find<UserProfileController>().companyIdentityNumberController!.text =
        info.companyIdentityNumber ?? '';
    Get.find<CompanyIdentityController>().loadFromProvider(info);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(builder: (c) {
      final providerId = c.providerModel?.content?.providerInfo?.id;
      if (providerId != null && providerId != _lastSyncedProviderId) {
        _lastSyncedProviderId = providerId;
        WidgetsBinding.instance.addPostFrameCallback((_) => _syncFieldsFromProvider());
      }
      return Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: CompanyIdentityInfoWidget(
                  identityNumberController: c.companyIdentityNumberController!,
                  identityNumberFocus: _identityNumberFocus,
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
      );
    });
  }

  Future<void> _save(UserProfileController c) async {
    final address = c.buildFormattedAddress().isNotEmpty
        ? c.buildFormattedAddress()
        : (c.providerModel?.content?.providerInfo?.companyAddress ?? '');
    final status = await c.updateProfile(
      address: address,
      identityNumber: c.providerModel?.content?.providerInfo?.owner?.identificationNumber ?? '',
      validateContactIdentity: false,
      validateCompanyIdentity: true,
      requireContactPhoto: false,
    );
    if (status.isSuccess!) {
      showCustomSnackBar(trLabel('profile_updated_successfully'), type: ToasterMessageType.success);
    } else {
      showCustomSnackBar(status.message);
    }
  }
}
