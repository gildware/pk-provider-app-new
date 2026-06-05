import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BusinessReport extends StatelessWidget {
  const BusinessReport({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<BusinessReportController>(builder: (businessReportController){
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: ReportAppBarView(
          title: 'earning_report'.tr,
          fromPage: 'report',
          isFiltered: businessReportController.isFiltered,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            businessReportController.isFiltered ? const Padding(
              padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: BusinessReportFilteredWidget(),
            ) : const SizedBox(),
            const Expanded(child: BusinessReportView()),
          ],
        ),
      );
    });
  }
}
