class NotificationResponseModel {
  final int unreadCount;
  final List<NotificationModel> notifications;

  NotificationResponseModel({
    required this.unreadCount,
    required this.notifications,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationResponseModel(
      unreadCount: json['unreadCount'] ?? 0,
      notifications: (json['notifications'] as List? ?? [])
          .map((e) => NotificationModel.fromJson(e))
          .toList(),
    );
  }
}

class NotificationModel {
  final int notificationId;
  final String type;
  final String title;
  final String message;
  final int? orderId;
  final int? baggageId;
  final bool isRead;
  final String sentAt;

  const NotificationModel({
    required this.notificationId,
    required this.type,
    required this.title,
    required this.message,
    this.orderId,
    this.baggageId,
    required this.isRead,
    required this.sentAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] ?? 0,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      orderId: json['orderId'],
      baggageId: json['baggageId'],
      isRead: json['isRead'] ?? false,
      sentAt: json['sentAt'] ?? '',
    );
  }
}
