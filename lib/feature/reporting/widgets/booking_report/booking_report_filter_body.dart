import 'package:demandium_provider/common/widgets/custom_date_picker.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class BookingReportFilterBody extends StatefulWidget {
  const BookingReportFilterBody({super.key});

  @override
  State<BookingReportFilterBody> createState() => _BookingReportFilterBodyState();
}

class _BookingReportFilterBodyState extends State<BookingReportFilterBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<BookingReportController>().prepareBookingReportFilterOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingReportController>(
      builder: (bookingReportController) {
        if (bookingReportController.isFilterOptionsLoading) {
          return const Center(child: CustomLoader());
        }

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeSmall,
            horizontal: Get.width * .04,
          ),
          decoration: BoxDecoration(
            color: Get.isDarkMode
                ? Theme.of(context).cardColor.withValues(alpha: 0.5)
                : Theme.of(context).cardColor,
          ),
          child: Column(
            children: [
              ReportCustomDropdownButton(
                label: 'select_zone'.tr,
                translateLabels: false,
                value: bookingReportController.selectedZoneName,
                items: bookingReportController.zoneNameList.isNotEmpty
                    ? bookingReportController.zoneNameList
                    : ['select'.tr],
                onChanged: bookingReportController.zoneNameList.isNotEmpty
                    ? (newValue) {
                        bookingReportController.setSelectedDropdownValue(
                          newValue!,
                          type: 'zone',
                        );
                      }
                    : null,
              ),
              ReportCustomDropdownButton(
                label: 'category'.tr,
                translateLabels: false,
                value: bookingReportController.selectedCategoryName,
                items: bookingReportController.categoryNameList.isNotEmpty
                    ? bookingReportController.categoryNameList
                    : ['select'.tr],
                onChanged: bookingReportController.categoryNameList.isNotEmpty
                    ? (newValue) {
                        bookingReportController.setSelectedDropdownValue(
                          newValue!,
                          type: 'category',
                        );
                      }
                    : null,
              ),
              ReportCustomDropdownButton(
                label: 'sub_category'.tr,
                translateLabels: false,
                value: bookingReportController.selectedSubcategoryName,
                items: bookingReportController.subcategoryNameList.isNotEmpty
                    ? bookingReportController.subcategoryNameList
                    : ['select'.tr],
                onChanged: bookingReportController.subcategoryNameList.isNotEmpty
                    ? (newValue) {
                        bookingReportController.setSelectedDropdownValue(
                          newValue!,
                          type: 'subcategory',
                        );
                      }
                    : null,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              ReportCustomDropdownButton(
                label: 'select_date'.tr,
                value: bookingReportController.dateRange ?? 'all_time',
                items: bookingReportController.dateRangeDropdownValue,
                onChanged: (newValue) {
                  bookingReportController.setSelectedDropdownValue(
                    newValue!,
                    type: 'date_range',
                  );
                },
              ),
              if (bookingReportController.dateRange == 'custom_date')
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: CustomDatePicker(
                          title: 'from'.tr,
                          text: bookingReportController.startDate != null
                              ? bookingReportController.dateFormat
                                  .format(bookingReportController.startDate!)
                                  .toString()
                              : 'from_date'.tr,
                          image: Images.calender,
                          requiredField: false,
                          selectDate: () => bookingReportController.selectDate(
                            'start',
                            context,
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Expanded(
                        child: CustomDatePicker(
                          title: 'to'.tr,
                          text: bookingReportController.endDate != null
                              ? bookingReportController.dateFormat
                                  .format(bookingReportController.endDate!)
                                  .toString()
                              : 'to_date'.tr,
                          image: Images.calender,
                          requiredField: false,
                          selectDate: () => bookingReportController.selectDate(
                            'end',
                            context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    btnTxt: 'clear'.tr,
                    height: 40,
                    width: 110,
                    onPressed: () {
                      bookingReportController.resetValue();
                      bookingReportController.updatedIsFilteredValue();
                      bookingReportController.getBookingReportData(1);
                    },
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  CustomButton(
                    btnTxt: 'filter'.tr,
                    height: 40,
                    width: 110,
                    isLoading: bookingReportController.isLoading,
                    onPressed: () async {
                      if (bookingReportController.dateRange == 'custom_date' &&
                          bookingReportController.startDate == null) {
                        showCustomSnackBar(
                          'enter_from_date'.tr,
                          type: ToasterMessageType.info,
                        );
                      } else if (bookingReportController.dateRange ==
                              'custom_date' &&
                          bookingReportController.endDate == null) {
                        showCustomSnackBar(
                          'enter_to_date'.tr,
                          type: ToasterMessageType.info,
                        );
                      } else {
                        await bookingReportController.getBookingReportData(
                          1,
                          reload: true,
                        );
                        bookingReportController.updatedIsFilteredValue();
                        Get.back();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
