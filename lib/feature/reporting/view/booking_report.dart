import 'package:demandium_provider/feature/reporting/widgets/transation_report/booking_report_view.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BookingReport extends StatelessWidget {
  const BookingReport({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingReportController>(
      builder: (bookingReportController) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: ReportAppBarView(
            title: 'booking_report'.tr,
            fromPage: 'booking',
            isFiltered: bookingReportController.isFiltered,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bookingReportController.isFiltered
                  ? const Padding(
                      padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: BookingReportFilteredWidget(),
                    )
                  : const SizedBox.shrink(),
              const Expanded(child: BookingReportView()),
            ],
          ),
        );
      },
    );
  }
}
