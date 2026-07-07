// Model for app notifications (order status, info, etc.)
// Used in NotificationPage for modern notification UI

class AppNotification {
  final String id;
  final int? orderId;
  final int? userId;
  final String title;
  final String message;
  final DateTime date;
  final NotificationType type;
  final bool isRead;

  AppNotification({
    required this.id,
    this.orderId,
    this.userId,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    this.isRead = false,
  });
}

enum NotificationType {
  orderSuccess,
  orderConfirmed,
  orderCompleted,
  orderCancelled,
  info,
} 