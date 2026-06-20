import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class RecentActivityGraph extends StatelessWidget {
  const RecentActivityGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (dashboardController) {
      final stats = dashboardController.bookingStatusStats;
      final totalBookings = dashboardController.totalBookings;

      return SizedBox(
        height: stats.length > 4 ? 360 : 320,
        child: Column(
          children: [
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Expanded(
              child: stats.isEmpty
                  ? Center(
                      child: Text(
                        'no_data_found'.tr,
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 1.5,
                            centerSpaceRadius: 52,
                            sections: _buildSections(context, stats, totalBookings),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              totalBookings.toString(),
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeExtraLarge,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            Text(
                              'total_booking'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
            if (stats.isNotEmpty) ...[
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: Dimensions.paddingSizeDefault,
                  runSpacing: Dimensions.paddingSizeSmall,
                  children: stats.map((item) {
                    return _LegendItem(
                      color: _statusColor(context, item.status),
                      label: item.status.tr,
                      count: item.count,
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: Dimensions.paddingSizeLarge),
          ],
        ),
      );
    });
  }

  List<PieChartSectionData> _buildSections(
    BuildContext context,
    List<BookingStatusStat> stats,
    int totalBookings,
  ) {
    if (totalBookings <= 0) {
      return [
        PieChartSectionData(
          color: Theme.of(context).hintColor.withValues(alpha: 0.35),
          value: 1,
          title: '',
          radius: 40,
        ),
      ];
    }

    return stats.map((item) {
      final percentage = (item.count * 100) / totalBookings;
      return PieChartSectionData(
        color: _statusColor(context, item.status),
        value: item.count.toDouble(),
        title: percentage >= 8 ? item.count.toString() : '',
        radius: 38,
        titleStyle: robotoMedium.copyWith(color: Colors.white, fontSize: 12),
      );
    }).toList();
  }

  Color _statusColor(BuildContext context, String status) {
    return context.customThemeColors.buttonTextColorMap[status] ??
        Theme.of(context).primaryColor;
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 4),
        Text(
          '$label ($count)',
          style: robotoRegular.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
