import 'dart:convert';

class VardConversation {
  final String id;
  final List<String> participantUids;
  final Map<String, String> participantUsernames;
  final Map<String, String> participantDisplayNames;
  final DateTime? lastMessageAt;
  final int unreadCount;

  VardConversation({
    required this.id,
    required this.participantUids,
    required this.participantUsernames,
    required this.participantDisplayNames,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory VardConversation.fromMap(Map<String, dynamic> map, String id) {
    return VardConversation(
      id: id,
      participantUids: List<String>.from(map['participant_uids'] ?? []),
      participantUsernames: Map<String, String>.from(
        map['participant_usernames'] is String 
            ? jsonDecode(map['participant_usernames']) 
            : map['participant_usernames'] ?? {},
      ),
      participantDisplayNames: Map<String, String>.from(
        map['participant_display_names'] is String 
            ? jsonDecode(map['participant_display_names']) 
            : map['participant_display_names'] ?? {},
      ),
      lastMessageAt: map['last_message_at'] != null 
          ? DateTime.parse(map['last_message_at']) 
          : null,
      unreadCount: map['unread_count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participant_uids': participantUids,
      'participant_usernames': jsonEncode(participantUsernames),
      'participant_display_names': jsonEncode(participantDisplayNames),
      'last_message_at': lastMessageAt?.toIso8601String(),
      'unread_count': unreadCount,
    };
  }

  String getOtherParticipantUid(String currentUserId) {
    return participantUids.firstWhere(
      (uid) => uid != currentUserId,
      orElse: () => '',
    );
  }

  String getOtherParticipantUsername(String currentUserId) {
    final otherUid = getOtherParticipantUid(currentUserId);
    return participantUsernames[otherUid] ?? '';
  }

  String getOtherParticipantDisplayName(String currentUserId) {
    final otherUid = getOtherParticipantUid(currentUserId);
    return participantDisplayNames[otherUid] ?? '';
  }
}