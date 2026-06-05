import 'package:demandium_provider/feature/settings/business/controller/identity_controller.dart';
import 'package:demandium_provider/feature/settings/business/widget/identity_info_widget.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class ContactIdentificationTab extends StatefulWidget {
  const ContactIdentificationTab({super.key});

  @override
  State<ContactIdentificationTab> createState() => _ContactIdentificationTabState();
}

class _ContactIdentificationTabState extends State<ContactIdentificationTab> {
  final TextEditingController identityNumber = TextEditingController();
  final FocusNode identityNumberFocus = FocusNode();
  String? _lastSyncedProviderId;

  void _syncFieldsFromProvider() {
    final info = Get.find<UserProfileController>().providerModel?.content?.providerInfo;
    if (info == null) return;
    final idNum = info.owner?.identificationNumber ?? '';
    if (idNum.isNotEmpty) {
      identityNumber.text = idNum;
    }
    Get.find<IdentityController>().loadFromProvider(info);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(builder: (profileCtrl) {
      final providerId = profileCtrl.providerModel?.content?.providerInfo?.id;
      if (providerId != null && providerId != _lastSyncedProviderId) {
        _lastSyncedProviderId = providerId;
        WidgetsBinding.instance.addPostFrameCallback((_) => _syncFieldsFromProvider());
      }
      return _buildContent();
    });
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: IdentityInfoWidget(
                identityNumberController: identityNumber,
                identityNumberFocus: identityNumberFocus,
                identityTypeList: AppConstants.contactIdentityTypeList,
              ),
            ),
          ),
          GetBuilder<UserProfileController>(
            builder: (c) => CustomButton(
              btnTxt: trLabel('save'),
              isLoading: c.isLoading,
              onPressed: () => _save(c),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 12),
        ],
      ),
    );
  }

  Future<void> _save(UserProfileController c) async {
    if (Get.find<IdentityController>().isUploadEmpty()) {
      showCustomSnackBar(trLabel('please_update_identity_images'));
      return;
    }
    if (identityNumber.text.trim().isEmpty) {
      showCustomSnackBar(trLabel('enter_identity_number'));
      return;
    }
    final address = c.buildFormattedAddress().isNotEmpty
        ? c.buildFormattedAddress()
        : (c.providerModel?.content?.providerInfo?.companyAddress ?? '');
    final status = await c.updateProfile(
      address: address,
      identityNumber: identityNumber.text.trim(),
      validateContactIdentity: true,
      requireContactPhoto: false,
    );
    if (status.isSuccess!) {
      showCustomSnackBar(trLabel('profile_updated_successfully'), type: ToasterMessageType.success);
    } else {
      showCustomSnackBar(status.message);
    }
  }
}
