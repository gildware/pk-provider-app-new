import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';


class ConversationController extends GetxController with GetSingleTickerProviderStateMixin implements GetxService   {
  final ConversationRepo conversationRepo;
  ConversationController({required this.conversationRepo});


  TabController? tabController;



  List <XFile>? _pickedImageFiles =[];
  List <XFile>? get pickedImageFile => _pickedImageFiles;

  FilePickerResult? _otherFile;
  FilePickerResult? get otherFile => _otherFile;

  File? _file;
  File? get file=> _file;
  List<PlatformFile>? objFile;

  int? _channelPageSize;
  int? _channelOffset = 1;
  int? get channelPageSize => _channelPageSize;
  int? get channelOffset => _channelOffset;

  int? _messagePageSize;
  int? _messageOffset = 1;
  
  int? get messagePageSize => _messagePageSize;
  int? get messageOffset => _messageOffset;

  bool _isLoading = false;
  bool get isLoading => _isLoading;


  bool? _paginationLoading = false;
  bool? get paginationLoading => _paginationLoading;

  bool _isFirst = false;
  bool get isFirst => _isFirst ;

  bool _isClickedOnMessage = false;
  bool get isClickedOnMessage => _isClickedOnMessage;

  bool _isClickedOnImageOrFile = false;
  bool get isClickedOnImageOrFile => _isClickedOnImageOrFile;

  bool _isActiveSuffixIcon = false;
  bool get isActiveSuffixIcon => _isActiveSuffixIcon;

  bool _isSearchComplete = true;
  bool get isSearchComplete => _isSearchComplete;

  bool _pickedFIleCrossMaxLength = false;
  bool get pickedFIleCrossMaxLength => _pickedFIleCrossMaxLength;

  String _onMessageTimeShowID = '';
  String get onMessageTimeShowID => _onMessageTimeShowID;

  String _onImageOrFileTimeShowID = '';
  String get onImageOrFileTimeShowID => _onImageOrFileTimeShowID;

  List<ChannelData>? _customerChannelList ;
  List<ChannelData>? get customerChannelList => _customerChannelList;

  List<ChannelData>? _servicemanChannelList ;
  List<ChannelData>? get servicemanChannelList => _servicemanChannelList;

  List<ChannelData>? _searchedChannelList = [];
  List<ChannelData>? get searchedChannelList => _searchedChannelList;

  List<ChannelData> _searchedCustomerChannelList = [];
  List<ChannelData> get searchedCustomerChannelList => _searchedCustomerChannelList;

  List<ChannelData> _searchedServicemanChannelList = [];
  List<ChannelData> get searchedServicemanChannelList => _searchedServicemanChannelList;


  List<MultipartBody> _selectedImageList = [];
  List<MultipartBody> get selectedImageList => _selectedImageList;


  List<ConversationData>? _conversationList;
  List<ConversationData>? get conversationList => _conversationList;

  ChannelData? _adminConversation;
  ChannelData? get adminConversationModel => _adminConversation;



  String _channelId = '';
  String get channelId => _channelId;


  final ScrollController channelScrollController1 = ScrollController();
  final ScrollController channelScrollController2 = ScrollController();
  final ScrollController messageScrollController = ScrollController();

  var conversationController = TextEditingController();
  var searchController = TextEditingController();


  void setChannelId(String channelId){
    _channelId = channelId;
    conversationController.text = "";

  }

  @override
  void onInit(){
    super.onInit();

    // SERVICEMAN_DISABLED
    tabController = TabController(
      vsync: this,
      length: AppFeatureFlags.servicemanEnabled ? 2 : 1,
    );

    conversationController.text = '';
    channelScrollController1.addListener(() {
      if (channelScrollController1.position.pixels == channelScrollController1.position.maxScrollExtent) {
        if (_channelOffset! < _channelPageSize!) {
          getChannelList(_channelOffset!+1, type: "customer");
        }
      }
    });

    channelScrollController2.addListener(() {
      if (channelScrollController1.position.pixels == channelScrollController1.position.maxScrollExtent) {
        if (_channelOffset! < _channelPageSize!) {
          getChannelList(_channelOffset!+1, type: "serviceman");
        }
      }
    });

    messageScrollController.addListener(() {
      if (messageScrollController.position.pixels == messageScrollController.position.maxScrollExtent) {
        if (_messageOffset! < _messagePageSize!) {
          getConversation(_channelId,_messageOffset!+1, isFromPagination: true);
        }
      }
    });
  }


  Future<void> pickMultipleImage(bool isRemove,{int? index}) async {

    _pickedFIleCrossMaxLength = false;
    if(isRemove) {
      if(index != null){
        _pickedImageFiles!.removeAt(index);
        _selectedImageList.removeAt(index);
      }
    }else {

      // Use FileValidationHelper for initial validation (extension and per-file size)
      List<XFile> pickImages = await FileValidationHelper.validateAndPickMultipleImages();
      _pickedImageFiles = [];
      _selectedImageList = [];
      objFile = [];

      if (pickImages.isEmpty) {
        update();
        return;
      }

      // Apply conversation-specific validation (file count)
      for (var element in pickImages) {
        if (_pickedImageFiles!.length < AppConstants.maxLimitOfTotalFileSent) {
          _pickedImageFiles!.add(element);
          _selectedImageList.add(MultipartBody('files[${_selectedImageList.length}]', element));
        }
      }

      // Set flag for file count limit
      if(_pickedImageFiles!.length == AppConstants.maxLimitOfTotalFileSent && pickImages.length > AppConstants.maxLimitOfTotalFileSent){
        _pickedFIleCrossMaxLength = true;
      }
    }
    update();
  }

  Future<void> pickOtherFile(bool isRemove, {int? index}) async {

    _pickedFIleCrossMaxLength = false;
    if(isRemove){
      if(objFile!=null){
        objFile!.removeAt(index!);
      }
    }else{

      // Use FileValidationHelper for validation (extension and file size)
      List<PlatformFile> platformFiles = await FileValidationHelper.validateAndPickDocuments();

      objFile = [];
      _pickedImageFiles = [];
      _selectedImageList = [];

      if (platformFiles.isEmpty) {
        update();
        return;
      }

      // Apply conversation-specific validation (file count limit)
      for (var element in platformFiles) {
        if (objFile!.length < AppConstants.maxLimitOfTotalFileSent) {
          objFile!.add(element);
        }
      }

      // Set flag for file count limit
      if(objFile!.length == AppConstants.maxLimitOfTotalFileSent && platformFiles.length > AppConstants.maxLimitOfTotalFileSent){
        _pickedFIleCrossMaxLength = true;
      }
    }
    update();
  }


  Future<void> getSearchedChannelList({String? query, }) async{
    _searchedChannelList = null;
    _isSearchComplete = false;
    _searchedCustomerChannelList = [];
    _searchedServicemanChannelList = [];
    update();

     Response response = await conversationRepo.searchChannelList(queryText: query);

     if(response.statusCode == 200){
       _searchedChannelList = [];
       response.body['content']['data'].forEach((channel){
         _searchedChannelList!.add(ChannelData.fromJson(channel));
       });

       if(_searchedChannelList!.isNotEmpty){
         for (var element in _searchedChannelList!) {
           ConversationUserModel? conversationUser = element.channelUsers?[0].user?.userType != "provider-admin" ? element.channelUsers![0] : element.channelUsers![1];
           if(conversationUser.user?.userType == "customer"){
             _searchedCustomerChannelList.add(element);
           } else if (conversationUser.user?.userType == "provider-serviceman"){
             _searchedServicemanChannelList.add(element);
           }
         }
       }

       if(tabController?.index == 0 && _searchedCustomerChannelList.isEmpty && _searchedServicemanChannelList.isNotEmpty){
         tabController?.index = 1;
       } else if(tabController?.index == 1 && _searchedServicemanChannelList.isEmpty && _searchedCustomerChannelList.isNotEmpty){
         tabController?.index = 0;
       }

     }else{
       ApiChecker.checkApi(response);
     }

    _isSearchComplete = true;
     update();
  }

  Future<void> getChannelList(int offset, {bool isFromPagination = false,bool reload = false, bool isFirst = false, String type = "customer"}) async{
    _channelOffset = offset;

    if(reload){
      if(!isFirst){
        update();
      }
    }

    Response response = await conversationRepo.getChannelList(offset, type: type);

    if(response.statusCode == 200){

      if(_channelOffset==1){
        if(type == "customer"){
          _customerChannelList = [];
          response.body['content']['channelList']['data'].forEach((channel){
            _customerChannelList!.add(ChannelData.fromJson(channel));
          });
        }else{
          _servicemanChannelList = [];
          response.body['content']['channelList']['data'].forEach((channel){
            _servicemanChannelList!.add(ChannelData.fromJson(channel));
          });
        }
      }else{
        if(type == "customer"){
          response.body['content']['channelList']['data'].forEach((channel){
            _customerChannelList!.add(ChannelData.fromJson(channel));
          });
        }else{
          response.body['content']['channelList']['data'].forEach((channel){
            _servicemanChannelList!.add(ChannelData.fromJson(channel));
          });
        }
      }

      _channelPageSize =response.body['content']['channelList']['last_page'];

      if(response.body['content']['adminChannel'] !=null) {
        _adminConversation = ChannelData.fromJson( response.body['content']['adminChannel']);
      }

    }else{
      ApiChecker.checkApi(response);
    }

    _paginationLoading = false;
    _isLoading = false;
    update();
  }

  Future<void> createChannel({String? userID,String? referenceID,String? name,String? image,String? phone,String userType=''}) async{
    _paginationLoading = true;
     Response response = await conversationRepo.createChannel(userID : userID, referenceID: referenceID);
     if(response.statusCode == 200){
       _isLoading = false;
       if(userType != 'super-admin'){
         Get.toNamed(RouteHelper.getChatScreenRoute(response.body['content']['id'],name!,image!,phone!,userType));
       }
     }else{
       ApiChecker.checkApi(response);
     }
     _paginationLoading=false;
     update();
  }

  Future<void> getConversation(String channelID, int offset, {bool isConversation = true, bool isFromPagination = false}) async{
    _messageOffset = offset;
    if(isConversation){
      _isFirst = true;
    }

   Response response = await conversationRepo.getConversation(channelID, offset);
    if(response.statusCode == 200){
      getChannelList(1, reload: true);

      if(!isFromPagination){
        _conversationList = [];
      }
      response.body['content']['data'].forEach((conversation){_conversationList!.add(ConversationData.fromJson(conversation));
      _messagePageSize =  response.body['content']['last_page'];
      _channelId = _conversationList![0].channelId!;
      });

    }else{

      ApiChecker.checkApi(response);
    }

    _isFirst = false;
    update();
  }

  Future<void> sendMessage(String channelID) async{
    _isLoading = true;
    update();
    Response response = await conversationRepo.sendMessage(conversationController.value.text,channelID ,_selectedImageList, objFile);
    if(response.statusCode == 200){
      getConversation(channelID,1,isConversation: false);
      conversationController.text='';
      _pickedImageFiles = [];
      _selectedImageList = [];
      _otherFile=null;
      objFile=null;
      _file=null;
    }
    else if(response.statusCode == 400){
      String message = response.body['errors'][0]['message'];
      if(message.contains("png  jpg  jpeg  csv  txt  xlx  xls  pdf")){
        message = "the_files_types_must_be";
      }
      if(message.contains("failed to upload")){
        message = "failed_to_upload";
      }
      _pickedImageFiles = [];
      _selectedImageList = [];
      _otherFile=null;
      objFile=null;
      _file=null;
      showCustomSnackBar(message.tr);
    }
    else{
      _pickedImageFiles = [];
      _selectedImageList = [];
      _otherFile=null;
      objFile=null;
      _file=null;
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  void resetControllerValue({bool shouldUpdate = true}){
    _pickedImageFiles = [];
    _selectedImageList = [];
    _otherFile=null;
    objFile=null;
    _file=null;

    if(shouldUpdate){
      update();
    }
  }



  void downloadFile(String url, String dir, String openFileUrl, String fileName) async {

    var snackBar = const SnackBar(content: Text('Downloading....'),backgroundColor: Colors.black54, duration: Duration(seconds: 1),);
    ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);

    final task  = await FlutterDownloader.enqueue(
      url: url,
      savedDir: dir,
      fileName: fileName,
      showNotification: true,
      saveInPublicStorage: true,
      openFileFromNotification: true,
    );

    if(task !=null){
      await OpenFile.open(openFileUrl);
    }
  }

  void showSuffixIcon(BuildContext context,String text){
    if(text.isNotEmpty){
      _isActiveSuffixIcon = true;
    }else if(text.isEmpty){
      _isActiveSuffixIcon = false;
      searchController.clear();
      _isSearchComplete = false;
    }
    update();
  }

  void clearSearchController({bool shouldUpdate = true} ){
    searchController.clear();
    _isSearchComplete = false;
    _isActiveSuffixIcon = false;
    tabController?.index = 0;
    if(shouldUpdate){
      update();
    }
  }

  String getChatTime (String todayChatTimeInUtc , String? nextChatTimeInUtc) {
    String chatTime = '';
    DateTime todayConversationDateTime = DateConverter.isoUtcStringToLocalTimeOnly(todayChatTimeInUtc);

    DateTime nextConversationDateTime;
    DateTime currentDate = DateTime.now();

    if(nextChatTimeInUtc == null){
      return chatTime = DateConverter.isoStringToLocalDateAndTime(todayChatTimeInUtc);
    }else{
      nextConversationDateTime = DateConverter.isoUtcStringToLocalTimeOnly(nextChatTimeInUtc);

      if(todayConversationDateTime.difference(nextConversationDateTime) < const Duration(minutes: 30) &&
        todayConversationDateTime.weekday == nextConversationDateTime.weekday){
        chatTime = '';
      }else if(currentDate.weekday != todayConversationDateTime.weekday
          && DateConverter.countDays(dateTime: todayConversationDateTime) < 6){

        if( (currentDate.weekday -1 == 0 ? 7 : currentDate.weekday -1) == todayConversationDateTime.weekday){
          chatTime = DateConverter.convert24HourTimeTo12HourTimeWithDay(todayConversationDateTime, false);
        }else{
          chatTime = DateConverter.convertStringTimeToDate(todayConversationDateTime);
        }

      }else if(currentDate.weekday == todayConversationDateTime.weekday
          && DateConverter.countDays(dateTime : todayConversationDateTime) < 6){
        chatTime = DateConverter.convert24HourTimeTo12HourTimeWithDay(todayConversationDateTime, true);
      }else{
        chatTime = DateConverter.isoStringToLocalDateAndTime(todayChatTimeInUtc);
      }
    }
    return chatTime;
  }

  bool isSameUserWithPreviousMessage( ConversationData ? previousConversation, ConversationData? currentConversation){
    if(previousConversation?.userId == currentConversation?.userId && previousConversation?.message != null && currentConversation?.message !=null){
      return true;
    }
    return false;
  }
  bool isSameUserWithNextMessage( ConversationData? currentConversation, ConversationData? nextConversation){
    if(currentConversation?.userId == nextConversation?.userId && nextConversation?.message != null && currentConversation?.message !=null){
      return true;
    }
    return false;
  }


  String? getOnPressChatTime(ConversationData currentConversation){
    if(currentConversation.id == _onMessageTimeShowID || currentConversation.id == _onImageOrFileTimeShowID){
      DateTime currentDate = DateTime.now();
      DateTime todayConversationDateTime = DateConverter.isoUtcStringToLocalTimeOnly(
          currentConversation.createdAt ?? ""
      );

      if(currentDate.weekday != todayConversationDateTime.weekday
          && DateConverter.countDays(dateTime : todayConversationDateTime) <= 7){
        return DateConverter.convertStringTimeToDate(todayConversationDateTime);
      }else if(currentDate.weekday == todayConversationDateTime.weekday
          && DateConverter.countDays( dateTime : todayConversationDateTime) <= 7){
        return  DateConverter.convert24HourTimeTo12HourTime(todayConversationDateTime);
      }else{
        return DateConverter.isoStringToLocalDateAndTime(currentConversation.createdAt!);
      }
    }else{
      return null;
    }
  }

  String getChatTimeWithPrevious (ConversationData currentChat, ConversationData? previousChat) {
    DateTime todayConversationDateTime = DateConverter
        .isoUtcStringToLocalTimeOnly(currentChat.createdAt ?? "");

    DateTime previousConversationDateTime;

    if (previousChat?.createdAt == null) {
      return 'Not-Same';
    } else {
      previousConversationDateTime =
          DateConverter.isoUtcStringToLocalTimeOnly(previousChat!.createdAt!);
      if (kDebugMode) {
        print("The Difference is ${previousConversationDateTime.difference(todayConversationDateTime) < const Duration(minutes: 30)}");
      }
      if (previousConversationDateTime.difference(todayConversationDateTime) <
          const Duration(minutes: 30) &&
          todayConversationDateTime.weekday ==
              previousConversationDateTime.weekday && isSameUserWithPreviousMessage(currentChat, previousChat)) {
        return '';
      } else {
        return 'Not-Same';
      }
    }

  }

  void toggleOnClickMessage ({required String onMessageTimeShowID}){
    _onImageOrFileTimeShowID = '';
    _isClickedOnImageOrFile = false;
    if(_isClickedOnMessage && _onMessageTimeShowID != onMessageTimeShowID){
      _onMessageTimeShowID = onMessageTimeShowID;
    }else if(_isClickedOnMessage && _onMessageTimeShowID == onMessageTimeShowID){
      _isClickedOnMessage = false;
      _onMessageTimeShowID = '';
    }else{
      _isClickedOnMessage = true;
      _onMessageTimeShowID = onMessageTimeShowID;
    }
    update();
  }


  void toggleOnClickImageAndFile ({required String onImageOrFileTimeShowID}){
    _onMessageTimeShowID = '';
    _isClickedOnMessage = false;
    if(_isClickedOnImageOrFile && _onImageOrFileTimeShowID != onImageOrFileTimeShowID){
      _onImageOrFileTimeShowID = onImageOrFileTimeShowID;
    }else if(_isClickedOnImageOrFile && _onImageOrFileTimeShowID == onImageOrFileTimeShowID){
      _isClickedOnImageOrFile = false;
      _onImageOrFileTimeShowID = '';
    }else{
      _isClickedOnImageOrFile = true;
      _onImageOrFileTimeShowID = onImageOrFileTimeShowID;
    }
    update();
  }


}