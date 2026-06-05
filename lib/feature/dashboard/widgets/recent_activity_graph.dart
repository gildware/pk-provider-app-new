import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class RecentActivityGraph extends StatelessWidget {
  const RecentActivityGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (dashboardController){
      return SizedBox(height: 290,
        child: Column(children: [
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Expanded(
            child: PieChart(
              PieChartData(
                borderData: FlBorderData(
                  show: false,
                ),
                sectionsSpace: 0,
                centerSpaceRadius: 50,
                sections: showingSections(dashboardController),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.circle,color: Colors.blue,size: 15,),
            const SizedBox(width: 5,),
            Text(
              "total_normal_booking".tr,
              style: robotoRegular.copyWith(fontSize: 12),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.circle,color: Colors.cyan.shade300,size: 15,),
            const SizedBox(width: 5,),
            Text(
              "total_customized_booking".tr,
              style: robotoRegular.copyWith(fontSize: 12),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeLarge),

        ]),
      );
    });
  }

  List<PieChartSectionData> showingSections(DashboardController dashboardController) {

    int pendingCustomisedPost = dashboardController.additionalInfoCount?.customizedPostCount ?? 0;
    int pendingBookingRequest = dashboardController.additionalInfoCount?.pendingBookingCount ?? 0;
    int totalCount = pendingBookingRequest + pendingCustomisedPost;


    double pendingCustomisedPostPercentage = (pendingCustomisedPost  * 100) / totalCount;
    double pendingBookingRequestPercentage = (pendingBookingRequest  * 100) / totalCount;



    return totalCount > 0 ? List.generate(2, (i) {
      const radius =  35.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.cyan.shade300,
            value: pendingCustomisedPostPercentage ,
            title: pendingCustomisedPost.toString(),
            radius: radius,
            titleStyle: robotoMedium.copyWith(color: Colors.white),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.blue,
            value: pendingBookingRequestPercentage,
            title:  pendingBookingRequest.toString(),
            radius: radius,
            titleStyle: robotoMedium.copyWith(color: Colors.white),
          );

        default:
          throw Error();
      }
    }):List.generate(1, (i) {
      const radius =  40.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Theme.of(Get.context!).hintColor.withValues(alpha:0.6),
            value: 1.0,
            title: "",
            radius: radius,
            titleStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xffffffff),
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
