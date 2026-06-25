import 'package:demandium_provider/feature/reporting/widgets/business_report/business_report_earning_list.dart';
import 'package:demandium_provider/feature/reporting/widgets/business_report/business_report_line_chart.dart';
import 'package:demandium_provider/feature/reporting/widgets/business_report/business_report_shimmer.dart';
import 'package:demandium_provider/feature/reporting/widgets/business_report/earning_report_net_card.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BusinessReportView extends StatefulWidget {
  const BusinessReportView({super.key});

  @override
  State<BusinessReportView> createState() => _BusinessReportViewState();
}

class _BusinessReportViewState extends State<BusinessReportView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<BusinessReportController>();
      controller.prepareEarningReportFilterOptions();
      controller.getBusinessReportEarningData(1);
    });
  }

  String? _dateRangeLabel(BusinessReportController controller) {
    final range = controller.dateRange;
    if (range == null || range.isEmpty || range == 'all_time') {
      return 'all_time'.tr;
    }
    return range.tr;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessReportController>(
      builder: (reportController) {
        if (!reportController.reportLoadFinished) {
          return const BusinessReportShimmer();
        }

        if (!reportController.hasEarningData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NoDataScreen(
                    text: 'no_data_found'.tr,
                    type: NoDataType.others,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  CustomButton(
                    btnTxt: 'retry'.tr,
                    onPressed: () => reportController.getBusinessReportEarningData(
                      1,
                      reload: true,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: context.adaptivePrimaryColor,
          onRefresh: () => reportController.getBusinessReportEarningData(
            1,
            reload: true,
          ),
          child: CustomScrollView(
            controller: reportController.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Dimensions.paddingSizeDefault,
                    Dimensions.paddingSizeDefault,
                    Dimensions.paddingSizeDefault,
                    Dimensions.paddingSizeSmall,
                  ),
                  child: EarningReportNetCard(
                    amount: reportController.netEarningAmount,
                    dateRangeLabel: _dateRangeLabel(reportController),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: BusinessReportLineChart(fromPage: 'earning'),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: Dimensions.paddingSizeSmall),
              ),
              SliverToBoxAdapter(
                child: BusinessReportEarningListView(
                  filterData: reportController.earningBookingsWithAmount,
                ),
              ),
              if (reportController.loading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
