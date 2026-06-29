class NotificationBody {
  String? title;
  String? body;
  String? bookingId;
  String? bookingStatus;
  String? repeatBookingType;
  String? bookingType;
  String? channelId;
  String? postId;
  String? advertisementId;
  String? notificationType;
  String? notificationImage;
  String? userProfileImage;
  String? userPhone;
  String? userName;
  String? userType;
  String? pushNotificationId;
  String? callId;
  String? agoraChannelName;

  NotificationBody({
    this.title,
    this.body,
    this.bookingId,
    this.notificationType,
    this.notificationImage,
    this.userProfileImage,
    this.channelId,
    this.userName,
    this.userPhone,
    this.userType,
    this.bookingType,
    this.repeatBookingType,
    this.bookingStatus,
    this.pushNotificationId,
    this.callId,
    this.agoraChannelName,
  });

  NotificationBody.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    body = json['body'];
    bookingId = json['booking_id'];
    bookingStatus = json['booking_status'];
    repeatBookingType = json['repeat_type'];
    bookingType = json['booking_type'];
    channelId = json['channel_id'];
    postId = json['post_id'];
    advertisementId = json['advertisement_id'];
    notificationType = json['type'];
    notificationImage = json['image'];
    userProfileImage = json['user_image'];
    userType = json['user_type'];
    userName = json['user_name'];
    userPhone = json['user_phone'];
    pushNotificationId = json['push_notification_id']?.toString();
    callId = json['call_id']?.toString();
    agoraChannelName = json['agora_channel_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['body'] = body;
    data['booking_id'] = bookingId;
    data['booking_status'] = bookingStatus;
    data['repeat_type'] = repeatBookingType;
    data['booking_type'] = bookingType;
    data['channel_id'] = channelId;
    data['post_id'] = postId;
    data['advertisement_id'] = advertisementId;
    data['type'] = notificationType;
    data['image'] = notificationImage;
    data['user_image'] = userProfileImage;
    data['user_name'] = userName;
    data['user_phone'] = userPhone;
    data['user_type'] = userType;
    data['push_notification_id'] = pushNotificationId;
    data['call_id'] = callId;
    data['agora_channel_name'] = agoraChannelName;
    return data;
  }
}
