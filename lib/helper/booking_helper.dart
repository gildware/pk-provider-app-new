import 'package:demandium_provider/feature/booking_details/model/bookings_details_model.dart';
import 'package:demandium_provider/feature/booking_requests/model/request_model.dart';
import 'package:demandium_provider/feature/splash/controller/splash_controller.dart';
import 'package:get/get.dart';

class BookingHelper{
  static double getSubTotalCost(BookingDetailsContent booking) {
    double subTotal = 0;
    for (var element in booking.details!) {
      subTotal = subTotal + ((element.serviceCost ?? 1) * (element.quantity ?? 1));
    }
    return subTotal;
  }

  static double getBookingServiceUnitConst(ItemService? item) {
    return getBookingServiceLineSubtotal(item);
  }

  static double getBookingServiceLineSubtotal(ItemService? item) {
    return (item?.serviceCost ?? 0) * (item?.quantity ?? 1);
  }

  static double getBookingServiceItemDiscountTotal(ItemService? item) {
    return (item?.discountAmount ?? 0) +
        (item?.campaignDiscountAmount ?? 0) +
        (item?.overallCouponDiscountAmount ?? 0);
  }

  static double getBookingServiceDiscountedTotal(ItemService? item) {
    if (item?.totalCost != null && item!.totalCost! >= 0) {
      return item.totalCost!;
    }
    final subtotal = getBookingServiceLineSubtotal(item);
    final discount = getBookingServiceItemDiscountTotal(item);
    return (subtotal - discount).clamp(0, double.infinity).toDouble();
  }

  static bool bookingServiceHasDiscount(ItemService? item) {
    if (getBookingServiceItemDiscountTotal(item) > 0) {
      return true;
    }
    return getBookingServiceLineSubtotal(item) > getBookingServiceDiscountedTotal(item);
  }

  static double getExtraServiceLineQuantity(ProviderExtraServiceLine line) {
    return (line.quantity == null || line.quantity! <= 0) ? 1 : line.quantity!.toDouble();
  }

  static double getExtraServiceLineSubtotal(ProviderExtraServiceLine line) {
    final qty = getExtraServiceLineQuantity(line);
    if (line.price != null && line.price! > 0) {
      return line.price! * qty;
    }
    final discountedTotal = line.total ?? line.amount ?? 0;
    final discount = line.discount ?? 0;
    if (discount > 0) {
      return discountedTotal + discount;
    }
    return discountedTotal;
  }

  static double getExtraServiceLineDiscountTotal(ProviderExtraServiceLine line) {
    return line.discount ?? 0;
  }

  static double getExtraServiceLineDiscountedTotal(ProviderExtraServiceLine line) {
    final subtotal = getExtraServiceLineSubtotal(line);
    final discount = getExtraServiceLineDiscountTotal(line);
    return line.total ?? line.amount ?? (subtotal - discount).clamp(0, double.infinity).toDouble();
  }

  static bool extraServiceLineHasDiscount(ProviderExtraServiceLine line) {
    if (getExtraServiceLineDiscountTotal(line) > 0) {
      return true;
    }
    return getExtraServiceLineSubtotal(line) > getExtraServiceLineDiscountedTotal(line);
  }

  static double getDiscountedSubTotal(BookingDetailsContent booking) {
    double total = 0;
    for (final item in booking.details ?? []) {
      total += getBookingServiceDiscountedTotal(item);
    }
    for (final line in booking.extraServiceLines ?? []) {
      if ((line.total ?? line.amount ?? 0) > 0) {
        total += getExtraServiceLineDiscountedTotal(line);
      }
    }
    return total;
  }

  static String? getRepeatBookingCurrentSchedule(BookingRequestModel bookingRequest) {
    if (bookingRequest.repeatBookingList == null || bookingRequest.repeatBookingList!.isEmpty ) {
      return bookingRequest.serviceSchedule;
    }

    final ongoingSchedule = bookingRequest.repeatBookingList?.firstWhere((repeatBooking) => repeatBooking.bookingStatus == "ongoing", orElse: () => RepeatBooking()).serviceSchedule;
    if (ongoingSchedule != null) return ongoingSchedule;

    final acceptedSchedule = bookingRequest.repeatBookingList?.firstWhere((repeatBooking) => repeatBooking.bookingStatus == "accepted", orElse: () => RepeatBooking()).serviceSchedule;
    if (acceptedSchedule != null) return acceptedSchedule;

    final completedSchedule = bookingRequest.repeatBookingList?.firstWhere((repeatBooking) => repeatBooking.bookingStatus == "completed", orElse: () => RepeatBooking()).serviceSchedule;
    if (completedSchedule != null) return completedSchedule;

    final canceledSchedule = bookingRequest.repeatBookingList?.firstWhere((repeatBooking) => repeatBooking.bookingStatus == "canceled", orElse: () => RepeatBooking()).serviceSchedule;
    if (canceledSchedule != null) return canceledSchedule;

    final pendingSchedule = bookingRequest.repeatBookingList?.firstWhere((repeatBooking) => repeatBooking.bookingStatus == "pending", orElse: () => RepeatBooking()).serviceSchedule;
    return pendingSchedule;

  }

  static RepeatBooking? getCurrentOngoingRepeatBooking(BookingRequestModel bookingRequest) {
    if (bookingRequest.repeatBookingList == null || bookingRequest.repeatBookingList!.isEmpty || bookingRequest.bookingStatus == "pending") {
      return null;
    }
    for (var repeatBooking in bookingRequest.repeatBookingList!) {
      if (repeatBooking.bookingStatus == "ongoing") {
        return repeatBooking;
      }
    }
    for (var repeatBooking in bookingRequest.repeatBookingList!) {
      if (repeatBooking.bookingStatus == "accepted") {
        return repeatBooking;
      }
    }
    return null;
  }

  static RepeatBooking? getNextUpcomingRepeatBooking(BookingDetailsContent? bookingRequest, String? providerId) {

    if (bookingRequest?.providerId != providerId || bookingRequest  == null || bookingRequest.repeatBookingList == null || bookingRequest.repeatBookingList!.isEmpty || bookingRequest.bookingStatus == "pending") {
      return null;
    }
    for (var repeatBooking in bookingRequest.repeatBookingList!) {
      if (repeatBooking.bookingStatus == "ongoing") {
        return repeatBooking;
      }
    }
    for (var repeatBooking in bookingRequest.repeatBookingList!) {
      if (repeatBooking.bookingStatus == "accepted") {
        return repeatBooking;
      }
    }
    return null;
  }

  static double getRepeatBookingPaidAmount(BookingDetailsContent bookingDetails){

    double amount = 0;

    if(bookingDetails.repeatBookingList == null || bookingDetails.repeatBookingList!.isEmpty){
      return 0;
    }

    for(var repeatBooking in bookingDetails.repeatBookingList!){
      if(repeatBooking.isPaid ==1){
        amount = amount + (repeatBooking.totalBookingAmount ?? 0);
      }
    }
    return amount;
  }

  static double getRepeatBookingCanceledAmount(BookingDetailsContent bookingDetails){

    double amount = 0;

    if(bookingDetails.repeatBookingList == null || bookingDetails.repeatBookingList!.isEmpty){
      return 0;
    }

    for(var repeatBooking in bookingDetails.repeatBookingList!){
      if(repeatBooking.bookingStatus == "canceled"){
        amount = amount + (repeatBooking.totalBookingAmount ?? 0);
      }
    }
    return amount;
  }

  static int getRepeatPaidBookingCount(BookingDetailsContent bookingDetails){

    int count = 0;
    if(bookingDetails.repeatBookingList == null || bookingDetails.repeatBookingList!.isEmpty){
      return 0;
    }
    for(var repeatBooking in bookingDetails.repeatBookingList!){
      if(repeatBooking.isPaid == 1){
        count ++;
      }
    }
    return count;
  }

  static int getRepeatCanceledBookingCount(BookingDetailsContent bookingDetails){

    int count = 0;
    if(bookingDetails.repeatBookingList == null || bookingDetails.repeatBookingList!.isEmpty){
      return 0;
    }
    for(var repeatBooking in bookingDetails.repeatBookingList!){
      if(repeatBooking.bookingStatus == "canceled"){
        count ++;
      }
    }
    return count;
  }

  static List<ProviderBookingSummaryLine> getAdditionalChargeLines(BookingDetailsContent booking) {
    final summaryLines = booking.bookingSummary?.additionalChargeLines
        ?.where((line) => (line.amount ?? 0) > 0)
        .toList();
    if (summaryLines != null && summaryLines.isNotEmpty) {
      return summaryLines;
    }

    if ((booking.extraFee ?? 0) > 0) {
      return [ProviderBookingSummaryLine(amount: booking.extraFee)];
    }

    return [];
  }

  static ProviderBookingSummary resolveBookingSummary(BookingDetailsContent booking) {
    final fromApi = booking.bookingSummary;
    if (fromApi != null && fromApi.grossTotal != null) {
      return fromApi;
    }
    return buildBookingSummaryFallback(booking, base: fromApi);
  }

  static ProviderBookingSummary buildBookingSummaryFallback(
    BookingDetailsContent booking, {
    ProviderBookingSummary? base,
  }) {
    final additionalLines = getAdditionalChargeLines(booking);
    final serviceAmount = getSubTotalCost(booking);
    final extraServiceTotal = (booking.extraServiceLines ?? [])
        .where((line) => !line.isSparePart)
        .fold<double>(0, (sum, line) => sum + (line.total ?? line.amount ?? 0));
    final spareTotal = (booking.extraServiceLines ?? [])
        .where((line) => line.isSparePart)
        .fold<double>(0, (sum, line) => sum + (line.total ?? line.amount ?? 0));
    final additionalTotal = additionalLines.fold<double>(0, (sum, line) => sum + (line.amount ?? 0));
    final grossTotal = serviceAmount + additionalTotal + extraServiceTotal + spareTotal;
    final grandTotalValue = booking.paymentDetails?.total ?? booking.totalBookingAmount ?? grossTotal;
    final paid = booking.paymentDetails?.amountPaidDisplay ?? 0;
    final due = booking.paymentDetails?.dueBalance ?? (grandTotalValue - paid).clamp(0, double.infinity);

    return ProviderBookingSummary(
      serviceAmount: base?.serviceAmount ?? serviceAmount,
      extraServiceLines: base?.extraServiceLines,
      sparePartLines: base?.sparePartLines,
      additionalChargeLines: base?.additionalChargeLines ?? additionalLines,
      grossTotal: base?.grossTotal ?? grossTotal,
      serviceDiscount: base?.serviceDiscount ?? booking.totalDiscountAmount,
      couponDiscount: base?.couponDiscount ?? booking.totalCouponDiscountAmount,
      campaignDiscount: base?.campaignDiscount ?? booking.totalCampaignDiscountAmount,
      referralDiscount: base?.referralDiscount ?? booking.totalReferralDiscountAmount,
      tax: base?.tax ?? booking.totalTaxAmount,
      hasTax: base?.hasTax ?? ((booking.totalTaxAmount ?? 0) > 0),
      grandTotal: base?.grandTotal ?? grandTotalValue,
      totalPaid: base?.totalPaid ?? paid,
      dueAmount: base?.dueAmount ?? due,
    );
  }

  static double resolveGrandTotal(BookingDetailsContent booking) {
    final summary = resolveBookingSummary(booking);
    return summary.grandTotal
        ?? booking.paymentDetails?.total
        ?? booking.totalBookingAmount
        ?? 0;
  }

  static double resolveListGrandTotal(BookingRequestModel booking) {
    return booking.displayGrandTotal;
  }
  static double subTotalBeforeAdditionalCharges(ProviderBookingSummary summary) {
    final additionalTotal = (summary.additionalChargeLines ?? [])
        .where((line) => (line.amount ?? 0) > 0)
        .fold<double>(0, (sum, line) => sum + (line.amount ?? 0));

    if (summary.grossTotal != null) {
      return (summary.grossTotal! - additionalTotal).clamp(0, double.infinity).toDouble();
    }

    final extraServiceTotal = (summary.extraServiceLines ?? [])
        .fold<double>(0, (sum, line) => sum + (line.amount ?? 0));
    final spareTotal = (summary.sparePartLines ?? [])
        .fold<double>(0, (sum, line) => sum + (line.amount ?? 0));

    return (summary.serviceAmount ?? 0) + extraServiceTotal + spareTotal;
  }

  static String additionalChargeLineLabel(ProviderBookingSummaryLine line) {
    if (line.name != null && line.name!.trim().isNotEmpty) {
      return line.name!.trim();
    }

    final configLabel = Get.find<SplashController>().configModel.content?.additionalChargeLabelName;
    if (configLabel != null && configLabel.trim().isNotEmpty) {
      return configLabel.trim();
    }

    return 'additional_charges'.tr;
  }


}