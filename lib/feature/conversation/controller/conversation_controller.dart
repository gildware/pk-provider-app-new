import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class _ConversationChannelCache {
  const _ConversationChannelCache({
    required this.messages,
    required this.loadedPage,
    required this.lastPage,
  });

  final List<ConversationData> messages;
  final int loadedPage;
  final int lastPage;
}

class ConversationController extends GetxController with GetSingleTickerProviderStateMixin implements GetxService   {
  static const String chatMessagesUpdateId = 'chat_messages';
  static const String chatSendUpdateId = 'chat_send';
  static const String chatBadgeUpdateId = 'chat_badge';
  static const String channelListUpdateId = 'channel_list';

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

  int _unreadChatCount = 0;
  int get unreadChatCount => _unreadChatCount;

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

  final Map<String, _ConversationChannelCache> _conversationCache = {};
  int _conversationFetchGeneration = 0;
  bool _isAppendingIncomingMessages = false;
  bool _isLoadingOlderMessages = false;
  bool get isLoadingOlderMessages => _isLoadingOlderMessages;
  Future<void>? _pendingConversationFetch;
  String _pendingConversationChannelId = '';
  String _displayedConversationChannelId = '';
  String get displayedConversationChannelId => _displayedConversationChannelId;

  ConversationUser? _activeChannelPeerUser;

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
    final normalized = normalizeChannelId(channelId);
    if (_channelId != normalized) {
      _displayedConversationChannelId = '';
      _pendingConversationFetch = null;
      _pendingConversationChannelId = '';
      _cancelInFlightConversationFetch();
    }
    _channelId = normalized;
    conversationController.text = "";
  }

  void setActiveChannelPeer({
    required String userType,
    required String name,
    String? image,
    String? phone,
  }) {
    final trimmedName = name.trim();
    final nameParts = trimmedName.split(RegExp(r'\s+'));
    _activeChannelPeerUser = ConversationUser(
      userType: userType,
      firstName: nameParts.isNotEmpty ? nameParts.first : trimmedName,
      lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null,
      profileImage: image,
      profileImageFullPath: image,
      phone: phone,
    );
  }

  void clearActiveChannel() {
    _channelId = '';
    _displayedConversationChannelId = '';
    _activeChannelPeerUser = null;
  }

  String get _currentUserDisplayName {
    final owner = Get.find<UserProfileController>().providerModel?.content?.providerInfo?.owner;
    return '${owner?.firstName ?? ''} ${owner?.lastName ?? ''}'.trim();
  }

  String _channelListTypeForPeer(String? peerUserType) {
    if (peerUserType == 'provider-serviceman') {
      return 'serviceman';
    }
    return 'customer';
  }

  void refreshActiveChannelListPreview() {
    final channelListType = _channelListTypeForPeer(_activeChannelPeerUser?.userType);
    unawaited(getChannelList(1, type: channelListType, silent: true));
  }

  void _updateChannelListPreviewAfterSend({
    required String channelId,
    required String? messageText,
    required String senderDisplayName,
    String? attachmentType,
    int? fileCount,
  }) {
    final normalizedId = normalizeChannelId(channelId);
    final now = DateTime.now().toUtc().toIso8601String();
    var updated = false;

    void applyToList(List<ChannelData>? list) {
      if (list == null) {
        return;
      }
      final index = list.indexWhere(
        (channel) => normalizeChannelId(channel.id) == normalizedId,
      );
      if (index == -1) {
        return;
      }

      final channel = list.removeAt(index);
      final trimmedMessage = messageText?.trim();
      channel.lastSentMessage = trimmedMessage?.isNotEmpty == true ? trimmedMessage : null;
      channel.lastMessageSentUser = senderDisplayName;
      channel.lastSentAttachmentType =
          trimmedMessage?.isNotEmpty == true ? null : attachmentType;
      channel.lastSentFileCount = fileCount;
      channel.lastMessageStatus = 'sent';
      channel.lastSentAt = now;
      for (final channelUser in channel.channelUsers ?? <ConversationUserModel>[]) {
        channelUser.updatedAt = now;
      }
      list.insert(0, channel);
      updated = true;
    }

    applyToList(_customerChannelList);
    applyToList(_servicemanChannelList);
    applyToList(_searchedCustomerChannelList);
    applyToList(_searchedServicemanChannelList);

    if (updated) {
      update([channelListUpdateId]);
    }
  }

  bool isViewingChannel(String channelId) {
    if (!Get.currentRoute.contains(RouteHelper.chatScreen)) {
      return false;
    }

    final normalized = normalizeChannelId(channelId);
    final openChannelId = normalizeChannelId(Get.parameters['channelID']);
    if (openChannelId.isNotEmpty) {
      return openChannelId == normalized;
    }

    if (_displayedConversationChannelId.isNotEmpty) {
      return _displayedConversationChannelId == normalized;
    }

    return normalizeChannelId(_channelId) == normalized;
  }

  ConversationUser _userFromPushPayload(Map<String, dynamic> data) {
    final senderUserId = data['sender_user_id']?.toString();
    for (final message in _conversationList ?? const <ConversationData>[]) {
      if (message.userId == senderUserId && message.user != null) {
        return message.user!;
      }
    }

    if (_activeChannelPeerUser != null) {
      return ConversationUser(
        id: senderUserId ?? _activeChannelPeerUser!.id,
        userType: data['user_type']?.toString() ?? _activeChannelPeerUser!.userType,
        firstName: _activeChannelPeerUser!.firstName,
        lastName: _activeChannelPeerUser!.lastName,
        profileImage: data['user_image']?.toString().isNotEmpty == true
            ? data['user_image']?.toString()
            : _activeChannelPeerUser!.profileImage,
        profileImageFullPath: data['user_image']?.toString().isNotEmpty == true
            ? data['user_image']?.toString()
            : _activeChannelPeerUser!.profileImageFullPath,
        phone: data['user_phone']?.toString() ?? _activeChannelPeerUser!.phone,
      );
    }

    final senderName = data['user_name']?.toString().trim() ?? '';
    final nameParts = senderName.split(RegExp(r'\s+'));
    return ConversationUser(
      id: senderUserId,
      userType: data['user_type']?.toString() ?? 'customer',
      firstName: nameParts.isNotEmpty ? nameParts.first : senderName,
      lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null,
      profileImage: data['user_image']?.toString(),
      profileImageFullPath: data['user_image']?.toString(),
      phone: data['user_phone']?.toString(),
    );
  }

  static String normalizeChannelId(String? channelId) {
    return channelId?.trim() ?? '';
  }

  void _cacheConversation(String channelId) {
    final normalizedChannelId = normalizeChannelId(channelId);
    if (_conversationList == null || _conversationList!.isEmpty) {
      return;
    }

    _conversationCache[normalizedChannelId] = _ConversationChannelCache(
      messages: List<ConversationData>.from(_conversationList!),
      loadedPage: _messageOffset ?? 1,
      lastPage: _messagePageSize ?? 1,
    );
  }

  _ConversationChannelCache? _cachedConversation(String channelId) {
    return _conversationCache[normalizeChannelId(channelId)];
  }

  @override
  void onInit(){
    super.onInit();

    // SERVICEMAN_DISABLED
    tabController = TabController(
      vsync: this,
      length: AppFeatureFlags.servicemanEnabled ? 2 : 1,
    );

    if (Get.find<AuthController>().isLoggedIn()) {
      // Badge is loaded from BottomNavScreen.loadData after channel list is ready.
    }

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

    messageScrollController.addListener(_loadOlderMessagesIfNeeded);
  }

  int _parseLastPage(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 1;
  }

  bool get _hasMoreOlderMessages {
    return (_messagePageSize ?? 1) > (_messageOffset ?? 1);
  }

  void _loadOlderMessagesIfNeeded() {
    if (!_hasMoreOlderMessages || _isLoadingOlderMessages || _channelId.isEmpty) {
      return;
    }

    if (!messageScrollController.hasClients) {
      return;
    }

    final position = messageScrollController.position;
    if (!position.hasPixels) {
      return;
    }

    if (position.pixels < position.maxScrollExtent - 120) {
      return;
    }

    unawaited(getConversation(
      _channelId,
      (_messageOffset ?? 1) + 1,
      isFromPagination: true,
    ));
  }

  void _scheduleAutoLoadOlderMessages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasMoreOlderMessages || _isLoadingOlderMessages) {
        return;
      }

      if (!messageScrollController.hasClients) {
        return;
      }

      final position = messageScrollController.position;
      if (!position.hasPixels) {
        return;
      }

      if (position.maxScrollExtent <= 120 ||
          position.pixels >= position.maxScrollExtent - 120) {
        _loadOlderMessagesIfNeeded();
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

  Future<void> getChannelList(int offset, {bool isFromPagination = false,bool reload = false, bool isFirst = false, String type = "customer", bool silent = false}) async{
    _channelOffset = offset;

    if(reload && !silent){
      if(!isFirst){
        update([channelListUpdateId]);
      }
    }

    Response response = await conversationRepo.getChannelList(offset, type: type);

    if(response.statusCode == 200){
      _ensureSupportChatBrandingIcons();

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

      if (_channelOffset == 1 && type == 'customer') {
        unawaited(getUnreadChatCount(prefetchChannels: false));
      }

    }else{
      ApiChecker.checkApi(response);
    }

    _paginationLoading = false;
    _isLoading = false;
    update([channelListUpdateId]);
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

  String _messageContentKey(ConversationData message) {
    return '${message.userId ?? ''}|${message.message?.trim() ?? ''}';
  }

  bool _conversationListsEqual(
    List<ConversationData> current,
    List<ConversationData> next,
  ) {
    if (current.length != next.length) {
      return false;
    }
    for (var index = 0; index < current.length; index++) {
      if (current[index].id != next[index].id) {
        return false;
      }
    }
    return true;
  }

  List<ConversationData> _mergeConversationFirstPage(
    List<ConversationData> current,
    List<ConversationData> serverPage,
  ) {
    final serverIds = serverPage.map((message) => message.id).whereType<String>().toSet();
    final serverContentKeys = serverPage.map(_messageContentKey).toSet();
    final optimistic = current.where((message) {
      if (message.id != null && serverIds.contains(message.id)) {
        return false;
      }
      return !serverContentKeys.contains(_messageContentKey(message));
    }).toList();
    return [...optimistic, ...serverPage];
  }

  void _refreshConversationInBackground(
    String normalizedChannelId,
    int offset, {
    bool refreshChannelList = false,
  }) {
    if ((_messageOffset ?? 1) > 1) {
      unawaited(appendIncomingMessages(normalizedChannelId));
      return;
    }

    unawaited(_fetchConversationPage(
      normalizedChannelId,
      offset,
      isFromPagination: false,
      refreshChannelList: refreshChannelList,
      showLoader: false,
    ));
  }

  /// Start loading messages before navigation so the chat screen opens instantly.
  void prefetchConversation(String channelID) {
    final normalizedChannelId = normalizeChannelId(channelID);
    if (normalizedChannelId.isEmpty) {
      return;
    }

    final cached = _cachedConversation(normalizedChannelId);
    if (cached != null && cached.messages.isNotEmpty) {
      return;
    }

    if (_pendingConversationChannelId == normalizedChannelId &&
        _pendingConversationFetch != null) {
      return;
    }

    _channelId = normalizedChannelId;
    _pendingConversationChannelId = normalizedChannelId;
    _pendingConversationFetch = _fetchConversationPage(
      normalizedChannelId,
      1,
      isFromPagination: false,
      refreshChannelList: false,
      showLoader: false,
    ).whenComplete(() {
      if (_pendingConversationChannelId == normalizedChannelId) {
        _pendingConversationFetch = null;
        _pendingConversationChannelId = '';
      }
    });
    unawaited(_pendingConversationFetch);
  }

  Future<void> getConversation(
    String channelID,
    int offset, {
    bool isConversation = true,
    bool isFromPagination = false,
    bool refreshChannelList = false,
  }) async {
    final normalizedChannelId = normalizeChannelId(channelID);

    if (isFromPagination) {
      if (_isLoadingOlderMessages || !_hasMoreOlderMessages) {
        return;
      }

      await _fetchConversationPage(
        normalizedChannelId,
        (_messageOffset ?? 1) + 1,
        isFromPagination: true,
        refreshChannelList: false,
        showLoader: false,
      );
      return;
    }

    _messageOffset = offset;
    _channelId = normalizedChannelId;

    if (isConversation) {
      if (_pendingConversationChannelId == normalizedChannelId &&
          _pendingConversationFetch != null) {
        await _pendingConversationFetch;
      }

      if (_displayedConversationChannelId == normalizedChannelId &&
          _conversationList != null &&
          _conversationList!.isNotEmpty) {
        _isFirst = false;
        update([chatMessagesUpdateId]);
        _scheduleAutoLoadOlderMessages();
        _refreshConversationInBackground(
          normalizedChannelId,
          1,
          refreshChannelList: refreshChannelList,
        );
        return;
      }

      final cached = _cachedConversation(normalizedChannelId);
      if (cached != null && cached.messages.isNotEmpty) {
        _conversationList = List<ConversationData>.from(cached.messages);
        _messageOffset = cached.loadedPage;
        _messagePageSize = cached.lastPage;
        _displayedConversationChannelId = normalizedChannelId;
        _isFirst = false;
        update([chatMessagesUpdateId]);
        _scheduleAutoLoadOlderMessages();
        _refreshConversationInBackground(
          normalizedChannelId,
          1,
          refreshChannelList: refreshChannelList,
        );
        return;
      }

      if (_displayedConversationChannelId != normalizedChannelId) {
        _conversationList = null;
        _messageOffset = 1;
        _messagePageSize = null;
        _isFirst = true;
        update([chatMessagesUpdateId]);
      } else if (_conversationList == null || _conversationList!.isEmpty) {
        _messageOffset = 1;
        _messagePageSize = null;
        _isFirst = true;
        update([chatMessagesUpdateId]);
      }
    }

    await _fetchConversationPage(
      normalizedChannelId,
      offset,
      isFromPagination: isFromPagination,
      refreshChannelList: refreshChannelList,
      showLoader: isConversation && !isFromPagination,
    );
  }

  void _cancelInFlightConversationFetch() {
    _conversationFetchGeneration++;
  }

  Future<void> _fetchConversationPage(
    String normalizedChannelId,
    int offset, {
    required bool isFromPagination,
    required bool refreshChannelList,
    required bool showLoader,
  }) async {
    if (isFromPagination) {
      _isLoadingOlderMessages = true;
      update([chatMessagesUpdateId]);
    }

    final generationAtStart = _conversationFetchGeneration;
    final channelIdAtStart = normalizedChannelId;

    try {
      final response = await conversationRepo.getConversation(normalizedChannelId, offset);
      if (generationAtStart != _conversationFetchGeneration ||
          channelIdAtStart != _channelId) {
        return;
      }

      if (response.statusCode == 200) {
        if (refreshChannelList) {
          unawaited(getChannelList(1, silent: true));
        }

        final rawMessages = response.body['content']['data'] as List;
        final pageMessages = rawMessages
            .map((conversation) => ConversationData.fromJson(conversation))
            .toList(growable: true);

        if (isFromPagination) {
          _conversationList ??= [];
          final existingIds = _conversationList!
              .map((message) => message.id)
              .whereType<String>()
              .toSet();
          for (final message in pageMessages) {
            final messageId = message.id;
            if (messageId != null && !existingIds.contains(messageId)) {
              _conversationList!.add(message);
              existingIds.add(messageId);
            }
          }
          _messageOffset = offset;
        } else if (!showLoader &&
            _conversationList != null &&
            _conversationList!.isNotEmpty &&
            (_messageOffset ?? 1) == 1) {
          _conversationList = _mergeConversationFirstPage(_conversationList!, pageMessages);
          _messageOffset = offset;
        } else {
          _conversationList = pageMessages;
          _messageOffset = offset;
        }

        _messagePageSize = _parseLastPage(response.body['content']['last_page']);
        _cacheConversation(normalizedChannelId);
        if (!isFromPagination) {
          _displayedConversationChannelId = normalizedChannelId;
        }

        if (!isFromPagination) {
          unawaited(getUnreadChatCount());
        }

        _scheduleAutoLoadOlderMessages();
      } else {
        if (showLoader) {
          ApiChecker.checkApi(response);
        }
      }

      if (showLoader) {
        _isFirst = false;
      }
    } finally {
      if (isFromPagination) {
        _isLoadingOlderMessages = false;
      }
      update([chatMessagesUpdateId]);
    }
  }

  /// Apply a push payload directly when possible; otherwise fetch only new rows.
  Future<void> appendIncomingMessageFromPush(Map<String, dynamic> data) async {
    final channelId = normalizeChannelId(data['channel_id']?.toString());
    if (!isViewingChannel(channelId)) {
      return;
    }

    _cancelInFlightConversationFetch();
    _conversationList ??= [];
    _isFirst = false;

    final conversationId = data['conversation_id']?.toString().trim() ?? '';
    final messageText = data['message']?.toString();
    if (conversationId.isNotEmpty && messageText != null && messageText.isNotEmpty) {
      final alreadyShown = _conversationList!.any((item) => item.id == conversationId);
      if (!alreadyShown) {
        _conversationList!.insert(0, ConversationData(
          id: conversationId,
          channelId: channelId,
          message: messageText,
          userId: data['sender_user_id']?.toString(),
          createdAt: data['created_at']?.toString() ?? DateTime.now().toUtc().toIso8601String(),
          user: _userFromPushPayload(data),
          conversationFile: const [],
        ));
        _cacheConversation(channelId);
        update([chatMessagesUpdateId]);
        return;
      }
    }

    await appendIncomingMessages(channelId);
  }

  /// Fetches the latest page and appends only messages not already shown.
  Future<void> appendIncomingMessages(String channelID) async {
    final normalizedChannelId = normalizeChannelId(channelID);
    if (!isViewingChannel(normalizedChannelId) || _isAppendingIncomingMessages) {
      return;
    }

    _isAppendingIncomingMessages = true;
    try {
      _conversationList ??= [];
      _isFirst = false;

      final response = await conversationRepo.getConversation(normalizedChannelId, 1);
      if (response.statusCode != 200) {
        return;
      }

      final pageMessages = (response.body['content']['data'] as List)
          .map((conversation) => ConversationData.fromJson(conversation))
          .toList(growable: true);

      if ((_messageOffset ?? 1) == 1) {
        final merged = _mergeConversationFirstPage(_conversationList!, pageMessages);
        if (_conversationListsEqual(_conversationList!, merged)) {
          return;
        }
        _conversationList = merged;
      } else {
        final existingIds = _conversationList!
            .map((message) => message.id)
            .whereType<String>()
            .toSet();
        final existingContentKeys = _conversationList!.map(_messageContentKey).toSet();
        final newMessages = <ConversationData>[];
        var replacedOptimistic = false;

        for (final message in pageMessages) {
          final messageId = message.id;
          if (messageId == null || existingIds.contains(messageId)) {
            continue;
          }

          final contentKey = _messageContentKey(message);
          final optimisticIndex = _conversationList!.indexWhere((item) =>
              item.id != messageId && _messageContentKey(item) == contentKey);
          if (optimisticIndex >= 0) {
            _conversationList![optimisticIndex] = message;
            existingIds.add(messageId);
            replacedOptimistic = true;
            continue;
          }

          if (!existingContentKeys.contains(contentKey)) {
            newMessages.add(message);
            existingIds.add(messageId);
            existingContentKeys.add(contentKey);
          }
        }

        if (newMessages.isEmpty && !replacedOptimistic) {
          return;
        }

        if (newMessages.isNotEmpty) {
          _conversationList!.insertAll(0, newMessages);
        }
      }

      _messagePageSize = _parseLastPage(response.body['content']['last_page']);
      _cacheConversation(normalizedChannelId);
      update([chatMessagesUpdateId]);
    } finally {
      _isAppendingIncomingMessages = false;
    }
  }

  /// Append a single sent message locally without refetching the whole thread.
  void appendSentMessage({
    required String channelId,
    required String message,
    required String senderUserId,
    String? conversationId,
  }) {
    if (!isViewingChannel(channelId)) {
      return;
    }

    _conversationList ??= [];
    _isFirst = false;
    final resolvedId = conversationId ?? DateTime.now().microsecondsSinceEpoch.toString();
    if (_conversationList!.any((item) => item.id == resolvedId)) {
      return;
    }

    _conversationList!.insert(0, ConversationData(
      id: resolvedId,
      channelId: normalizeChannelId(channelId),
      message: message,
      userId: senderUserId,
      createdAt: DateTime.now().toUtc().toIso8601String(),
      user: ConversationUser(
        id: senderUserId,
        userType: 'provider-admin',
        firstName: 'you'.tr,
      ),
      conversationFile: const [],
    ));
    _cacheConversation(channelId);
    update([chatMessagesUpdateId]);
  }

  Future<void> getUnreadChatCount({bool prefetchChannels = true}) async {
    if (!Get.find<AuthController>().isLoggedIn()) {
      return;
    }

    if (prefetchChannels && _adminConversation == null) {
      await getChannelList(1, type: 'customer', silent: true);
    }

    final response = await conversationRepo.getUnreadConversationCount();
    if (response.statusCode == 200) {
      final count = response.body['content']?['unread_conversation'];
      final apiCount = count is int ? count : int.tryParse('$count') ?? 0;
      _unreadChatCount = _resolvedUnreadChatCount(apiCount);
      update([chatBadgeUpdateId]);
    }
  }

  bool _channelHasAnyMessages(ChannelData channel) {
    return (channel.lastSentMessage?.trim().isNotEmpty ?? false) ||
        (channel.lastSentFileCount ?? 0) > 0;
  }

  int _resolvedUnreadChatCount(int apiCount) {
    if (apiCount <= 0) {
      return 0;
    }

    final admin = _adminConversation;
    if (admin != null && !_channelHasAnyMessages(admin)) {
      return apiCount > 0 ? apiCount - 1 : 0;
    }

    return apiCount;
  }

  Future<void> sendMessage(String channelID) async{
    _isLoading = true;
    update([chatSendUpdateId]);
    final sentText = conversationController.value.text;
    Response response = await conversationRepo.sendMessage(sentText,channelID ,_selectedImageList, objFile);
    if(response.statusCode == 200){
      _cancelInFlightConversationFetch();
      final senderUserId = Get.find<UserProfileController>().providerModel?.content?.providerInfo?.userId;
      final senderDisplayName = _currentUserDisplayName;
      final channelListType = _channelListTypeForPeer(_activeChannelPeerUser?.userType);
      if (sentText.trim().isNotEmpty && senderUserId != null) {
        appendSentMessage(
          channelId: channelID,
          message: sentText,
          senderUserId: senderUserId,
        );
        _updateChannelListPreviewAfterSend(
          channelId: channelID,
          messageText: sentText,
          senderDisplayName: senderDisplayName,
        );
      } else {
        await appendIncomingMessages(channelID);
        _updateChannelListPreviewAfterSend(
          channelId: channelID,
          messageText: null,
          senderDisplayName: senderDisplayName,
          attachmentType: _selectedImageList.isNotEmpty ? 'jpg' : null,
          fileCount: _selectedImageList.isNotEmpty
              ? _selectedImageList.length
              : objFile?.length,
        );
      }
      unawaited(getChannelList(1, type: channelListType, silent: true));
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
    update([chatMessagesUpdateId, chatSendUpdateId]);
  }

  void _ensureSupportChatBrandingIcons() {
    if (!Get.isRegistered<SplashController>()) {
      return;
    }

    final icons = Get.find<SplashController>().configModel.content?.mobileAppIcons;
    if (icons != null && icons.containsKey(MobileAppIconHelper.customerAppLogoKey)) {
      return;
    }

    unawaited(Get.find<SplashController>().getConfigData());
  }

  void resetOnAuthChange() {
    _cancelInFlightConversationFetch();
    _conversationCache.clear();
    _conversationList = null;
    _adminConversation = null;
    _customerChannelList = null;
    _servicemanChannelList = null;
    _searchedChannelList = [];
    _searchedCustomerChannelList = [];
    _searchedServicemanChannelList = [];
    _channelId = '';
    _displayedConversationChannelId = '';
    _pendingConversationChannelId = '';
    _pendingConversationFetch = null;
    _activeChannelPeerUser = null;
    _unreadChatCount = 0;
    _messageOffset = 1;
    _messagePageSize = null;
    _isFirst = false;
    _channelOffset = 1;
    _channelPageSize = null;
    _paginationLoading = false;
    _isLoading = false;
    clearSearchController(shouldUpdate: false);
    update([chatMessagesUpdateId, chatSendUpdateId, chatBadgeUpdateId, channelListUpdateId]);
  }

  void resetControllerValue({bool shouldUpdate = true}){
    _pickedImageFiles = [];
    _selectedImageList = [];
    _otherFile=null;
    objFile=null;
    _file=null;

    if(shouldUpdate){
      update([chatSendUpdateId]);
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