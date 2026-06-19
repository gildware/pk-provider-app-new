import 'package:demandium_provider/helper/booking_list_filter_tabs.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class BookingRequestMenuBar extends StatefulWidget{
  const BookingRequestMenuBar({super.key});

  @override
  State<BookingRequestMenuBar> createState() => _BookingRequestMenuBarState();
}

class _BookingRequestMenuBarState extends State<BookingRequestMenuBar> {
  BookingRequestController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.menuScrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.horizontal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingRequestController>(
      id: BookingRequestController.bookingTabsUpdateId,
      builder: (bookingRequestController) {
        final bookingCount = bookingRequestController.bookingCount;
        final visibleTabs = bookingRequestController.bookingRequestStatusList
            .where((tab) => bookingFilterTabShouldShow(tab, bookingCount))
            .toList(growable: false);
        final selectedStatus = bookingRequestController.bookingStatus;

        return Column(children: [
          if (bookingRequestController.selectedServiceType != ServiceType.all)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                bookingRequestController.selectedServiceType == ServiceType.regular
                    ? "regular_booking".tr
                    : "repeat_booking".tr,
              ),
            ),
          Container(
            color: Theme.of(context).colorScheme.surface,
            width: double.infinity,
            height: visibleTabs.isEmpty ? 0 : 52,
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
            child: visibleTabs.isEmpty
                ? const SizedBox.shrink()
                : ListView.builder(
                    key: const PageStorageKey('booking_request_tabs'),
                    controller: controller.menuScrollController,
                    itemCount: visibleTabs.length,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    itemBuilder: (context, index) {
                      final tab = visibleTabs[index];
                      if (!bookingFilterTabShouldShow(tab, bookingCount)) {
                        return const SizedBox.shrink();
                      }
                      return InkWell(
                        onTap: () => bookingRequestController.switchBookingTab(tab),
                        child: AutoScrollTag(
                          controller: controller.menuScrollController!,
                          key: ValueKey(tab),
                          index: index,
                          highlightColor: Colors.transparent,
                          child: BookingRequestMenuItem(
                            bookingCount: bookingCount,
                            title: tab,
                            isSelected: selectedStatus == tab,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ]);
      },
    );
  }
}
