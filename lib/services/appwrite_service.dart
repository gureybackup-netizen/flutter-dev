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
        .setKey(AppConstants.appwriteApiKey);
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
  
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        queries: [
          Query.contains('display_name', query),
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
    required String conversationId,
    required String userId,
    required String otherUserId,
    required String otherDisplayName,
  }) async {
    try {
      await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.conversationsCollectionId,
        documentId: conversationId,
        data: {
          'id': conversationId,
          'participant_ids': [userId, otherUserId],
          'participant_display_names': {userId: 'Me', otherUserId: otherDisplayName},
          'last_message_at': DateTime.now().toIso8601String(),
          'unread_count': 0,
        },
      );
      return null;
    } catch (e) {
      return e.toString();
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
      return result.documents.map((doc) => doc.data).toList();
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
        },
      );
      return messageId;
    } catch (e) {
      return null;
    }
  }
}