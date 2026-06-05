import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class ShowcaseController extends GetxController implements GetxService {
  final ShowcaseRepo showcaseRepo;
  ShowcaseController({required this.showcaseRepo});

  List<ProviderShowcaseItem>? _items;
  List<ProviderShowcaseItem>? get items => _items;

  String _approvalFilter = 'all';
  String get approvalFilter => _approvalFilter;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedMediaType = 'image';
  String get selectedMediaType => _selectedMediaType;

  XFile? _pickedMedia;
  XFile? get pickedMedia => _pickedMedia;

  String? _networkMediaUrl;
  String? get networkMediaUrl => _networkMediaUrl;

  VideoPlayerController? videoPlayerController;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  ProviderShowcaseItem? _editingItem;
  ProviderShowcaseItem? get editingItem => _editingItem;

  void setApprovalFilter(String filter) {
    if (_approvalFilter == filter) return;
    _approvalFilter = filter;
    getShowcaseList(reload: true);
  }

  Future<void> getShowcaseList({bool reload = false}) async {
    if (_items != null && !reload) return;
    _isLoading = true;
    update();
    final statusParam = _approvalFilter == 'all' ? null : _approvalFilter;
    Response response = await showcaseRepo.getShowcaseList(approvalStatus: statusParam);
    if (response.statusCode == 200) {
      _items = [];
      if (response.body['content'] != null) {
        response.body['content'].forEach((item) {
          _items!.add(ProviderShowcaseItem.fromJson(item));
        });
      }
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  void initForm({ProviderShowcaseItem? item}) {
    _editingItem = item;
    titleController.text = item?.title ?? '';
    descriptionController.text = item?.description ?? '';
    _selectedMediaType = item?.mediaType ?? 'image';
    _pickedMedia = null;
    _networkMediaUrl = item?.displayMediaUrl;
    if (item?.isVideo == true && _networkMediaUrl != null && _networkMediaUrl!.isNotEmpty) {
      initializeVideoPlayerForNetwork();
    }
    update();
  }

  void resetForm() {
    _editingItem = null;
    titleController.clear();
    descriptionController.clear();
    _selectedMediaType = 'image';
    clearMedia();
    update();
  }

  void setMediaType(String type) {
    if (_selectedMediaType == type) return;
    _selectedMediaType = type;
    clearMedia();
    update();
  }

  void clearMedia() {
    _pickedMedia = null;
    _networkMediaUrl = null;
    if (videoPlayerController != null && videoPlayerController!.value.isInitialized) {
      videoPlayerController!.dispose();
      videoPlayerController = null;
    }
    update();
  }

  Future<void> pickMedia() async {
    if (_selectedMediaType == 'video') {
      _pickedMedia = await FileValidationHelper.validateAndPickVideo(source: ImageSource.gallery);
      if (_pickedMedia != null) {
        _networkMediaUrl = null;
        initializeVideoPlayerForPicked();
        update();
      }
    } else {
      _pickedMedia = await FileValidationHelper.validateAndPickImage(source: ImageSource.gallery);
      if (_pickedMedia != null) {
        _networkMediaUrl = null;
        update();
      }
    }
  }

  void initializeVideoPlayerForPicked() {
    if (_pickedMedia == null) return;
    if (videoPlayerController != null && videoPlayerController!.value.isInitialized) {
      videoPlayerController!.dispose();
    }
    videoPlayerController = VideoPlayerController.file(File(_pickedMedia!.path))
      ..initialize().then((_) => update());
  }

  void initializeVideoPlayerForNetwork() {
    if (_networkMediaUrl == null || _networkMediaUrl!.isEmpty) return;
    if (videoPlayerController != null && videoPlayerController!.value.isInitialized) {
      videoPlayerController!.dispose();
    }
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(_networkMediaUrl!))
      ..initialize().then((_) => update());
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    if (videoPlayerController != null) {
      videoPlayerController!.dispose();
    }
    super.onClose();
  }

  Future<bool> saveItem() async {
    final hasMedia = _pickedMedia != null || (_editingItem != null && _networkMediaUrl != null);
    if (!hasMedia) {
      showCustomSnackBar('please_select_media'.tr, type: ToasterMessageType.error);
      return false;
    }

    _isLoading = true;
    update();

    final body = <String, String>{
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'media_type': _selectedMediaType,
    };

    Response response;
    if (_editingItem != null) {
      response = await showcaseRepo.updateShowcaseItem(
        _editingItem!.id!,
        body,
        media: _pickedMedia != null ? MultipartBody('media', _pickedMedia!) : null,
      );
    } else {
      response = await showcaseRepo.addShowcaseItem(
        body,
        MultipartBody('media', _pickedMedia!),
      );
    }

    _isLoading = false;
    bool success = false;
    if (response.statusCode == 200) {
      success = true;
      showCustomSnackBar(
        'showcase_submitted_for_review'.tr,
        type: ToasterMessageType.success,
      );
      await getShowcaseList(reload: true);
      resetForm();
      Get.back();
    } else {
      ApiChecker.checkApi(response);
    }
    update();
    return success;
  }

  Future<void> deleteItem(String id) async {
    _isLoading = true;
    update();
    Response response = await showcaseRepo.deleteShowcaseItem(id);
    _isLoading = false;
    if (response.statusCode == 200) {
      showCustomSnackBar('showcase_deleted_successfully'.tr, type: ToasterMessageType.success);
      await getShowcaseList(reload: true);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }
}
