import 'package:demandium_provider/feature/reporting/widgets/booking_report/booking_report_filter_body.dart';
import 'package:demandium_provider/feature/reporting/widgets/business_report/earning_report_filter_body.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class ReportSearchFilter extends StatelessWidget {
  final String fromPage;
  const ReportSearchFilter({super.key, required this.fromPage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "filter".tr),
      body: fromPage == 'booking'
          ? const BookingReportFilterBody()
          : const EarningReportFilterBody(),
    );
  }
}
