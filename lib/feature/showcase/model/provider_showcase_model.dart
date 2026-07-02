import 'package:demandium_provider/helper/mobile_app_icon_helper.dart';

class ProviderShowcaseItem {
  String? id;
  String? providerId;
  String? title;
  String? description;
  String? mediaType;
  String? fileName;
  String? mediaFullPath;
  int? sortOrder;
  int? isActive;
  int? isApproved;
  String? createdAt;

  ProviderShowcaseItem({
    this.id,
    this.providerId,
    this.title,
    this.description,
    this.mediaType,
    this.fileName,
    this.mediaFullPath,
    this.sortOrder,
    this.isActive,
    this.isApproved,
    this.createdAt,
  });

  bool get isVideo => mediaType == 'video';

  bool get isPendingApproval => isApproved == 2;
  bool get isApprovedItem => isApproved == 1;
  bool get isDenied => isApproved == 0;

  /// Resolves showcase media against the app API base (fixes localhost vs APP_URL mismatch).
  String? get displayMediaUrl {
    final fromApi = mediaFullPath?.trim();
    if (fromApi != null && fromApi.isNotEmpty) {
      return MobileAppIconHelper.resolveMediaUrl(fromApi) ?? fromApi;
    }
    final file = fileName?.trim();
    if (file != null && file.isNotEmpty) {
      final storagePath = file.contains('/')
          ? '/storage/$file'
          : '/storage/provider/showcase/$file';
      return MobileAppIconHelper.resolveMediaUrl(storagePath);
    }
    return null;
  }

  ProviderShowcaseItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    providerId = json['provider_id'];
    title = json['title'];
    description = json['description'];
    mediaType = json['media_type'];
    fileName = json['file_name'];
    mediaFullPath = json['media_full_path'];
    sortOrder = int.tryParse(json['sort_order']?.toString() ?? '');
    isActive = int.tryParse(json['is_active']?.toString() ?? '');
    isApproved = int.tryParse(json['is_approved']?.toString() ?? '2');
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'title': title,
      'description': description,
      'media_type': mediaType,
      'file_name': fileName,
      'media_full_path': mediaFullPath,
      'sort_order': sortOrder,
      'is_active': isActive,
      'is_approved': isApproved,
      'created_at': createdAt,
    };
  }
}
