import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class CreateChannelDialog extends StatefulWidget {
  final bool isSubBooking;
  const CreateChannelDialog({super.key, required this.isSubBooking,});
  @override
  State<CreateChannelDialog> createState() => _ProductBottomSheetState();
}
class _ProductBottomSheetState extends State<CreateChannelDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimensions.webMaxWidth,
      padding: const EdgeInsets.only(
        left: Dimensions.paddingSizeDefault,
        bottom: Dimensions.paddingSizeDefault,
      ),

      child: GetBuilder<BookingDetailsController>(builder: (bookingDetailsController){

        BookingDetailsContent? bookingDetails = widget.isSubBooking ? bookingDetailsController.subBookingDetails?.content : bookingDetailsController.bookingDetails?.content;

        BookingDetailsServiceman? serviceman = bookingDetails?.serviceman ?? bookingDetails?.subBooking?.serviceman;
        Customer? customer = bookingDetails?.customer ?? bookingDetails?.subBooking?.customer;
        final bool showServiceman = AppFeatureFlags.servicemanEnabled && serviceman != null;

        String titleText = "";

        if(showServiceman && customer != null){
          titleText = "make_conversation_with_customer_and_serviceman";
        } else if(showServiceman){
          titleText = "make_conversation_with_serviceman";
        }
        else if(customer != null){
          titleText = "make_conversation_with_customer";
        }

        return GetBuilder<ConversationController>(
            builder: (conversationController) {
              return SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () => Get.back(),
                        child: const Padding(
                          padding: EdgeInsets.only(
                            top: Dimensions.paddingSizeDefault,
                            right: Dimensions.paddingSizeDefault,
                          ),
                          child: Icon(Icons.close),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: Dimensions.paddingSizeDefault,
                          top: Dimensions.paddingSizeDefault,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(titleText.tr,
                              style: robotoMedium,),
                            const SizedBox(height: Dimensions.paddingSizeLarge,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                customer != null ? TextButton(
                                  onPressed:(){
                                    Get.back();
                                    String? customerId = customer.id;
                                    String? refId = bookingDetails?.id;
                                    String? name = "${customer.firstName ?? ""}" " ${customer.lastName ??""}";
                                    String? image = customer.profileImageFullPath ??"";
                                    String? phone = customer.phone ?? "";
                                    Get.find<ConversationController>().createChannel(userID:customerId, referenceID : refId,name: name,image: image,phone: phone.tr, userType: "customer");
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Theme.of(context).disabledColor.withValues(alpha:0.3),
                                    minimumSize:  const Size(Dimensions.paddingSizeLarge, 40),
                                    padding:  const EdgeInsets.symmetric(
                                      vertical: Dimensions.paddingSizeSmall,
                                      horizontal: Dimensions.paddingSizeLarge,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
                                  ),
                                  child: Text(
                                    "customer".tr, textAlign: TextAlign.center,
                                    style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                                  ),
                                ):const SizedBox.shrink(),
                                const SizedBox(width: Dimensions.paddingSizeLarge),

                                showServiceman ?
                                TextButton(
                                  onPressed:(){
                                    Get.back();
                                    String ? servicemanId = serviceman.userId;
                                    String? refId = bookingDetails?.id ?? "";
                                    String name = "${serviceman.user?.firstName ?? ""}" "${serviceman.user?.lastName ?? ""}";
                                    String image = serviceman.user?.profileImageFullPath??"";
                                    String phone = serviceman.user?.phone ?? "";
                                    Get.find<ConversationController>().createChannel(userID: servicemanId, referenceID : refId, name: name,image: image,phone: phone, userType: "serviceman");
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Theme.of(context).disabledColor.withValues(alpha:0.3),
                                    minimumSize:  const Size(Dimensions.paddingSizeLarge, 40),
                                    padding:  const EdgeInsets.symmetric(
                                      vertical: Dimensions.paddingSizeSmall,
                                      horizontal: Dimensions.paddingSizeLarge,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
                                  ),
                                  child: Text(
                                    "provider-serviceman".tr, textAlign: TextAlign.center,
                                    style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                                  ),
                                ):const SizedBox.shrink(),
                              ],
                            ),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            const SizedBox(height: Dimensions.paddingSizeLarge),
                          ],
                        ),
                      ),
                    ]
                ),
              );
            });
      }),
    );
  }
}
