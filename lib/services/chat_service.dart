import '../services/appwrite_service.dart';

class ChatService {
  final AppwriteService _appwrite = AppwriteService();

  String generateConversationId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<Map<String, dynamic>?> getConversation(String conversationId) async {
    final conversations = await _appwrite.getConversations('');
    try {
      return conversations.firstWhere((c) => c['id'] == conversationId);
    } catch (e) {
      return null;
    }
  }

  Future<String?> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  }) async {
    return await _appwrite.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      content: content,
    );
  }

  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    return await _appwrite.getMessages(conversationId);
  }

  Future<void> markMessagesAsRead(String conversationId, String recipientUid) async {
    // Simple implementation - could be expanded
  }
}