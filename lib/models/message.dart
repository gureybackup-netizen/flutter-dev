class VardMessage {
  final String id;
  final String conversationId;
  final String senderUid;
  final String encryptedContent;
  final DateTime sentAt;
  final bool isRead;
  final bool isDeletedBySender;
  final DateTime? deliveredAt;

  VardMessage({
    required this.id,
    required this.conversationId,
    required this.senderUid,
    required this.encryptedContent,
    required this.sentAt,
    this.isRead = false,
    this.isDeletedBySender = false,
    this.deliveredAt,
  });

  factory VardMessage.fromMap(Map<String, dynamic> map, String id) {
    return VardMessage(
      id: id,
      conversationId: map['conversation_id'] ?? '',
      senderUid: map['sender_uid'] ?? '',
      encryptedContent: map['encrypted_content'] ?? '',
      sentAt: DateTime.parse(map['sent_at'] ?? DateTime.now().toIso8601String()),
      isRead: map['is_read'] ?? false,
      isDeletedBySender: map['is_deleted_by_sender'] ?? false,
      deliveredAt: map['delivered_at'] != null 
          ? DateTime.parse(map['delivered_at']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversation_id': conversationId,
      'sender_uid': senderUid,
      'encrypted_content': encryptedContent,
      'sent_at': sentAt.toIso8601String(),
      'is_read': isRead,
      'is_deleted_by_sender': isDeletedBySender,
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }

  VardMessage copyWith({
    bool? isRead,
    bool? isDeletedBySender,
    DateTime? deliveredAt,
  }) {
    return VardMessage(
      id: id,
      conversationId: conversationId,
      senderUid: senderUid,
      encryptedContent: encryptedContent,
      sentAt: sentAt,
      isRead: isRead ?? this.isRead,
      isDeletedBySender: isDeletedBySender ?? this.isDeletedBySender,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}