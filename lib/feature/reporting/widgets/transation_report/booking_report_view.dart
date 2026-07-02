import 'package:demandium_provider/feature/reporting/widgets/booking_report/booking_amount_widget.dart';
import 'package:demandium_provider/feature/reporting/widgets/booking_report/booking_count_widget.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BookingReportView extends StatefulWidget {
  const BookingReportView({super.key});

  @override
  State<BookingReportView> createState() => _BookingReportViewState();
}

class _BookingReportViewState extends State<BookingReportView> {
  final JustTheController _dueTooltipController = JustTheController();
  final JustTheController _settledTooltipController = JustTheController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<BookingReportController>();
      controller.prepareBookingReportFilterOptions();
      controller.getBookingReportData(1);
    });
  }

  @override
  void dispose() {
    _dueTooltipController.dispose();
    _settledTooltipController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingReportController>(
      builder: (reportController) {
        if (!reportController.reportLoadFinished) {
          return const Center(child: CustomLoader());
        }

        if (!reportController.hasBookingData) {
          return _ErrorOrEmptyState(
            message: reportController.loadError?.tr ?? 'no_data_found'.tr,
            onRetry: () => reportController.getBookingReportData(1, reload: true),
          );
        }

        final content = reportController.bookingReportModel?.content;

        return RefreshIndicator(
          color: context.adaptivePrimaryColor,
          onRefresh: () => reportController.getBookingReportData(1, reload: true),
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
            children: [
              BookingCountWidget(
                totalBookings:
                    content?.bookingsCount?.totalBookings?.toString() ?? '0',
                ongoing: content?.bookingsCount?.ongoing?.toString() ?? '0',
                completed: content?.bookingsCount?.completed?.toString() ?? '0',
                canceled: content?.bookingsCount?.canceled?.toString() ?? '0',
              ),
              BookingAmountWidget(
                totalBookingAmount:
                    content?.bookingAmount?.totalBookingAmount?.toString() ?? '0',
                dueAmount:
                    content?.bookingAmount?.totalUnpaidBookingAmount?.toString() ??
                        '0',
                settledAmount:
                    content?.bookingAmount?.totalPaidBookingAmount?.toString() ??
                        '0',
                dueTooltipController: _dueTooltipController,
                settledTooltipController: _settledTooltipController,
              ),
              const BookingReportBarChart(),
              BookingReportListView(
                bookingFilterData: reportController.bookingReportFilterData,
                isLoading: reportController.isLoading,
                selectedBookingStatus: reportController.selectedBookingStatus,
                onStatusChanged: (value) async {
                  reportController.setSelectedDropdownValue(
                    value,
                    type: 'booking_status',
                  );
                  await reportController.getBookingReportData(1);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorOrEmptyState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorOrEmptyState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NoDataScreen(
              text: message,
              type: NoDataType.others,
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            CustomButton(
              btnTxt: 'retry'.tr,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
