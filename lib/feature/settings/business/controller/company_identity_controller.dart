import 'package:demandium_provider/feature/profile/model/provider_model.dart';
import 'package:demandium_provider/feature/settings/business/model/picked_identity_image_model.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class CompanyIdentityController extends GetxController implements GetxService {
  String? _selectedCompanyIdentityType;
  String? get selectedCompanyIdentityType => _selectedCompanyIdentityType;

  List<PickedIdentityImageModel?>? _replacedIdentityImages;
  List<PickedIdentityImageModel?>? get replacedIdentityImages => _replacedIdentityImages;

  List<XFile?>? _identityImages;
  List<XFile?>? get identityImages => _identityImages;

  List<String?> _currentIdentityImages = [];
  List<String?> get currentIdentityImages => _currentIdentityImages;

  List<String?> _deletedIdentityImages = [];
  List<String?> get deletedIdentityImages => _deletedIdentityImages;

  void onChangeIdentityType(String? type, {bool isUpdate = true}) {
    _selectedCompanyIdentityType = type;
    if (isUpdate) {
      update();
    }
  }

  void initializeCurrentImage(List<String?> currentImages, {bool notify = true}) {
    _currentIdentityImages = currentImages
        .map((e) => e?.trim())
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toList();
    if (notify) {
      update();
    }
  }

  void removeCurrentImage(int index) {
    _deletedIdentityImages.add(_currentIdentityImages[index]);
    _currentIdentityImages.removeAt(index);
    initializeCurrentImage(_currentIdentityImages);
    update();
  }

  void identityImagePickInitialize({bool notify = true}) {
    _identityImages = [];
    _deletedIdentityImages = [];
    _replacedIdentityImages =
        List.generate(_currentIdentityImages.length, (index) => null, growable: true);
    if (notify) {
      update();
    }
  }

  void loadFromProvider(ProviderInfo? info) {
    if (info == null) return;
    onChangeIdentityType(info.companyIdentityType, isUpdate: false);
    initializeCurrentImage(info.companyIdentityImagesFullPath ?? [], notify: false);
    identityImagePickInitialize(notify: true);
  }

  void pickIdentityImage({int? index, bool isRemoved = false}) async {
    if (isRemoved) {
      _identityImages?.removeAt(index!);
    } else {
      final pickedImage = await FileValidationHelper.validateAndPickImage(
        source: ImageSource.gallery,
        maxSizeInBytes: AppConstants.registrationCompanyIdentityMaxBytes,
      );
      if (pickedImage != null) {
        if (index != null) {
          _identityImages?[index] = pickedImage;
        } else {
          _identityImages?.add(pickedImage);
        }
      }
    }
    update();
  }

  void onReplacePickIdentityImage({required int index, bool isRemoved = false}) async {
    if (isRemoved) {
      _replacedIdentityImages?[index] = null;
    } else {
      final pickedImage = await FileValidationHelper.validateAndPickImage(
        source: ImageSource.gallery,
        maxSizeInBytes: AppConstants.registrationCompanyIdentityMaxBytes,
      );
      if (pickedImage != null) {
        _replacedIdentityImages?[index] = PickedIdentityImageModel(
          imageFile: pickedImage,
          imageUrl: _currentIdentityImages[index],
        );
      }
    }
    update();
  }

  List<XFile> getUploadedImageFiles() => [
        for (final image in _replacedIdentityImages ?? [])
          if (image?.imageFile != null) image!.imageFile!,
        ...?_identityImages?.whereType<XFile>(),
      ];

  List<String> getDeletedImageUrls() {
    for (int i = 0; i < (_replacedIdentityImages?.length ?? 0); i++) {
      if (_replacedIdentityImages != null && _replacedIdentityImages![i] != null) {
        _deletedIdentityImages.add(_replacedIdentityImages![i]!.imageUrl);
      }
    }

    return _deletedIdentityImages
        .whereType<String>()
        .map((url) => url.split('/').last)
        .toList();
  }

  bool isUploadEmpty() =>
      _currentIdentityImages.isEmpty && getUploadedImageFiles().isEmpty;
}
