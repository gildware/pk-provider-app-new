import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class ColumnText extends StatelessWidget {
  final String amount;
  final String title;
  const ColumnText({super.key,required this.title,required this.amount});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onPrimary;

    return SizedBox(
      width: Get.width * .27,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              amount.toString(),
              style: robotoBold.copyWith(fontSize: 17, color: textColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              title,
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(
                fontSize: 12,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
