import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class BottomCard extends StatelessWidget {

  const BottomCard({
    super.key,
    required this.name,
    required this.phone,
    required this.image,
    this.address,
    this.avgRating,
    this.ratingCount,
  });

  final String name;
  final String phone;
  final String image;
  final String? address;
  final double? avgRating;
  final int? ratingCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:Get.isDarkMode?Theme.of(context).cardColor.withValues(alpha:0.6):Theme.of(context).primaryColor.withValues(alpha:0.05),
          //boxShadow: shadow
      ),

      child: Column(
        children: [
          const Row(),

          const SizedBox(height: Dimensions.paddingSizeDefault,),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CustomImage(
              height: 50,
              width: 50,
              image: image,
              placeholder: Images.userPlaceHolder,
            )
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall,),
          Text(name, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault,),textAlign: TextAlign.center,),

          const SizedBox(height: Dimensions.paddingSizeSmall,),
          Text(phone, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.7))),

          if (avgRating != null) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            RatingBar(
              rating: avgRating ?? 0,
              ratingCount: ratingCount,
              size: 16,
            ),
          ],

          // const SizedBox(height: Dimensions.paddingSizeSmall,),
          // address != null ?
          // Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
          //   child: RichText(
          //     text: TextSpan(text: '${'service_address'.tr} :',
          //       style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault,
          //         color: Theme.of(context).textTheme.bodyLarge!.color,
          //       ),
          //     children: [
          //         TextSpan(
          //           text: ' $address',
          //             style: robotoRegular.copyWith(
          //               fontSize: Dimensions.fontSizeDefault,
          //               color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.7),
          //             ),
          //         ),
          //     ],
          //   ),
          //     textAlign: TextAlign.center),
          // ) : const SizedBox(),

           const SizedBox(height:Dimensions.paddingSizeLarge),
        ],
      ),
    );
  }
}