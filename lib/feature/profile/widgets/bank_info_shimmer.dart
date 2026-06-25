import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class BankInfoShimmer extends StatelessWidget {
  const BankInfoShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final placeholderColor =
        Get.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;

    return Shimmer(
      duration: const Duration(seconds: 3),
      interval: const Duration(seconds: 5),
      color: context.adaptiveWhite,
      colorOpacity: 0,
      enabled: true,
      direction: const ShimmerDirection.fromLTRB(),
      child: Container(
        height: context.height,
        width: context.width,
        color: context.adaptiveWhite,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                itemBuilder: (context, index) {
                  return Container(
                    height: 90,
                    width: context.width,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: placeholderColor,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Container(
                          height: 50,
                          width: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: placeholderColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
              )
            ],
          ),
        ),
      ),
    );
  }
}
