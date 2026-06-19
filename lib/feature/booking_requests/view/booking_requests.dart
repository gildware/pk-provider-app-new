
import 'package:get/get.dart';
import 'package:demandium_provider/helper/booking_list_filter_tabs.dart';
import 'package:demandium_provider/util/core_export.dart';

class BookingRequestScreen extends StatefulWidget {
  const BookingRequestScreen({super.key});
  @override
  State<BookingRequestScreen> createState() => _BookingRequestScreenState();
}

class _BookingRequestScreenState extends State<BookingRequestScreen>{



  @override
  void initState() {
    super.initState();

    Get.find<UserProfileController>().getProviderInfo(reload: true);
    Get.find<BookingRequestController>().updateSelectedServiceType();
    Get.find<BookingRequestController>().getBookingRequestList('pending',1,reload: true, isFirst: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: MainAppBar(title: 'booking_requests'.tr,color: Theme.of(context).primaryColor,fromBookingRequest: true,),
      body: GetBuilder<UserProfileController>(builder: (userController){
        return Column(children: [
          const ProviderPendingApprovalBanner(),
          const BookingRequestMenuBar(),
          const Expanded(child: BookingRequestList()),
        ],);
      }),

    );
  }
}

class SubscriptionCanceledView extends StatelessWidget {
  const SubscriptionCanceledView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding( padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [

          Text("your_subscription_plan_has_been_cancelled_you_will_not_able_to_accept_any_booking_request".tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
            textAlign: TextAlign.center,),

          const SizedBox(height: Dimensions.paddingSizeDefault,),

          CustomButton(
            btnTxt: 'choose_plan'.tr,
            width: 180, height: 45,
            radius: Dimensions.radiusLarge,
            onPressed: () {
              Get.toNamed(RouteHelper.getBusinessPlanScreen());
            },
          ),
        ],),
      ),
    );
  }
}

class PendingApprovalBookingView extends StatelessWidget {
  const PendingApprovalBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Center(
        child: ProviderPendingVerificationWarningCard(
          messageKey: 'provider_pending_verification_bookings_empty',
          margin: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class TurnOnServiceAvailability extends StatelessWidget {
  const TurnOnServiceAvailability({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding( padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [

          Text("service_availability_option_has_turned_off".tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
            textAlign: TextAlign.center,),

          const SizedBox(height: Dimensions.paddingSizeDefault,),

          InkWell(
            onTap: () => Get.to(const BusinessSettingScreen()),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                border: Border.all(color: Theme.of(context).primaryColor),
              ), padding:  const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall-3),
                child: Text("go_to_business_settings".tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),)),
          )

        ],),
      ),
    );
  }
}

class BookingRequestList extends StatefulWidget {
  const BookingRequestList({super.key});

  @override
  State<BookingRequestList> createState() => _BookingRequestListState();
}

class _BookingRequestListState extends State<BookingRequestList> {
  @override
  Widget build(BuildContext context) {

    return GetBuilder<UserProfileController>(builder: (userProfileController){
      return GetBuilder<BookingRequestController>(
        id: BookingRequestController.bookingListUpdateId,
        builder: (bookingRequestController){
        return userProfileController.isPendingAdminVerification ?
        Center(
          child: SizedBox(
            height: Get.height * 0.7,
            child: const PendingApprovalBookingView(),
          ),
        ) : bookingRequestController.bookingRequestList == null ?
        const BookingRequestItemShimmer()

        : bookingRequestController.isTabLoading && bookingRequestController.bookingRequestList!.isEmpty ?
        const BookingRequestItemShimmer()

        : bookingRequestController.bookingStatus == 'pending'  && userProfileController.providerModel?.content?.providerInfo?.serviceAvailability == 0 ?
        Center(
          child: SizedBox(height: Get.height * 0.7,
            child:const TurnOnServiceAvailability(),
          ),
        ) : bookingRequestController.bookingStatus == 'pending'  &&  userProfileController.providerModel?.content?.subscriptionInfo?.subscribedPackageDetails?.isCanceled == 1 ? Center(
          child: SizedBox(height: Get.height * 0.7,
            child:const SubscriptionCanceledView(),
          ),
        ) : bookingRequestController.bookingRequestList!.isEmpty ? Center(
          child: SizedBox(height: Get.height * 0.7,
            child: NoDataScreen(
                text: bookingRequestController.bookingStatus == 'all' ? "you_do_not_have_any_booking_request_yet".tr :
                '${'you_have_not'.tr} ${bookingListFilterTabLabelKey(bookingRequestController.bookingStatus).tr.toLowerCase()} ${"request_yet".tr}',
                type: NoDataType.request
            ),
          ),
        ) : const BookingRequestListview();
      });
    });
  }
}
