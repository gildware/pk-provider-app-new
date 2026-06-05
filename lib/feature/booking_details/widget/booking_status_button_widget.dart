import 'package:demandium_provider/helper/extension_helper.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BookingStatusButtonWidget extends StatelessWidget {
  final String? bookingStatus;
  const BookingStatusButtonWidget({super.key, this.bookingStatus});

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color : context.customThemeColors.buttonBackgroundColorMap[bookingStatus],
      ),
      child: Text("$bookingStatus".tr,
        style: robotoRegular.copyWith(
          color:  context.customThemeColors.buttonTextColorMap[bookingStatus],
          fontSize: Dimensions.fontSizeSmall,
        ),
      ),
    );
  }
}
