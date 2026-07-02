import 'package:demandium_provider/feature/reporting/helper/report_api_helper.dart';
import 'package:demandium_provider/feature/reporting/helper/report_filter_helper.dart';
import 'package:demandium_provider/feature/reporting/model/booking_report_model.dart';
import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class BookingReportController extends GetxController implements GetxService {
  final ReportRepo reportRepo;
  BookingReportController({required this.reportRepo});

  List<String> dateRangeDropdownValue = [
    'all_time','this_week',"last_week","last_15_days","this_month","last_month","this_year","last_year",
    "this_year_1st_quarter","this_year_2nd_quarter","this_year_3rd_quarter","this_year_4th_quarter","custom_date"
  ];

  int? _pageSize;
  int _offset = 1;

  int get offset => _offset;
  int? get pageSize => _pageSize;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _reportLoadFinished = false;
  bool get reportLoadFinished => _reportLoadFinished;

  bool get hasBookingData => _bookingReportModel?.content != null;

  String? _loadError;
  String? get loadError => _loadError;

  int _requestSeq = 0;

  String? _dateRange;
  String? get dateRange => _dateRange;

  List<String> bookingStatus = [
    'all',
    'pending',
    'accepted',
    'ongoing',
    'on_hold',
    'completed',
    'canceled',
    'refunded',
  ];
  String? _selectedBookingStatus;
  String? get selectedBookingStatus => _selectedBookingStatus;

  final List<String> _zoneNameList= [];
  List<ZonesList> _zonesList =[];
  List<String> get zoneNameList=> _zoneNameList;
  String? _selectedZoneName;
  String? get selectedZoneName => _selectedZoneName;
  String? _selectedZoneId;
  String? get selectedZoneId => _selectedZoneId;


  final List<String> _categoryNameList = [];
  List<Categories> _categoriesList =[];
  List<String> get categoryNameList => _categoryNameList ;
  String? _selectedCategoryName;
  String? get selectedCategoryName => _selectedCategoryName;
  String? _selectedCategoryId;
  String? get selectedCategoryId => _selectedCategoryId;

  List<String> _subcategoryNameList = [];
  List<SubCategories> _subcategoriesList =[];
  List<String> get subcategoryNameList => _subcategoryNameList ;
  String? _selectedSubcategoryName;
  String? get selectedSubcategoryName => _selectedSubcategoryName;
  String? _selectedSubcategoryId;
  String? get selectedSubcategoryId => _selectedSubcategoryId;


  BookingReportModel? _bookingReportModel;
  BookingReportModel? get bookingReportModel => _bookingReportModel;

  List<BookingFilterData>  _bookingReportFilterData=[];
  List<BookingFilterData> get bookingReportFilterData => _bookingReportFilterData;

  final List<SubscriptionModelData> _subscribedBookingFilterSource = [];
  Set<String> _allowedZoneIds = {};
  Set<String> _allowedCategoryIds = {};
  bool _isFilterOptionsLoading = false;
  bool get isFilterOptionsLoading => _isFilterOptionsLoading;
  bool _filterOptionsPrepared = false;

  ScrollController scrollController = ScrollController();

  List<Map<String,dynamic>> barChartData =[];

  bool _isFiltered = false;
  bool get isFiltered => _isFiltered;


  DateTime? _startDate;
  DateTime? _endDate;
  String? _fromDate;
  String? _toDate;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-d');
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  DateFormat get dateFormat => _dateFormat;


  @override
  void onInit() {
    super.onInit();

    scrollController.addListener(() {
      if (!scrollController.hasClients) return;
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (!_isLoading && _pageSize != null && _offset < _pageSize!) {
          getBookingReportData(_offset + 1, reload: true);
        }
      }
    });

  }

  Future<void> prepareBookingReportFilterOptions() async {
    if (_isFilterOptionsLoading) return;
    if (_filterOptionsPrepared) {
      _rebuildSubcategoryFilterOptions();
      _sanitizeFilterSelections();
      update();
      return;
    }
    _isFilterOptionsLoading = true;
    update();

    try {
      _zoneNameList.clear();
      _categoryNameList.clear();
      _subcategoryNameList.clear();
      _zonesList.clear();
      _categoriesList.clear();
      _subcategoriesList.clear();
      _subscribedBookingFilterSource.clear();

      final data = await ReportFilterHelper.loadProviderZonesAndSubscriptions();
      _zonesList.addAll(data.zones);
      _zoneNameList.addAll(data.zoneNames);
      _categoriesList.addAll(data.categories);
      _categoryNameList.addAll(data.categoryNames);
      _subscribedBookingFilterSource.addAll(data.subscriptions);
      _allowedZoneIds = ReportFilterHelper.providerZoneIds(data);
      _allowedCategoryIds = ReportFilterHelper.subscribedCategoryIds(
        _subscribedBookingFilterSource,
      );
      if (_allowedCategoryIds.isEmpty) {
        _allowedCategoryIds = _categoriesList
            .map((c) => ReportFilterHelper.normalizeId(c.id))
            .where((id) => id.isNotEmpty)
            .toSet();
      }
      _rebuildSubcategoryFilterOptions();
      _sanitizeFilterSelections();
      _filterOptionsPrepared = _zoneNameList.isNotEmpty;
    } finally {
      _isFilterOptionsLoading = false;
      update();
    }
  }

  void _sanitizeFilterSelections() {
    ReportFilterHelper.sanitizeDropdownSelections(
      zoneNameList: _zoneNameList,
      categoryNameList: _categoryNameList,
      subcategoryNameList: _subcategoryNameList,
      selectedZoneName: _selectedZoneName,
      selectedCategoryName: _selectedCategoryName,
      selectedSubcategoryName: _selectedSubcategoryName,
      onClear: ({zoneName, categoryName, subcategoryName}) {
        _selectedZoneName = zoneName;
        if (zoneName == null) {
          _selectedZoneId = null;
        } else {
          for (final element in _zonesList) {
            if (element.name == zoneName) {
              _selectedZoneId = ReportFilterHelper.normalizeId(element.id);
              break;
            }
          }
        }
        _selectedCategoryName = categoryName;
        if (categoryName == null) {
          _selectedCategoryId = null;
        } else {
          for (final element in _categoriesList) {
            if (element.name == categoryName) {
              _selectedCategoryId = ReportFilterHelper.normalizeId(element.id);
              break;
            }
          }
        }
        _selectedSubcategoryName = subcategoryName;
        if (subcategoryName == null) {
          _selectedSubcategoryId = null;
        } else {
          for (final element in _subcategoriesList) {
            if (element.name == subcategoryName) {
              _selectedSubcategoryId = ReportFilterHelper.normalizeId(element.id);
              break;
            }
          }
        }
        if (categoryName == null) {
          _rebuildSubcategoryFilterOptions();
        }
      },
    );
  }

  void _mergeApiFilterOptionsFromResponse(dynamic content) {
    if (content == null) return;
    ReportFilterHelper.mergeApiFilterOptions(
      zonesList: _zonesList,
      zoneNameList: _zoneNameList,
      categoriesList: _categoriesList,
      categoryNameList: _categoryNameList,
      subcategoriesList: _subcategoriesList,
      allowedZoneIds: _allowedZoneIds,
      allowedCategoryIds: _allowedCategoryIds,
      subscriptions: _subscribedBookingFilterSource,
      apiZones: content.zones,
      apiCategories: content.categories,
      apiSubCategories: content.subCategories,
    );
    _syncCategoryAndSubcategoryNameLists();
  }

  void _syncCategoryAndSubcategoryNameLists() {
    if (_categoryNameList.isEmpty) {
      _categoryNameList.addAll(
        _categoriesList.map((c) => c.name ?? '').where((n) => n.isNotEmpty),
      );
    }
    _rebuildSubcategoryFilterOptions();
  }

  void _rebuildSubcategoryFilterOptions() {
    _subcategoryNameList.clear();
    _subcategoriesList.clear();

    if (_selectedCategoryId == null) {
      final seen = <String>{};
      for (final item in _subscribedBookingFilterSource) {
        final sub = item.subCategory;
        final id = sub?.id ?? item.subCategoryId;
        final name = sub?.name?.trim() ?? '';
        if (id == null || id.isEmpty || name.isEmpty || seen.contains(id)) continue;
        seen.add(id);
        _subcategoriesList.add(SubCategories(id: id, parentId: item.categoryId, name: name));
        _subcategoryNameList.add(name);
      }
      _selectedSubcategoryId = null;
      _selectedSubcategoryName = null;
      return;
    }

    _subcategoriesList.addAll(
      ReportFilterHelper.subscribedSubcategoriesForCategory(
        subscriptions: _subscribedBookingFilterSource,
        categoryId: _selectedCategoryId!,
      ),
    );
    for (final element in _subcategoriesList) {
      if (element.name != null) {
        _subcategoryNameList.add(element.name!);
      }
    }

    if (_subcategoryNameList.length > 1) {
      _subcategoryNameList.insert(0, 'all');
      _selectedSubcategoryName = 'all';
      _selectedSubcategoryId = null;
    } else if (_subcategoryNameList.length == 1) {
      _selectedSubcategoryName = _subcategoryNameList[0];
      _selectedSubcategoryId = _subcategoriesList[0].id;
    } else {
      _selectedSubcategoryId = null;
      _selectedSubcategoryName = null;
    }
  }

  Future<void> getBookingReportData(int offset,{bool reload =false}) async {
    final requestSeq = ++_requestSeq;
    _offset = offset;
    if(reload || offset == 1){
      if (offset == 1) {
        if (_bookingReportModel == null) {
          _reportLoadFinished = false;
        }
        _loadError = null;
      }
      _isLoading = true;
      update();
    }


    final data = ReportApiHelper.baseFilterBody(
      dateRange: _dateRange,
      from: _fromDate,
      to: _toDate,
      zoneId: _selectedZoneId,
      categoryId: _selectedCategoryId,
      subCategoryId: _selectedSubcategoryId,
      bookingStatus: _selectedBookingStatus ?? 'all',
    );

    try {
      Response response = await reportRepo.getBookingReportData(
          offset,data
      );
      if(ReportApiHelper.isSuccess(response)){
        _loadError = null;
        _bookingReportModel = BookingReportModel.fromJson(response.body);
        final content = _bookingReportModel?.content;
        if(content != null){
          _pageSize = content.filterData?.lastPage ?? 1;
          if(offset == 1){
            try {
              _mergeApiFilterOptionsFromResponse(content);
            } catch (_) {
              // Filter merge must not block report rendering.
            }
            _bookingReportFilterData = List.from(content.filterData?.data ?? []);
          } else {
            _bookingReportFilterData.addAll(content.filterData?.data ?? []);
          }

          barChartData = [];
          try {
            final chartData = content.chartData;
            final timeline = chartData?.timeline;
            if (chartData != null && timeline != null && timeline.isNotEmpty) {
              for (int i = 0; i < timeline.length; i++) {
                final bookingAmount = (i < (chartData.bookingAmount?.length ?? 0))
                    ? chartData.bookingAmount![i]
                    : 0.0;
                final taxAmount = (i < (chartData.taxAmount?.length ?? 0))
                    ? chartData.taxAmount![i].toString()
                    : '0';
                final adminCommission = (i < (chartData.adminCommission?.length ?? 0))
                    ? chartData.adminCommission![i].toString()
                    : '0';
                barChartData.add({
                  'timeline': timeline[i].toString(),
                  'Amount': bookingAmount,
                  'tax': PriceConverter.convertPrice(double.tryParse(taxAmount)),
                  'commission': PriceConverter.convertPrice(double.tryParse(adminCommission)),
                });
              }
            }
          } catch (_) {
            barChartData = [];
          }
        } else {
          _loadError = 'no_data_found';
        }
      }else{
        _bookingReportModel = null;
        _bookingReportFilterData = [];
        barChartData = [];
        _loadError = response.statusText?.isNotEmpty == true
            ? response.statusText
            : 'no_data_found';
      }
    } catch (_) {
      if (offset == 1) {
        _bookingReportModel = null;
        _bookingReportFilterData = [];
        barChartData = [];
        _loadError = 'no_data_found';
      }
    } finally {
      _isLoading = false;
      if (requestSeq == _requestSeq) {
        _reportLoadFinished = true;
        update();
      }
    }
  }

  void selectDate(String type, BuildContext context){
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    ).then((date) {
      if (type == 'start'){
        _startDate = date;
        _fromDate = _dateFormat.format(_startDate!).toString();
      }else{
        _endDate = date;
        _toDate = _dateFormat.format(_endDate!).toString();
      }
      if(date == null){

      }
      update();
    });
  }

  void setSelectedDropdownValue(String dropdownValue,{String? type}){

    if(type=='zone'){
      for (var element in _zonesList) {
        if(element.name==dropdownValue){
          _selectedZoneId = ReportFilterHelper.normalizeId(element.id);
          _selectedZoneName = dropdownValue;
        }
      }
    }else if(type=='category'){
      for (var element in _categoriesList) {
        if(element.name==dropdownValue){
          _selectedCategoryId = ReportFilterHelper.normalizeId(element.id);
          _selectedCategoryName = dropdownValue;
        }
      }
      _rebuildSubcategoryFilterOptions();
    }else if(type=='subcategory'){
      if (dropdownValue == 'all') {
        _selectedSubcategoryId = null;
        _selectedSubcategoryName = 'all';
      } else {
        for (var element in _subcategoriesList) {
          if(element.name==dropdownValue){
            _selectedSubcategoryId = ReportFilterHelper.normalizeId(element.id);
            _selectedSubcategoryName = dropdownValue;
          }
        }
      }
    }else if(type=='booking_status'){
      _selectedBookingStatus=dropdownValue;
    }else if(type=='date_range'){
      _dateRange = dropdownValue;
    }
    if (type != 'booking_status') {
      update();
    }
  }

  void resetDropDownValue(){
    _zonesList =[];
    _categoriesList =[];
    _subcategoriesList=[];
  }

  void resetValue(){
    _requestSeq++;
    _filterOptionsPrepared = false;
    _reportLoadFinished = false;
    _loadError = null;
    _pageSize = null;
    _offset = 1;
    _bookingReportModel = null;
    _bookingReportFilterData = [];
    barChartData = [];
    _toDate= null;
    _fromDate= null;
    _startDate= null;
    _endDate = null;
    _dateRange = null;
    _selectedCategoryId=null;
    _selectedCategoryName=null;
    _selectedSubcategoryId=null;
    _selectedSubcategoryName = null;
    _selectedZoneId = null;
    _selectedZoneName = null;
    _selectedBookingStatus = null;
    _isFiltered = false;
    _rebuildSubcategoryFilterOptions();
    update();
  }

  void removeFilteredItem({required String removeItem}){

    if(removeItem == "zone"){
      _selectedZoneName = null;
      _selectedZoneId = null;
    } else if (removeItem == 'category'){
      _selectedCategoryName = null;
      _selectedCategoryId = null;
    }else if(removeItem == 'subCategory'){
      _selectedSubcategoryId = null;
      _selectedSubcategoryName = null;
    }else if(removeItem == 'status'){
      _selectedBookingStatus = null;
    }else if(removeItem == "date_range"){
      _startDate = null;
      _endDate = null;
      _dateRange = null;
    }

    if(_selectedZoneName == null && _dateRange == null
        && _selectedCategoryName == null && _selectedSubcategoryName == null &&
        _selectedBookingStatus == null){
      _isFiltered = false;
    }
    update();
  }

  void updatedIsFilteredValue({ bool shouldUpdate = true}){
    if(_selectedZoneName == null && _dateRange == null
        && _selectedCategoryName == null && _selectedSubcategoryName == null &&
        _selectedBookingStatus == null){
      _isFiltered = false;
    }else{
      _isFiltered = true;
    }

    if(shouldUpdate){
      update();
    }
  }


}