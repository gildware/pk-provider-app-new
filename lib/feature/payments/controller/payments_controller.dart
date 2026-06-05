import 'package:demandium_provider/feature/payments/model/provider_payments_model.dart';
import 'package:demandium_provider/feature/payments/repo/payments_repo.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

enum ProviderPaymentSubTab {
  ledger,
  recorded,
  earning,
  specialEarning,
  disputed,
}

extension ProviderPaymentSubTabExt on ProviderPaymentSubTab {
  String get apiValue => switch (this) {
        ProviderPaymentSubTab.ledger => 'ledger',
        ProviderPaymentSubTab.recorded => 'recorded',
        ProviderPaymentSubTab.earning => 'earning',
        ProviderPaymentSubTab.specialEarning => 'special_earning',
        ProviderPaymentSubTab.disputed => 'disputed',
      };
}

class PaymentsController extends GetxController implements GetxService {
  final PaymentsRepo paymentsRepo;
  PaymentsController({required this.paymentsRepo});

  ProviderPaymentsOverview? _overview;
  ProviderPaymentsOverview? get overview => _overview;

  ProviderPaymentSubTab _activeSub = ProviderPaymentSubTab.ledger;
  ProviderPaymentSubTab get activeSub => _activeSub;

  final List<Map<String, dynamic>> _listItems = [];
  List<Map<String, dynamic>> get listItems => _listItems;

  Map<String, dynamic>? _listTotals;
  Map<String, dynamic>? get listTotals => _listTotals;

  bool _overviewLoading = false;
  bool get overviewLoading => _overviewLoading;

  bool _listLoading = false;
  bool get listLoading => _listLoading;

  bool _paginationLoading = false;
  bool get paginationLoading => _paginationLoading;

  int _offset = 1;
  int _lastPage = 1;
  int get lastPage => _lastPage;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent == scrollController.position.pixels) {
        if (_offset < _lastPage && !_paginationLoading && !_listLoading) {
          loadList(_offset + 1, fromPagination: true);
        }
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> initPayments() async {
    _activeSub = ProviderPaymentSubTab.ledger;
    await Future.wait([loadOverview(), loadList(1)]);
  }

  Future<void> loadOverview() async {
    _overviewLoading = true;
    update();
    final response = await paymentsRepo.getOverview();
    if (response.statusCode == 200) {
      final content = response.body['content'];
      if (content is Map && content['overview'] is Map) {
        _overview = ProviderPaymentsOverview.fromJson(
          Map<String, dynamic>.from(content['overview']),
        );
      }
    } else if (response.statusCode == 401) {
      ApiChecker.checkApi(response);
    }
    _overviewLoading = false;
    update();
  }

  Future<void> changeSubTab(ProviderPaymentSubTab sub) async {
    if (_activeSub == sub) return;
    _activeSub = sub;
    update();
    await loadList(1);
  }

  Future<void> loadList(int offset, {bool fromPagination = false}) async {
    _offset = offset;
    if (!fromPagination) {
      _listItems.clear();
      _listTotals = null;
      _listLoading = true;
    } else {
      _paginationLoading = true;
    }
    update();

    final limit = Get.find<SplashController>().configModel.content?.paginationLimit ?? 20;
    final response = await paymentsRepo.getList(
      paymentSub: _activeSub.apiValue,
      offset: offset,
      limit: limit,
    );

    if (response.statusCode == 200) {
      final content = response.body['content'];
      if (content is Map) {
        final parsed = ProviderPaymentsListResponse.fromJson(Map<String, dynamic>.from(content));
        _lastPage = parsed.lastPage;
        _listTotals = parsed.totals;
        _listItems.addAll(parsed.data);
      }
    } else if (response.statusCode == 401) {
      ApiChecker.checkApi(response);
    }

    _listLoading = false;
    _paginationLoading = false;
    update();
  }

  Future<void> refreshAll() async {
    await Future.wait([loadOverview(), loadList(1)]);
  }
}
