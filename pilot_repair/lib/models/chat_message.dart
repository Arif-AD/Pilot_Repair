class ChatMessage {
  final int? id;
  final int orderId;
  final int senderId;
  final String messageType; // 'text', 'system', 'quick_reply'
  final String content;
  final bool isRead;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? senderName;
  final String? senderRole;

  ChatMessage({
    this.id,
    required this.orderId,
    required this.senderId,
    this.messageType = 'text',
    required this.content,
    this.isRead = false,
    this.createdAt,
    this.updatedAt,
    this.senderName,
    this.senderRole,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int?,
      orderId: json['order_id'] as int,
      senderId: json['sender_id'] as int,
      messageType: json['message_type'] as String? ?? 'text',
      content: json['content'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      senderName: json['sender_name'] as String?,
      senderRole: json['sender_role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'sender_id': senderId,
      'message_type': messageType,
      'content': content,
      'is_read': isRead,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'sender_name': senderName,
      'sender_role': senderRole,
    };
  }
}