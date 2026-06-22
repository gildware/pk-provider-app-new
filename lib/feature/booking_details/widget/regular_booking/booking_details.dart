import 'package:demandium_provider/feature/booking_details/widget/booking_service_location.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class BookingDetailsWidget extends StatelessWidget {
  final String? bookingId;
  final String? subBookingId;
  final bool isSubBooking;
  final TabController? tabController;
  const BookingDetailsWidget({super.key,  this.bookingId, required this.isSubBooking, this.tabController, this.subBookingId,});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(
      initState: (_)=>  Get.find<BookingDetailsController>().showHideExpandView(0, shouldUpdate: false),
      builder: (bookingDetailsController) {
        final bookingDetailsContent = isSubBooking ? bookingDetailsController.subBookingDetails : bookingDetailsController.bookingDetails;

        if(bookingDetailsContent == null && bookingDetailsContent?.content == null){
          return const Center(child: BookingDetailsShimmer());
        } else if( bookingDetailsContent != null && bookingDetailsContent.content == null){
          return SizedBox(height: Get.height * 0.7, child:  BookingEmptyScreen (bookingId: bookingId ?? "",));
        }else{
          final bookingDetails = isSubBooking ? bookingDetailsController.subBookingDetails!.content : bookingDetailsController.bookingDetails!.content;
          bool isPartial = (bookingDetails!.partialPayments !=null && bookingDetails.partialPayments!.isNotEmpty) ? true : false ;
          ConfigModel configModel = Get.find<SplashController>().configModel;
          String bookingStatus = bookingDetails.bookingStatus ?? "";
          int isGuest = bookingDetails.isGuest ?? 0;
          bool subBookingPaid = isSubBooking && bookingDetails.isPaid == 1;
          return Scaffold(
            body: Column( children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    if(isSubBooking){
                      await  Get.find<BookingDetailsController>().getBookingSubDetails(subBookingId ?? "", reload: false);
                    }else{
                      await  Get.find<BookingDetailsController>().getBookingDetails(bookingId?? "", reload: false);
                    }
                  },
                  child: SingleChildScrollView(physics: const ClampingScrollPhysics(), child: Column(children: [

                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    bookingDetails.bookingStatus!='pending'?
                    Row( mainAxisAlignment: MainAxisAlignment.center, children: [

                      const SizedBox(width:Dimensions.paddingSizeDefault),
                      Expanded(
                        child: CustomButton(
                          btnTxt: "edit_booking".tr, icon: Icons.edit,
                          onPressed: ( !subBookingPaid && configModel.content?.providerCanEditBooking == 1 && !isPartial && (bookingStatus == "accepted" || bookingStatus == "ongoing") && (isGuest == 1 && bookingDetails.paymentMethod != "cash_after_service" ? false : true)) ? (){
                            Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrail){
                              if(isTrail){
                                Get.to(()=> BookingEditScreen(bookingEditType: isSubBooking ? BookingEditType.subBooking : BookingEditType.regular,));
                              }
                            });
                          } :  null,
                        ),
                      ),

                      const SizedBox(width:Dimensions.paddingSizeSmall),

                      CustomButton(width: 120, color: Colors.blue,
                        icon: Icons.file_present, btnTxt: "invoice".tr,
                        onPressed: () async {
                          showCustomDialog(child: const CustomLoader());
                          String languageCode = Get.find<LocalizationController>().locale.languageCode;
                          final variant = isSubBooking ? 'single' : 'regular';
                          final uri = await BookingInvoiceHelper.providerInvoiceUrl(
                            bookingId: bookingDetails.id ?? '',
                            lang: languageCode,
                            variant: variant,
                          );
                          if (kDebugMode) {
                            print("Uri : $uri");
                          }
                          await _launchUrl(Uri.parse(uri));
                          Get.back();

                        },
                      ),
                      const SizedBox(width:Dimensions.paddingSizeDefault),
                    ]) :const SizedBox.shrink(),

                    const SizedBox(height: Dimensions.paddingSizeSmall,),

                    BookingInformationView(bookingDetails: bookingDetails, isSubBooking: isSubBooking),

                    BookingServiceLocation(
                      bookingDetails: bookingDetails, isSubBooking: isSubBooking,
                      bookingEditType: isSubBooking ? BookingEditType.subBooking : BookingEditType.regular,
                    ),

                    BookingSummeryView(bookingDetails: bookingDetails),

                    // SERVICEMAN_DISABLED
                    AppFeatureFlags.servicemanEnabled &&
                            bookingDetails.bookingStatus == 'accepted' &&
                            bookingDetails.serviceman == null
                        ? GetBuilder<ServicemanSetupController>(builder: (servicemanSetupController) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeLarge,
                                vertical: Dimensions.paddingSizeSmall,
                              ),
                              child: !servicemanSetupController.isLoading
                                  ? CustomButton(
                                      btnTxt: "Assign_service_man".tr,
                                      onPressed: () => bookingDetailsController.showHideExpandView(350),
                                    )
                                  : CircularProgressIndicator(color: Theme.of(context).hoverColor),
                            );
                          })
                        : AppFeatureFlags.servicemanEnabled &&
                                bookingDetails.bookingStatus != 'pending' &&
                                bookingDetails.serviceman != null
                            ? BookingDetailsServicemanInfo(bookingDetails: bookingDetails)
                            : const SizedBox.shrink(),

                    BookingDetailsCustomerInfo(bookingDetails: bookingDetails,),

                    if (!isSubBooking && bookingDetails.bookingStatus == 'completed')
                      CustomerRatingButton(
                        bookingId: bookingDetails.id ?? '',
                        customerName: _resolveCustomerName(bookingDetails),
                      ),

                    ServiceCompletedPhotoEvidence(bookingDetails: bookingDetails, isSubBooking: isSubBooking,),

                    const SizedBox(height: Dimensions.paddingSizeExtraSmall,)
                  ],),
                  ),
                ),
              ),

              (  (!isSubBooking || (isSubBooking && bookingDetails.bookingStatus != "pending")) && (bookingDetails.bookingStatus == "pending" || bookingDetails.bookingStatus == "accepted" || bookingDetails.bookingStatus == "ongoing" )) ?
              ChangeStatusDropdownButton(
                bookingDetails: bookingDetails,
                bookingId: bookingDetails.id!,
                isSubBooking: isSubBooking,
              ) : const SizedBox(),

              const SizedBox(height: Dimensions.paddingSizeDefault,)
            ]),

            floatingActionButton: bookingDetailsController.isShowChattingButton(bookingDetails, tabController) ?
            Padding(padding:  EdgeInsets.only(bottom: GetPlatform.isAndroid ? 70 : 35),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: 48, width: 48,
                    child: FloatingActionButton(
                      shape: const CircleBorder(),

                      heroTag: "1",
                      elevation: 0.0,
                      backgroundColor: Colors.green,
                      onPressed: () async => await  launchUrl(Uri(
                        scheme: 'tel',
                        path: bookingDetails.serviceAddress?.contactPersonNumber ?? bookingDetails.subBooking?.serviceAddress?.contactPersonNumber ?? "",
                      ),mode: LaunchMode.externalApplication,
                      ),
                      child: Icon(Icons.call,color: light.cardColor, size: 20,),
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

                  SizedBox(height: 48, width: 48,
                    child: FloatingActionButton(
                      shape: const CircleBorder(),
                      heroTag: "2",
                      elevation: 0.0,
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        if(Get.find<UserProfileController>().checkAvailableFeatureInSubscriptionPlan(featureType: "chat")){
                          showCustomBottomSheet(child:  CreateChannelDialog(isSubBooking: isSubBooking,));
                        }
                      },
                      child: Icon(Icons.message_rounded,color: light.cardColor,size: 18,),
                    ),
                  ),
                ],
              ),
            ) : null,
          );
        }
      },
    );
  }
  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}

class BookingEmptyScreen extends StatelessWidget {
  final String? bookingId;
  const BookingEmptyScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [
      Image.asset(Images.noResults, height: Get.height * 0.1, color: Theme.of(context).primaryColor,),
      const SizedBox(height: Dimensions.paddingSizeLarge,),
      Text("information_not_found".tr, style: robotoRegular,),
      const SizedBox(height: Dimensions.paddingSizeLarge,),

      CustomButton(
        height: 35, width: 120, radius: Dimensions.radiusExtraLarge,
        btnTxt: "go_back".tr, onPressed: () {
          Get.find<BookingRequestController>().removeBookingItemFromList(bookingId ?? "", shouldUpdate: true , bookingStatus: "");
        Get.back();
      },)

    ],),);
  }
}

String _resolveCustomerName(BookingDetailsContent bookingDetails) {
  final customerName = bookingDetails.serviceAddress?.contactPersonName
      ?? '${bookingDetails.customer?.firstName ?? ''} ${bookingDetails.customer?.lastName ?? ''}'.trim();
  return customerName.isNotEmpty ? customerName : 'customer'.tr;
}
