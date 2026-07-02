import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BookingReportBarChart extends StatelessWidget {
  const BookingReportBarChart({super.key});

  List<_BookingChartPoint> _chartPoints(BookingReportController controller) {
    if (controller.barChartData.isEmpty) {
      return const [
        _BookingChartPoint('0', 0),
        _BookingChartPoint('1', 0),
        _BookingChartPoint('2', 0),
      ];
    }

    return controller.barChartData.map((item) {
      final amount = item['Amount'];
      final parsedAmount = amount is num
          ? amount.toDouble()
          : double.tryParse(amount?.toString() ?? '') ?? 0;
      return _BookingChartPoint(
        item['timeline']?.toString() ?? '',
        parsedAmount,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingReportController>(
      builder: (controller) {
        final points = _chartPoints(controller);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          height: 250,
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Row(
                children: [
                  Image.asset(Images.dashboardEarning, height: 15, width: 15),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text(
                    'booking_statistics'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Expanded(
                child: SfCartesianChart(
                  primaryXAxis: const CategoryAxis(),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries<_BookingChartPoint, String>>[
                    ColumnSeries<_BookingChartPoint, String>(
                      dataSource: points,
                      xValueMapper: (point, _) => point.label,
                      yValueMapper: (point, _) => point.amount,
                      color: context.adaptivePrimaryColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ],
          ),
        );
      },
    );
  }
}

class _BookingChartPoint {
  final String label;
  final double amount;

  const _BookingChartPoint(this.label, this.amount);
}
