import 'package:demandium_provider/feature/booking_details/model/bookings_details_model.dart';
import 'package:demandium_provider/feature/booking_requests/model/request_model.dart';
import 'package:demandium_provider/feature/splash/controller/splash_controller.dart';
import 'package:get/get.dart';

class BookingHelper{
  static double getSubTotalCost(BookingDetailsContent booking) {
    double subTotal = 0;
    for (var element in booking.details!) {
      subTotal = subTotal + ((element.serviceCost ?? 0) * (element.quantity ?? 1));
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
      final resolvedGrand = resolveInvoiceGrandTotal(booking, summary: fromApi);
      if (fromApi.grandTotal == null ||
          (fromApi.grandTotal! - resolvedGrand).abs() > 0.009) {
        fromApi.grandTotal = resolvedGrand;
      }
      return fromApi;
    }
    return buildBookingSummaryFallback(booking, base: fromApi);
  }

  /// Invoice grand total (subtotal + additional charges + tax). Never use [PaymentDetailsSummary.total].
  static double resolveInvoiceGrandTotal(
    BookingDetailsContent booking, {
    ProviderBookingSummary? summary,
  }) {
    summary ??= booking.bookingSummary;
    if (summary?.grandTotal != null && summary!.grandTotal! > 0.009) {
      return summary.grandTotal!;
    }
    if (booking.payableGrandTotal != null && booking.payableGrandTotal! > 0.009) {
      return booking.payableGrandTotal!;
    }
    final computed = computeGrandTotalFromBreakdown(booking, summary: summary);
    if (computed > 0.009) {
      return computed;
    }
    return booking.totalBookingAmount ?? 0;
  }

  static double computeGrandTotalFromBreakdown(
    BookingDetailsContent booking, {
    ProviderBookingSummary? summary,
  }) {
    summary ??= booking.bookingSummary;
    double total = getDiscountedSubTotal(booking);
    final additionalLines =
        summary?.additionalChargeLines ?? getAdditionalChargeLines(booking);
    for (final line in additionalLines) {
      total += line.amount ?? 0;
    }
    final taxAmount = summary?.tax ?? booking.totalTaxAmount ?? 0;
    if (summary?.hasTax == true || taxAmount > 0.009) {
      total += taxAmount;
    }
    return total;
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
    final grandTotalValue = resolveInvoiceGrandTotal(booking, summary: base);
    final paid = booking.paymentDetails?.amountPaidDisplay ??
        base?.totalPaid ??
        0;
    final due = booking.paymentDetails?.dueBalance ??
        base?.dueAmount ??
        (grandTotalValue - paid).clamp(0, double.infinity);

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
    return resolveInvoiceGrandTotal(booking);
  }

  static double? resolveDisputedFinalBookingAmount(BookingDetailsContent booking) {
    final disputed = booking.disputedSettlement;
    if (disputed?.hasDisputedSettlement == true) {
      final amount = disputed?.finalBookingAmount ?? disputed?.retainedFromCustomer;
      if (amount != null) {
        return amount;
      }
    }
    final payment = booking.paymentDetails;
    if (payment?.isDisputedSettlement == true) {
      return payment?.finalBookingAmount ?? payment?.retainedAmount ?? payment?.total;
    }
    return null;
  }

  static bool hasDisputedSettlement(BookingDetailsContent booking) {
    if (booking.disputedSettlement?.hasDisputedSettlement == true) {
      return true;
    }
    return booking.paymentDetails?.isDisputedSettlement == true;
  }

  static double? resolveDisputedCustomerPaidTotal(BookingDetailsContent booking) {
    final disputed = booking.disputedSettlement;
    if (disputed?.hasDisputedSettlement == true && disputed?.customerPaidTotal != null) {
      return disputed!.customerPaidTotal;
    }
    return booking.paymentDetails?.customerPaidTotal ?? booking.paymentDetails?.amountPaidDisplay;
  }

  static double? resolveDisputedRefundTotal(BookingDetailsContent booking) {
    final disputed = booking.disputedSettlement;
    if (disputed?.hasDisputedSettlement == true && disputed?.refundTotal != null) {
      return disputed!.refundTotal;
    }
    return booking.paymentDetails?.refundedAmount ?? booking.paymentDetails?.refundTotal;
  }

  static double? resolveRefundedAmount(BookingDetailsContent booking) {
    final disputedRefund = resolveDisputedRefundTotal(booking);
    if (disputedRefund != null && disputedRefund > 0.009) {
      return disputedRefund;
    }
    final refunded = booking.paymentDetails?.refundedAmount;
    if (refunded != null && refunded > 0.009) {
      return refunded;
    }
    return null;
  }

  static double resolvePaymentDueBalance(PaymentDetailsSummary payment) {
    if (payment.dueBalance != null) {
      return payment.dueBalance!.clamp(0.0, double.infinity);
    }
    final total = payment.total ?? 0;
    final paid = payment.amountPaidDisplay ?? 0;
    return (total - paid).clamp(0.0, double.infinity).toDouble();
  }

  static bool isWriteoffSettledBooking(BookingDetailsContent booking) {
    final payment = booking.paymentDetails;
    if (payment?.isWriteoffSettled == true) {
      return true;
    }
    final writeoff = payment?.scaledLossWriteoffAmount
        ?? booking.revenueSettlement?.scaledLossWriteoffAmount
        ?? 0;
    return writeoff > 0.009;
  }

  static double getWriteoffSettlementAmount(BookingDetailsContent booking) {
    final payment = booking.paymentDetails;
    if ((payment?.scaledLossWriteoffAmount ?? 0) > 0.009) {
      return payment!.scaledLossWriteoffAmount!;
    }
    return booking.revenueSettlement?.scaledLossWriteoffAmount ?? 0;
  }

  static double resolveBookingDueBalance(BookingDetailsContent booking) {
    if (hasDisputedSettlement(booking)) {
      return 0;
    }
    if (isWriteoffSettledBooking(booking)) {
      return 0;
    }

    final payment = booking.paymentDetails;
    if (payment != null) {
      final due = payment.dueBalance;
      if (due != null) {
        return due.clamp(0.0, double.infinity);
      }
      return resolvePaymentDueBalance(payment);
    }

    final summaryDue = resolveBookingSummary(booking).dueAmount;
    if (summaryDue != null) {
      return summaryDue.clamp(0.0, double.infinity);
    }

    final grandTotal = resolveGrandTotal(booking);
    double paid = 0;
    if (booking.partialPayments != null && booking.partialPayments!.isNotEmpty) {
      for (final partial in booking.partialPayments!) {
        paid += partial.paidAmount ?? 0;
      }
    } else if (booking.isPaid == 1) {
      paid = grandTotal;
    }
    return (grandTotal - paid).clamp(0, double.infinity);
  }

  static bool canCompleteBooking(BookingDetailsContent booking) {
    final due = resolveBookingDueBalance(booking);
    if (booking.paymentDetails?.canComplete == true) {
      return true;
    }
    if (booking.paymentDetails?.canComplete == false) {
      return false;
    }
    return due <= 0.009;
  }

  static bool canRecordCustomerPayment(BookingDetailsContent booking) {
    if (hasDisputedSettlement(booking)) {
      return false;
    }

    final status = (booking.bookingStatus ?? '').toLowerCase();
    if (const {'canceled', 'cancelled', 'refunded'}.contains(status)) {
      return false;
    }

    final due = resolveBookingDueBalance(booking);
    if (due <= 0.009) return false;

    if (booking.paymentDetails?.canRecordPayment == true) {
      return true;
    }

    if (status == 'completed') {
      return booking.paymentDetails?.canRecordPayment != false;
    }

    return const {'pending', 'accepted', 'ongoing', 'on_hold'}.contains(status);
  }

  static String resolveRecordPaymentBookingId(
    BookingDetailsContent booking, {
    String? fallbackBookingId,
  }) {
    final parentId = booking.parentBookingId?.trim();
    if (parentId != null && parentId.isNotEmpty) {
      return parentId;
    }
    final fallback = fallbackBookingId?.trim();
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }
    return booking.id ?? '';
  }

  static double? resolvePendingRefundAmount(BookingDetailsContent booking) {
    final disputed = booking.disputedSettlement;
    if (disputed?.hasDisputedSettlement == true) {
      final pending = disputed?.pendingRefund;
      if (pending != null && pending > 0.009) {
        return pending;
      }
      return null;
    }
    final pending = booking.paymentDetails?.pendingRefund ?? booking.paymentDetails?.refundableRemaining;
    if (pending != null && pending > 0.009) {
      return pending;
    }
    return null;
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