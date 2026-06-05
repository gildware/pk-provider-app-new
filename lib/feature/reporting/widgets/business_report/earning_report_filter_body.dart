import 'package:demandium_provider/common/widgets/custom_date_picker.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';

class EarningReportFilterBody extends StatefulWidget {
  const EarningReportFilterBody({super.key});

  @override
  State<EarningReportFilterBody> createState() => _EarningReportFilterBodyState();
}

class _EarningReportFilterBodyState extends State<EarningReportFilterBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<BusinessReportController>().prepareEarningReportFilterOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessReportController>(
      builder: (businessReportController) {
        if (businessReportController.isFilterOptionsLoading) {
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
                value: businessReportController.selectedZoneName,
                items: businessReportController.zoneNameList.isNotEmpty
                    ? businessReportController.zoneNameList
                    : ['select'.tr],
                onChanged: businessReportController.zoneNameList.isNotEmpty
                    ? (newValue) {
                        businessReportController.setSelectedDropdownValue(
                          newValue!,
                          type: 'zone',
                        );
                      }
                    : null,
              ),
              ReportCustomDropdownButton(
                label: 'category'.tr,
                translateLabels: false,
                value: businessReportController.selectedCategoryName,
                items: businessReportController.categoryNameList.isNotEmpty
                    ? businessReportController.categoryNameList
                    : ['select'.tr],
                onChanged: businessReportController.categoryNameList.isNotEmpty
                    ? (newValue) {
                        businessReportController.setSelectedDropdownValue(
                          newValue!,
                          type: 'category',
                        );
                      }
                    : null,
              ),
              ReportCustomDropdownButton(
                label: 'sub_category'.tr,
                translateLabels: false,
                value: businessReportController.selectedSubcategoryName,
                items: businessReportController.subcategoryNameList.isNotEmpty
                    ? businessReportController.subcategoryNameList
                    : ['select'.tr],
                onChanged: businessReportController.subcategoryNameList.isNotEmpty
                    ? (newValue) {
                        businessReportController.setSelectedDropdownValue(
                          newValue!,
                          type: 'subcategory',
                        );
                      }
                    : null,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              ReportCustomDropdownButton(
                label: 'select_date'.tr,
                value: businessReportController.dateRange ?? 'all_time',
                items: businessReportController.dateRangeDropdownValue,
                onChanged: (newValue) {
                  businessReportController.setSelectedDropdownValue(
                    newValue!,
                    type: 'date_range',
                  );
                },
              ),
              if (businessReportController.dateRange == 'custom_date')
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: CustomDatePicker(
                        title: 'from'.tr,
                        text: businessReportController.startDate != null
                            ? businessReportController.dateFormat
                                .format(businessReportController.startDate!)
                                .toString()
                            : 'from_date'.tr,
                        image: Images.calender,
                        requiredField: false,
                        selectDate: () => businessReportController.selectDate(
                          'start',
                          context,
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(
                      child: CustomDatePicker(
                        title: 'to'.tr,
                        text: businessReportController.endDate != null
                            ? businessReportController.dateFormat
                                .format(businessReportController.endDate!)
                                .toString()
                            : 'to_date'.tr,
                        image: Images.calender,
                        requiredField: false,
                        selectDate: () => businessReportController.selectDate(
                          'end',
                          context,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    btnTxt: 'clear'.tr,
                    height: 35,
                    width: 100,
                    onPressed: () async {
                      businessReportController.resetValue();
                      await businessReportController.getBusinessReportEarningData(
                        1,
                        reload: false,
                      );
                      businessReportController.updatedIsFilteredValue();
                    },
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  CustomButton(
                    btnTxt: 'filter'.tr,
                    height: 35,
                    width: 100,
                    isLoading: businessReportController.isLoading,
                    onPressed: () async {
                      await businessReportController.getBusinessReportEarningData(
                        1,
                        reload: true,
                      );
                      Get.back();
                      businessReportController.updatedIsFilteredValue();
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
