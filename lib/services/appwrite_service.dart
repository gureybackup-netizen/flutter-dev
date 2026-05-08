import 'package:appwrite/appwrite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';

class AppwriteService {
  late Client _client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  
  AppwriteService._internal() {
    _client = Client()
        .setEndpoint(AppConstants.appwriteEndpoint)
        .setProject(AppConstants.appwriteProjectId)
        .addHeader('X-Appwrite-Key', AppConstants.appwriteApiKey);
  }
  
  Client get client => _client;
  Account get account => Account(_client);
  Databases get databases => Databases(_client);
  
  String generateUniqueId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final now = DateTime.now().millisecondsSinceEpoch;
    StringBuffer buffer = StringBuffer('VARD-');
    for (int i = 0; i < 8; i++) {
      buffer.write(chars[(now >> (i * 3)) % chars.length]);
    }
    return buffer.toString();
  }
  
  Future<String?> createUser({required String uniqueId, required String displayName}) async {
    try {
      await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: uniqueId,
        data: {
          'unique_id': uniqueId,
          'display_name': displayName,
          'created_at': DateTime.now().toIso8601String(),
        },
      );
      await _secureStorage.write(key: 'user_id', value: uniqueId);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
  
  Future<String?> loginWithUniqueId(String uniqueId) async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        queries: [
          Query.equal('unique_id', [uniqueId]),
        ],
      );
      
      if (result.documents.isEmpty) {
        return 'User not found';
      }
      
      await _secureStorage.write(key: 'user_id', value: uniqueId);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
  
  Future<String?> getCurrentUserId() async {
    return await _secureStorage.read(key: 'user_id');
  }
  
  Future<void> logout() async {
    await _secureStorage.delete(key: 'user_id');
  }
  
  Future<Map<String, dynamic>?> getUserByUniqueId(String uniqueId) async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        queries: [
          Query.equal('unique_id', [uniqueId]),
        ],
      );
      
      if (result.documents.isEmpty) return null;
      return result.documents.first.data;
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> updateUserDisplayName({required String userId, required String displayName}) async {
    try {
      await databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: userId,
        data: {
          'display_name': displayName,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> updateUserNotificationSetting({required String userId, required bool enabled}) async {
    // Placeholder - notifications_enabled not in schema
    // In production, this would update the user's notification preference
    return true;
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];
      
      final result = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        queries: [
          Query.startsWith('unique_id', query.toUpperCase()),
          Query.limit(20),
        ],
      );
      return result.documents.map((doc) => doc.data).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.conversationsCollectionId,
        queries: [
          Query.contains('participant_ids', [userId]),
          Query.orderDesc('last_message_at'),
        ],
      );
      return result.documents.map((doc) => doc.data).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> createConversation({
    required String userId,
    required String otherUserId,
    required String otherDisplayName,
  }) async {
    try {
      final participants = [userId, otherUserId]..sort();
      final conversationId = '${participants[0]}_${participants[1]}';
      
      await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.conversationsCollectionId,
        documentId: conversationId,
        data: {
          'id': conversationId,
          'participant_ids': participants,
          'participant_display_names': {userId: 'Me', otherUserId: otherDisplayName},
          'last_message_at': DateTime.now().toIso8601String(),
          'unread_count': 0,
        },
      );
      return conversationId;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.messagesCollectionId,
        queries: [
          Query.equal('conversation_id', [conversationId]),
          Query.orderDesc('sent_at'),
          Query.limit(100),
        ],
      );
      final messages = result.documents.map((doc) => doc.data).toList();
      return messages.where((m) => m['is_deleted_by_sender'] != true).toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<String?> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  }) async {
    try {
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Save the message
      await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.messagesCollectionId,
        documentId: messageId,
        data: {
          'id': messageId,
          'conversation_id': conversationId,
          'sender_id': senderId,
          'content': content,
          'sent_at': DateTime.now().toIso8601String(),
          'is_read': false,
          'is_deleted_by_sender': false,
        },
      );
      
      // Update conversation metadata
      final conversationDoc = await databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.conversationsCollectionId,
        documentId: conversationId,
      );
      
      final conversation = conversationDoc.data;
      final participantIds = conversation['participant_ids'] as List<dynamic>? ?? [];
      final recipientId = participantIds.firstWhere(
        (id) => id.toString() != senderId,
        orElse: () => '',
      );
      
      // Update conversation
      await databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.conversationsCollectionId,
        documentId: conversationId,
        data: {
          'last_message_at': DateTime.now().toIso8601String(),
          'last_message_preview': 'Encrypted message',
          'unread_count': (conversation['unread_count'] as int? ?? 0) + 1,
        },
      );
      
// Save notification for recipient
      await _saveNotification(
        recipientId: recipientId,
        type: 'message',
        title: 'New message',
        body: 'You have a new message',
        conversationId: conversationId,
      );

      return messageId;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveNotification({
    required String recipientId,
    required String type,
    required String title,
    required String body,
    String? conversationId,
  }) async {
    try {
      await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'notifications',
        documentId: DateTime.now().millisecondsSinceEpoch.toString(),
        data: {
          'user_id': recipientId,
          'type': type,
          'title': title,
          'body': body,
          'conversation_id': conversationId ?? '',
          'created_at': DateTime.now().toIso8601String(),
          'is_read': false,
        },
      );
    } catch (e) {
      // Silently fail - notification isn't critical
    }
  }

  Future<bool> deleteMessageForSelf(String messageId) async {
    try {
      await databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.messagesCollectionId,
        documentId: messageId,
        data: {
          'is_deleted_by_sender': true,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<List<Map<String, dynamic>>> getCallHistory(String userId) async {
    try {
      final callerResult = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.callsCollectionId,
        queries: [
          Query.equal('caller_id', [userId]),
          Query.orderDesc('created_at'),
          Query.limit(50),
        ],
      );
      
      final calleeResult = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.callsCollectionId,
        queries: [
          Query.equal('callee_id', [userId]),
          Query.orderDesc('created_at'),
          Query.limit(50),
        ],
      );
      
      final allCalls = [...callerResult.documents.map((d) => d.data), ...calleeResult.documents.map((d) => d.data)];
      allCalls.sort((a, b) {
        final aTime = a['created_at'] as String? ?? '';
        final bTime = b['created_at'] as String? ?? '';
        return bTime.compareTo(aTime);
      });
      
      return allCalls;
    } catch (e) {
      return [];
    }
  }
}
