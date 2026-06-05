import 'package:get/get.dart';
import 'package:demandium_provider/feature/payments/controller/payments_controller.dart';
import 'package:demandium_provider/feature/payments/widget/payments_list_card.dart';
import 'package:demandium_provider/feature/payments/widget/payments_summary_section.dart';
import 'package:demandium_provider/util/core_export.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> with TickerProviderStateMixin {
  late TabController _pageTabController;
  late TabController _detailsSubTabController;

  static const _subTabs = ProviderPaymentSubTab.values;

  @override
  void initState() {
    super.initState();
    _pageTabController = TabController(length: 2, vsync: this);
    _detailsSubTabController = TabController(length: _subTabs.length, vsync: this);
    _pageTabController.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<PaymentsController>().initPayments();
    });
  }

  @override
  void dispose() {
    _pageTabController.dispose();
    _detailsSubTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaymentsController>(builder: (controller) {
      final activeSubIndex = _subTabs.indexOf(controller.activeSub);
      if (_detailsSubTabController.index != activeSubIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _detailsSubTabController.index != activeSubIndex) {
            _detailsSubTabController.animateTo(activeSubIndex);
          }
        });
      }

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: CustomAppBar(title: 'payments'.tr),
        body: controller.overviewLoading && controller.overview == null && _pageTabController.index == 0
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Material(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: TabBar(
                      controller: _pageTabController,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Theme.of(context).hintColor,
                      indicatorColor: Theme.of(context).primaryColor,
                      labelStyle: robotoMedium,
                      unselectedLabelStyle: robotoRegular,
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(text: 'summary'.tr),
                        Tab(text: 'details'.tr),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: controller.refreshAll,
                      child: _pageTabController.index == 0
                          ? _buildSummaryTab(controller)
                          : _buildDetailsTab(context, controller),
                    ),
                  ),
                ],
              ),
      );
    });
  }

  Widget _buildSummaryTab(PaymentsController controller) {
    if (controller.overviewLoading && controller.overview == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeLarge),
      children: [
        PaymentsSummarySection(overview: controller.overview),
      ],
    );
  }

  Widget _buildDetailsTab(BuildContext context, PaymentsController controller) {
    return CustomScrollView(
      controller: controller.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _PaymentsTabBarDelegate(
            TabBar(
              controller: _detailsSubTabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              onTap: (index) => controller.changeSubTab(_subTabs[index]),
              tabs: [
                Tab(text: 'provider_ledger'.tr),
                Tab(text: 'payment_transactions_all_parties'.tr),
                Tab(text: 'booking_earning_report'.tr),
                Tab(text: 'special_booking_earning_report'.tr),
                Tab(text: 'disputed_bookings'.tr),
              ],
            ),
          ),
        ),
        if (controller.listLoading && controller.listItems.isEmpty)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (controller.listItems.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: NoDataScreen(text: 'no_data_available'.tr)),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= controller.listItems.length) {
                  return controller.paginationLoading
                      ? const Padding(
                          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox(height: Dimensions.paddingSizeLarge);
                }
                return PaymentsListCard(
                  subTab: controller.activeSub,
                  item: controller.listItems[index],
                );
              },
              childCount: controller.listItems.length + 1,
            ),
          ),
        if (controller.listTotals != null && controller.listItems.isNotEmpty)
          SliverToBoxAdapter(
            child: _TotalsFooter(totals: controller.listTotals!, activeSub: controller.activeSub),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: Dimensions.paddingSizeLarge)),
      ],
    );
  }
}

class _TotalsFooter extends StatelessWidget {
  final Map<String, dynamic> totals;
  final ProviderPaymentSubTab activeSub;
  const _TotalsFooter({required this.totals, required this.activeSub});

  @override
  Widget build(BuildContext context) {
    if (activeSub != ProviderPaymentSubTab.earning &&
        activeSub != ProviderPaymentSubTab.specialEarning &&
        activeSub != ProviderPaymentSubTab.disputed) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('total'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ...totals.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(_labelForKey(e.key), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall))),
                    Text(PriceConverter.convertPrice(_toDouble(e.value)), style: robotoMedium),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String _labelForKey(String key) => key.replaceAll('_', ' ');

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }
}

class _PaymentsTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _PaymentsTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _PaymentsTabBarDelegate oldDelegate) => false;
}
