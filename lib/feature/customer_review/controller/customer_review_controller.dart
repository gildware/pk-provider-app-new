import 'package:demandium_provider/feature/customer_review/model/customer_review_body.dart';
import 'package:demandium_provider/feature/customer_review/repo/customer_review_repo.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class CustomerReviewController extends GetxController {
  final CustomerReviewRepo customerReviewRepo;

  CustomerReviewController({required this.customerReviewRepo});

  static void ensureDependencies() {
    if (!Get.isRegistered<CustomerReviewRepo>()) {
      Get.lazyPut(() => CustomerReviewRepo(apiClient: Get.find()));
    }
    if (!Get.isRegistered<CustomerReviewController>()) {
      Get.lazyPut(
        () => CustomerReviewController(
          customerReviewRepo: Get.find<CustomerReviewRepo>(),
        ),
        fenix: true,
      );
    }
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFetching = false;
  bool get isFetching => _isFetching;

  int _selectedRating = 5;
  int get selectedRating => _selectedRating;

  bool _isEditable = true;
  bool get isEditable => _isEditable;

  bool _hasReview = false;
  bool get hasReview => _hasReview;

  bool _isApproved = false;
  bool get isApproved => _isApproved;

  bool get canEdit => _hasReview && !_isApproved;

  String _reviewComment = '';
  String get reviewComment => _reviewComment;

  final TextEditingController reviewController = TextEditingController();

  void selectRating(int rating) {
    _selectedRating = rating;
    update();
  }

  void _applyReviewContent(Map<dynamic, dynamic> content) {
    _selectedRating = int.tryParse(content['review_rating']?.toString() ?? '5') ?? 5;
    _reviewComment = content['review_comment']?.toString() ?? '';
    reviewController.text = _reviewComment;
    _hasReview = true;
    _isApproved = content['is_active'] == 1 || content['is_active'] == true;
    _isEditable = false;
  }

  void _resetReviewState() {
    _selectedRating = 5;
    _reviewComment = '';
    reviewController.text = '';
    _hasReview = false;
    _isApproved = false;
    _isEditable = true;
  }

  bool _parseReviewContent(dynamic content) {
    if (content is Map && content.isNotEmpty) {
      _applyReviewContent(content);
      return true;
    }
    _resetReviewState();
    return false;
  }

  Map<dynamic, dynamic>? _readReviewContent(Response response) {
    if (response.statusCode != 200) {
      return null;
    }
    final body = response.body;
    if (body is! Map) {
      return null;
    }
    final content = body['content'];
    if (content is! Map || content.isEmpty) {
      return null;
    }
    return content;
  }

  Future<bool> checkReviewExists(String bookingId) async {
    final response = await customerReviewRepo.getCustomerReview(bookingId: bookingId);
    return _readReviewContent(response) != null;
  }

  Future<void> loadCustomerReview(String bookingId) async {
    _isFetching = true;
    update();

    try {
      final response = await customerReviewRepo.getCustomerReview(bookingId: bookingId);
      final content = _readReviewContent(response);
      if (content != null) {
        _parseReviewContent(content);
      } else {
        _resetReviewState();
      }
    } catch (_) {
      _resetReviewState();
    }

    _isFetching = false;
    update();
  }

  Future<void> submitCustomerReview({
    required String bookingId,
  }) async {
    _isLoading = true;
    update();

    final reviewBody = CustomerReviewBody(
      bookingId: bookingId,
      rating: _selectedRating.toString(),
      comment: reviewController.text.trim(),
    );

    final response = await customerReviewRepo.submitCustomerReview(reviewBody: reviewBody);
    if (response.statusCode == 200) {
      _hasReview = true;
      _isApproved = false;
      _isEditable = false;
      _reviewComment = reviewController.text.trim();
      final message = (response.body is Map && response.body['message'] != null)
          ? response.body['message'].toString()
          : 'review_submitted_successfully'.tr;
      showCustomSnackBar(message, type: ToasterMessageType.success);
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  void enableEdit() {
    if (!canEdit) {
      return;
    }
    _isEditable = true;
    update();
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
